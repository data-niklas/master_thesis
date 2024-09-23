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

=== Data Collection
While the previous sections detail the evaluation pipeline, this section briefly details the data collection process.
The process consists of `crawling`, `filtering`, `scenario extraction` and `scenario validation`.

In the first step `crawling`, possible Python dependencies are searched for manually, either by searching through #acr("PyPI"), by browsing the web, asking colleagues or through any other means.
As this is a manual process, it is inefficient, different sources provide duplicates.

While crawling and afterward, the dependencies are filtered after different criteria.
Each dependency must not have too many tasks present in the dataset yet. Currently, the highest amount of tasks per dependency is $3$ (pydantic). In this case pydantic would be filtered in favor of other dependencies.
Additionally, the dependency must have some form of changelog, which can be used to determine potential scenarios, such as deprecation etc.
Usually the dependency has a Git repository, which includes some form of changelog file in the root directory (`CHANGELOG`, `CHANGELOG.md`, `NEWS`, `HISTORY`, etc.).
Alternatively, the changelog can often be found in the GitHub releases tab. Popular dependencies also have a changelog on their website.
Another criteria is how well the approach correctness and functional correctness of scenarios can be tested. Crafting scenarios for some dependencies is hard, such as game engines.
In the filtering process, algorithmic libraries are preferred to such dependencies, as they are easier to test.

Then, the changelog is skimmed for potential scenarios, while the previous criteria are kept in mind. If a plausible scenario is found, a task is created, including the approach and functional correctness tests.
At last, the functional tests are run to validate the gold solution.

The manual collection process is time-consuming and increases per found scenario, as it is difficult to find dependencies which match all criteria.
E.g. the time spent on finding a suitable 22#super[nd] task took \~$30$-$60$ minutes, while the first three tasks took \~$10$-$20$ minutes each.

=== Dependencies
To achieve the listed functionality, DependencyEval relies on several dependencies:
The two main dependencies are `click` and `virtualenv-clone`.
`click` helps in creating #acr("CLI") applications, as it allows to create such applications declaratively.
In addition, it automatically creates a help page of the commands and subcommands.
`virtualenv-clone` is another fundamental package in enabling reproducable and fast workflows, as it can duplicate a Python virtual environment. It is used to duplicate a virtual environment from a cache into a working directory.
Other dependencies are `openpyxl` to export stats into Excel sheets, `matplotlib` to create beautiful charts and `sankeyflow` to create Sankey diagrams of the results without and with the approach.
`textual` is used to display results interactively in a table, while the dependency `tqdm` is used to display progress bars for long evaluation runs. `pygount` counts lines of code and enables dependency analysis of dataset dependencies.
All other features use the standard library for operations like working with files and processes.

=== Structure
#figure(
  codefile("/assets/code/dependency_eval_structure.terminal"),
  caption: [Directory structure of the `dependency_eval` repository.],
)<terminal:dependency_eval:structure>

The structure of the repository is fourfold.
The `data` directory contains all information to build the distributable dataset, which is then located in `data/dist`.
The evaluation results of the dataset are stored in `evaluations`, such that they are persisted in Git.
The Python package `dependency_eval` can be executed with Python, which runs the file `__main__.py` and serves the functionality through the #acr("CLI") program.
The evaluations use different model configurations, which are stored in `model_configurations`.
Similar to how model are evaluated with different configurations, the approach is evaluated with different configurations, which are stored in `lsp_generation_configurations`.

=== Dataset Distribution
The distributable dataset is a `.jsonl` file, where each row is a #acr("JSON") dictionary with the schema as introduced in @code:dataset:format.
While the compact `.jsonl` dataset file is easily distributed and machine-readable, it is hard to read for a human.
Thus, the basis for the dataset is an easily human-readable form, which simplifies extending the dataset by a human (which is necessary, as the dataset is curated manually).
One base is the `data/tasks` directory, which includes a single code file for each task. The code files are named after the task and include the whole code, including the gold solution.

#figure(
  codefile("/assets/code/dataset/textual_1.py"),
  caption: [The contents of the `data/tasks/textual_1.py` file, which is used to create the task `textual_1` in the DependencyEval dataset. The file is split to obtain the imports, additional context, the function definition, function documentation string and gold standard completion.],
)<code:dataset:textual_1>

As described in the design section, the fields in @prompt:dataset:fields are combined to form the whole code with or without completion, depending on the use case.
Using the reverse process, a file such as @code:dataset:textual_1 is split into the different components to form a dataset entry.
This is possible, as every single file adheres to the same regular format.

