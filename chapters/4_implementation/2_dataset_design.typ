#import "/utils.typ": *
== Dataset Implementation
This section details the implementation of DependencyEval, from the creation of the dataset to the evaluation pipeline.
The structure of this section is similar to the structure of the previous section.

=== Project Setup
The implementation is found here: #link("https://github.com/data-niklas/DependencyEval"). It is distributed as a single self-contained Python project and versioned through Git.
DependencyEval provides a #acr("CLI"), which includes the following functionality:
1. Creation of the distributable dataset.
2. Completion and then evaluation of the dataset on the approach, using several model configurations.
3. Calculation of metrics and export into different format.

The functionality of the #acr("CLI") is split into several modules, e.g. the calculation of different metrics lies in its own module.
This enables the use of this Python package as a library, reusing functionality such as the evaluation pipeline.

=== Dependencies
To achieve the listed functionality, DependencyEval relies on several dependencies:
The two main dependencies are `click` and `virtualenv-clone`.
`click` helps in creating #acr("CLI") applications, as it allows to create such applications declaratively.
In addition, it automatically creates a help page of the commands and subcommands.
`virtualenv-clone` is another fundamental package in enabling reproducable and fast workflows, as it can duplicate a Python virtual environment. It is used to duplicate a virtual environment from a cache into a working directory.
#todo[Explain later several GB large]
Other dependencies are `openpyxl` to export stats into Excel sheets, `matplotlib` to create beautiful charts and `sankeyflow` to create Sankey diagrams of the results without and with the approach.
#todo[Requires textual for table?!, tqdm]
All other features use the standard library for operations like working with files and processes. 

#todo[ref to click and other dependencies]

=== Structure

#link(
  "https://github.com/data-niklas/DependencyEval/tree/main",
  [#figure(
      terminal(```terminal
      [green,black]❯[text,medium] tree --dirsfirst 
      [subtext1]├── [sapphire,bold]data
      [subtext1]│   ├── [sapphire,bold]dist
      [subtext1]│   ├── [sapphire,bold]tasks
      [subtext1]│   ├── [sapphire,bold]tests
      [subtext1]│   ├── metadata.json
      [subtext1]│   └── schema.json
      [subtext1]├── [sapphire,bold]model_configurations
      [subtext1]├── [sapphire,bold]evaluations
      [subtext1]└── [sapphire,bold]dependency_eval
      [subtext1]    ├── ... other modules ...
      [subtext1]    └── __main__.py
      ```),
      caption: [Directory structure of the `dependency_eval` repository.],
    )<terminal:dependency_eval:structure>],
)

The structure of the repository is fourfold.
The `data` directory contains all information to build the distributable dataset, which is then located in `data/dist`.
The evaluation results of the dataset are stored in `evaluations`, such that they are persisted in Git.
The Python package `dependency_eval` can be executed with Python, which runs the file `__main__.py` and serves the functionality through the #acr("CLI") program.
The evaluations use different model configurations, of which some used with the approach are stored in `model_configurations`.

=== Dataset Distribution
The distributable dataset is a `.jsonl` file, where each row is a #acr("JSON") dictionary with the schema as introduced in @code:dataset:format.
While the compact `.jsonl` dataset file is easily distributed and machine readable, it is hard to read for a human.
Thus, the basis for the dataset is a easily human readable form, which simplifies extending the dataset by a human (which is necessary, as the dataset is curated manually).
One base is the `data/tasks` directory, which includes a single code file for each task. The code files are named after the task and include the whole code, including the gold solution.

#figure(
  code(
    lang: "Python",
    ```py
from textual.widgets import TextArea


def create_textual_text_area_with_indent() -> TextArea:
    """Create a TextArea widget, which indents its content when tab is pressed.

    Returns:
        TextArea: New instance of TextArea with indentation on tab press
    """
    return TextArea(tab_behavior="indent")
    ```
  ), caption: [The contents of the `data/tasks/textual_1.py` file, which is used to create the task `textual_1` in the DependencyEval dataset. The file is split to obtain the imports, additional context, the function definition, function documentation string and gold standard completion.]
)<code:dataset:textual_1>

