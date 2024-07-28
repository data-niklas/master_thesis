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