For evaluation, the different unit tests are also stored in their own code files, in `data/tests`.
To keep the tests as simple to run as possible, they do not rely on external test runners and reuse the Python unit test framework.

#figure(
  codefile("/assets/code/textual_1_tests.py"),
  caption: [The unit tests for the `textual_1` task. The contents are stored in `data/tests/textual_1.py`. Next to the tested dependency, only the built-in unit test framework is used. The results are communicated via standard streams.],
)<code:dataset:textual_1_tests>

The unit tests for the `textual_1` task can be found in @code:dataset:textual_1_tests.
The test file contains both a test for the functional correctness and approach correctness.

The final piece needed to form the distributable dataset is the additional metadata associated with each entry.
While the metadata could have been embedded in the code directly, e.g. as a Python comment at the top of `data/tasks/textual_1.py`, a separate metadata file such as `data/metadata.json` simplifies the parsing process and reduces format driven errors.
`metadata.json` does not use any special format. It contains a list for dictionaries, where each dictionary contains additional metadata in the same schema as the final dataset, including a field `task_name`. The task name is the same task name used for the code file, unit test file and helps associate the different information.

When distributing the dataset, these three information sources are combined to form the different task entries. This has both the benefit of an easy-to-extend dataset for humans, while enabling easy distribution and use by machines.

=== Unit Tests
As introduced in the design section and quickly described in the last section, each entry requires two test cases.
The first test case tests the functional correctness, while the second test tests the approach correctness.

The tests are implemented as standard Python unit tests. This simplifies the testing as the built-in unit test framework can be reused through the `unittest` package.
The test setup requires three components to fit together:
1. Starting the unit tests from the running Python code and
2. disabling logging to access and log the test results, while
3. mocking used objects to introspect the used approach.

Typically, unit tests are either run through the command line using the unit test module, or by running the Python script directly and calling the function `unittest.main`.
#exampletext(caption: "Typical execution of Python unit tests through the command line.")[
  ```bash
  python -m unittest path/to/file.py
  ```
]
In either case, all defined unit tests are found and executed, after which the result is printed to the standard output. The result looks similar to @terminal:unittest:
#figure(
  codefile("/assets/code/unit_test_output.terminal"),
  caption: [Typical console output when executing two Python unit tests. Parsing the output is error prone and unneeded, as the results can be accessed directly.],
)<terminal:unittest>

The script accesses the test results directly through the `results` field, which contains the number of failures, tests with errors and the total number of tests run.
The list of errors, failures, and total tests is serialized using the #acr("JSON") format and sent to the controlling process through standard output.
This simplifies the parsing process and easily yields the desired information and is extensible if more information is needed.
// IPC

As this approach relies on standard output for #acr("IPC"), all other output must be suppressed, as it complicates the parsing of the results in the controlling process.
Printing of the unit test results is suppressed by setting the test log verbosity to $0$ and redirecting the output of the test runner to the `/dev/null` stream, effectively voiding the output.

Other output is suppressed, by setting the logging level of the logger to critical.

// Approach correctness
Each unit test is carefully crafted, by mocking the objects of the gold solution and of probable deprecated functions.
Tests can then be failed directly, if the deprecated function is used instead of the gold solution. Even if the gold solution function is used, the passed parameters can be introspected, enabling complex test scenarios. Each test scenarios test certain properties.
For the scenario in @code:dataset:textual_1_tests the tests assert that the parameter `tab_behavior` is used, while `tab_behaviour` is incorrect, as it is deprecated.

=== Evaluation Loop
At the heart of the evaluation pipeline lies the evaluation loop, which is located in `dependency_eval/loop.py`. It is abstractly defined in @code:dataset:loop:

#figure(
  codefile("/assets/code/loop.py"),
  caption: [The general evaluation loop, which combines several each model configuration with a dataset task.],
)<code:dataset:loop>

The loop combines every model configuration with every dataset task.
The progress is displayed using the `tqdm` dependency, which provides an estimate of the remaining run time, as seen in @terminal:tqdm:
#figure(
  codefile("/assets/code/tqdm.terminal"),
  caption: [Sample output of the running evaluation. The first progress bar displays the progress in evaluation whole model configurations. The lower progress bar shows the progress of a single model configuration, showing the progress in evaluation a single task.],
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

Isolating the generation from the evaluation pipeline process increases the robustness, which is vital as the pipeline may run for several hours. If the generation should fail due to out of memory issues, issues in the communication with the language server or other places, the evaluation pipeline can resume.