As described in the design section, the fields in @prompt:dataset:fields are combined to form the whole code with or without completion, depending on the use case.
Using the reverse process, a file such as @code:dataset:textual_1 is split into the different components to form a dataset entry.
This is possible, as every single file adheres to the same regular format.

For evaluation, the different unit tests are also stored in their own code files, in `data/tests`.
To keep the tests as simple to run as possible, they do not rely on external test runners and reuse the Python unit test framework.

#figure(
  code(
    lang: "Python",
    ```py
from importlib import reload
from unittest import TestCase, TextTestRunner, main
from unittest.mock import MagicMock


class Test(TestCase):
    def test_approach_correctness(self):
        import textual.widgets
        TextArea = reload(textual.widgets).TextArea
        globals()["TextArea"] = TextArea
        from textual.app import App
        app = App()
        out = create_textual_text_area_with_indent()
        assert isinstance(out, TextArea)
        assert hasattr(out, "tab_behavior")
        assert out.tab_behavior == "indent"

    def test_output_correctness(self):
        import textual.widgets
        TextArea = reload(textual.widgets).TextArea
        from textual.app import App
        app = App()
        TextArea = MagicMock(TextArea)
        globals()["TextArea"] = TextArea
        out = create_textual_text_area_with_indent()
        assert TextArea.call_count == 1
        kwargs = TextArea.call_args.kwargs
        assert "tab_behavior" in kwargs
        assert "tab_behaviour" not in kwargs
        assert kwargs["tab_behavior"] == "indent"

if __name__ == "__main__":
    import logging
    logging.disable(logging.CRITICAL)
    import json
    import os
    result = main(exit=False, verbosity=0, testRunner=TextTestRunner(verbosity=0, stream=open(os.devnull,"w"))).result
    print(json.dumps([len(result.errors), len(result.failures), result.testsRun]))
    ```
  ), caption: [The unit tests for the `textual_1` task. The contents are stored in `data/tests/textual_1.py`. Next to the tested dependency, only the built-in unit test framework is used. The results are communicated via standard streams.]
)<code:dataset:textual_1_tests>

The unit tests for the `textual_1` task can be found in @code:dataset:textual_1_tests.
The test file contains both a test for the functional correctness and approach correctness.

The final piece needed to form the distributable dataset is the additional metadata associated with each entry.
While the metadata could have been embedded in the code directly, e.g. as a Python comment at the top of `data/tasks/textual_1.py`, a separate metadata file such as `data/metadata.json` simplifies the parsing process and reduces format driven errors.
`metadata.json` does not use any special format. It contains a list for dictionaries, where each dictionary contains additional metadata in the same schema as the final dataset, including a field `task_name`. The task name is the same task name used for the code file, unit test file and helps associate the different informations.

When distributing the dataset, these three information sources are combined to form the different task entries. This has both the benefit of an easy to extend dataset for humans, while enabling easy distribution and use by machines. 

=== Unit Tests
As introduced in the design section and quickly described in the last section, each entry requires two test cases.
The first test case tests the functional correctness, while the second test tests the approach correctness.

The tests are implemented as standard Python unit tests. This simplifies the testing as the built-in unit test framework can be reused through the `unittest` package.
The test setup requires three components to fit together:
1. Starting the unit tests from the running Python code and
2. disabling logging to access and log the test results, while
3. mocking used objects to introspect the used approach.

Typically unit tests are either run through the command line using the unit test module:
```bash
python -m unittest path/to/file.py
```,
or by running the Python script directly and calling the function `unittest.main`.
In either case, all defined unit tests are found and executed, after which the result is printed to the standard output. The result looks similar to @terminal:unittest:
#figure(
  terminal(```terminal
...
----------------------------------------------------------------------
Ran 2 tests in 0.200s

OK
```),
caption: [Typical console output when executing two Python unit tests. Parsing the output is error prone and unneeded, as the results can be accessed directly.]
)<terminal:unittest>

The script accesses the test results directly through the `results` field, which contains the number of failures, tests with errors and the total number of tests run.
The list of errors, failures and total tests is serialized using the #acr("JSON") format and sent to the controlling process through standard output.
This simplifies the parsing process and easily yields the desired information and is extensible if more information is needed.
// IPC