=== Code Evaluation Sandbox
To securely evaluate foreign code, a special evaluation sandbox is created using Docker.
The implementation currently only uses plain Docker. As Docker is a containerization tool, it is a vast improvement over the reliability guard of e.g. `HumanEval+`. But improvements can still be made by adding a tool such as #link("https://github.com/google/gvisor"), to further secure the kernel.

#acr("IPC") with the evaluation sandbox again relies on sending #acr("JSON") serialized messages over the standard output stream.
Similar to running the code completion, the evaluation starts a subprocess, passes all arguments and handles errors. Finally, all dangling resources are removed.

The Docker container is started with the following arguments seen in @code:evaluation:docker.

#figure(
  codefile("/assets/code/docker_run.py"),
  caption: [Arguments to Docker run, which starts the evaluation in a Docker container. Note that Git is installed to support installing dependencies from Git repositories.],
)<code:evaluation:docker>

The Docker container image is an official Python image, where the Python version is set from the task.
Ultimately, this creates the specific environment needed for the task. The Python package dependencies are installed inside the container, before running the evaluation.
The code to evaluate is mounted into the container, next to the requirements file.
The compute is limited to a single CPU.

Docker supports a filesystem size limit using the `--storage-opt` flag, which could be used to limit the size of the filesystem. In practice, this requires support by the Docker storage driver, of which filesystems like `btrfs` and `zfs` are favoured @DockerRunDocker.
This implementation does not limit the filesystem size for compatibility reasons.

The container execution time is limited to two minutes, which is enough time to install larger dependencies, such as PyTorch.
After the two minutes have elapsed, the container is forcefully removed if it still runs.
To reference the container, it is given the name `dev_dataset_eval_item_`, followed by a salt.
The salt is unique to the run and obtained by taking the first 8 characters of a random UUID4:
#figure(
  codefile("/assets/code/salt.py"),
  caption: [The salt is a unique identifier appended to any name used during the evaluation.],
)<code:evaluation:salt>
This allows for multiple evaluations to run in parallel, without interfering with each other.

=== Virtual Environment Management
Running the neural code completion requires a whole Python virtual environment per task, as each task has its own pinned dependencies, the project environment.
As creating each environment may take up to several minutes when installing larger dependencies, the environments are cached and reused.

#figure(
  codefile("/assets/code/optimized_venv_cache_size.terminal"),
  caption: [Space used by the virtual environments in the cache. Results obtained using `ncdu`. Each directory is a Python virtual environment containing specific dependencies of a task.],
)<terminal:venv_cache>

The dependencies are first sorted, then hashed using SHA256, to further enable reuse between tasks.
The hash is used as a name for the virtual environment.
If the environment does not exist yet, it is created using the `venv` package.
Instead of the typical #acr("CLI") use, the following Python functions are used, as seen in @code:dataset:venv_creation:

#figure(
  codefile("/assets/code/venv_cache.py"),
  caption: [Creating a virtual environment programmatically in Python.],
)<code:dataset:venv_creation>

The `EnvBuilder` in @code:dataset:venv_creation creates the base environment without further dependencies. After manually installing `packaging` and `wheel`, the remaining dependencies can be installed using a regular `pip install`, using the Python installation of the virtual environment.

If the virtual environment exists yet, it is cloned into the code directory, such that the neural code completion can find the environment.
As virtual environments contain links, copying is non-trivial and involves more than copying the directory.
Thus, the dependency `clonevirtualenv` is used to clone the cached environment.

The environments may be prepopulated once before evaluation, by running the subcommand `create_venvs`.

Using the same approach the runtime environment is created once, before the evaluation starts. Only the approach is installed into the runtime environment.

=== Main
The main file has the following structure, as seen in @code:dataset:main:

#figure(
  codefile("/assets/code/main.py"),
  caption: [Structure of the DependencyEval main file, which includes the #acr("CLI") commands.],
)<code:dataset:main>

The #acr("CLI") is defined through the `click` dependency and invoked by calling the `cli` function.
By using the function decorator `click.group`, the general #acr("CLI") is defined, with the given version `VERSION`. It automatically detects the package name and sets it as the program name.

Subcommands are registered, by using the `cli.command` decorator on single functions, where each function then represents a single subcommand.
Single arguments are defined through the `click.option` decorator.

The `create_venvs` function defined in @code:dataset:main defines a subcommand with the same name, taking three arguments, of which two have a default value.
All uppercase variables are constants either defined in `dependnecy_eval/constants.py`, or in other parts of the file.