As this approach relies on standard output for #acr("IPC"), all other output must be suppressed, as it complicates the parsing of the results in the controlling process.
Printing of the unit test results is suppressed by setting the test log verbosity to $0$ and redirecting the output of the test runner to the `/dev/null` stream, effectively voiding the output.

Other output is suppressed, by setting the logging level of the logger to critical.

// Approach correctness
Each unit test is carefully crafted, by mocking the objects of the gold solution and of probable deprecated functions.
Tests can then be failed directly, if the deprecated function is used instead of the gold solution. Even if the gold solution function is used, the passed parameters can be introspected, enabling complex test scenarios. Each test scenarios tests certain properties.
For the scenario in @code:dataset:textual_1_tests the tests assert that the parameter `tab_behavior` is used, while `tab_behaviour` is incorrect, as it is deprecated.

=== Evaluation Loop
At the heart of the evaluation pipeline lies the evaluation loop, which is located in `dependency_eval/loop.py`. It is abstractly defined in @code:dataset:loop:

#figure(
  code(
    lang: "Python",
```py
def run_loop(
    model_configurations: List[ModelConfiguration],
    dataset: Dataset,
    model_configuration_finished_cb: Callable[[ModelConfiguration], None],
    item_cb: Callable[[ModelConfiguration, Dict[str, Any]], None],
):
    for model_configuration in tqdm(model_configurations):
        tqdm.write(f"Running for {model_configuration.name}")
        for item in tqdm(dataset.items):
            item_cb(model_configuration, item)
        model_configuration_finished_cb(model_configuration)
```
  ), caption: [The general evaluation loop, which combines several each model configuration with a dataset task.]
)<code:dataset:loop>

The loop combines every model configuration with every dataset task.
The progress is displayed using the `tqdm` dependency, which provides an estimate of the remaining run time, as seen in @terminal:tqdm:
#figure(
  terminal(```terminal
76%|████████████████████████        | 1/4 [00:33<00:10, 229.00it/s]
76%|████████████████████████        | 7568/22 [00:33<00:10, 229.00it/s]
```),
caption: todo[Sample output]
)<terminal:tqdm>

The passed item callback is called for every different combination. By abstracting the content of the item callback, several scenarios are possible, such as only running the neural code completion, evaluation, or both.
After the whole dataset for a single model configuration was processed, the model configuration finished callback is called, running any finishing task, such as saving the results for the configuration.

=== Robust Neural Code Completion
The completion is located in `dependency_eval/generate.py`. It requires a project directory with a virtual environment, in which all dependencies are installed.
// In venv section

The code for the passed task is built, excluding the gold solution and then written to the file `code.py` in the project directory.
In addition, a `LSPGenerationConfig` object is created and serialized into #acr("JSON").
Depending on if the code should be completed using the approach or not, the field `enabled` is toggled.
Then a subprocess runs the Python binary of the project virtual environment, calling the file `dependency_eval/eval_prompt.py` and passing the `LSPGenerationConfig`, the name of the model and the path to the `code.py` file as arguments.
This trick enables running the neural code completion inside the exact environment as defined in the dataset. This ensures that only these dependencies are found and used, without contamination by the evaluation pipeline dependencies.
#footnote[The language server might be able to find the virtual environment, based on the passed code file alone. But the custom logic to determine if a symbol is deprecated uses `importlib`, reusing the dependencies available in the currently running Python instance.]

Similar to before, `eval_prompt.py` suppressed the standard output, as it prints the completed code into the standard output.

Isolating the generation from the evaluation pipeline process increases the robustness, which is vital as the pipeline may run for several hours. Ff the generation should fail due to out of memory issues, issues in the communication with the language server or other places, the evaluation pipeline can resume.

=== Code Evaluation Sandbox
To securely evaluate foreign code, a special evaluation sandbox is created using Docker.
The implementation currently only uses plain Docker. As Docker is a containerization tool, it is a vast improvement over the reliability guard of e.g. `HumanEval+`. But improvements can still be made by adding a tool such as #link("https://github.com/google/gvisor"), to further secure the kernel.

#acr("IPC") with the evaluation sandbox again relies on sending #acr("JSON") serialized messages over the standard output stream. 

=== Test Metric Calculation

=== Virtual Environment Management

=== Main
#todo[Somehow main]