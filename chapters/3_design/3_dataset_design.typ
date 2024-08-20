#import "/utils.typ": *
== Dataset<chapter:design:dataset>
Evaluation of the approach described in @chapter:design:lsp requires a fitting dataset. This section will first list the
requirements for such a dataset, then shortly analyze why current datasets do not fit these requirements. Lastly, it
will propose the hand-crafted dataset `DependencyEval` that fits the requirements.

=== Requirements
In general, such a dataset requires a set of code snippets that can be used as input to the approach, as well as a
ground truth for comparison. Moreover, it needs test cases to run the comparison and an evaluation pipeline to run a
full evaluation securely and collect metrics.

As the work in this thesis focuses on exact use of dependencies, it has further requirements towards a dataset. The
exact requirements are listed in @table:dataset:requirements.
#figure(
  table(
    columns: 2,
    table.header([Identifier], [Keyword]),
    [*R#sub[dataset]1*],
    [Captures exact environment],
    [*R#sub[dataset]2*],
    [Test functional and approach correctness],
    [*R#sub[dataset]3*],
    [Include examples of deprecated code],
    [*R#sub[dataset]4*],
    [Secure evaluation pipeline],
  ),
  caption: [Special requirements of the dataset],
)<table:dataset:requirements>

==== Captures exact environment.<rdataset:1>
The first requirement is that each entry in the dataset lists all details that constitute the environment in which the
code is executed. In a broader sense, this requirement starts with the exact version of the interpreter / compiler used
to run the provided code. Then, the used dependencies need to be pinned to a specific version. Standard library packages
often do not need to be pinned, as they are part of the language runtime and share the same version. In contrast, all
external dependencies need to be specified.

Only specifying the dependencies is not enough, as this enables the reproduction of the environment but does not
guarantee that it is usable. To ensure that the then available dependencies can be used, the import statements are
required.

==== Test functional and approach correctness.<rdataset:2>
The second requirement is for the dataset to contain at least two types of tests. The first type is used to test the
functional correctness of any given code snippet. This test is the most basic test and comparable to a regular unit test
checking the output of a function.

The second type of test is used to check if the approach used in the code snippet is correct. This test will be the
focus of the evaluation as it specifically checks if the code snippet e.g. uses deprecated code or uses the correct
alternative instead.

Both tests can be run in conjuction to count the number of failed tests, completed tests and tests with errors. This
will allow observing the behavior of different changes in the implementation to the used approach, while asserting that
the functional correctness is kept.

==== Include examples of deprecated code.<rdataset:3>
The third requirement is pertaining to the type of collected code snippets. To evaluate #acrpl("CLM") correctly using
dependencies, the dataset requires examples of changing dependencies.

As noted in #r(1), there are three scenarios for dependency changes:
1. A feature is added to a dependency
2. An old deprecated feature is removed or changed in a dependency
3. A feature is removed in a dependency

In addition, the included examples should cover the following other scenarios listed in #r(1):
4. A widely unknown dependency is used
5. A dependency with a widely unknown feature is used

The last two scenarios cover the case that the number of examples of the dependency or the specific feature in the
training dataset of a #acr("CLM") are too low to be learned correctly.

==== Secure evaluation pipeline.<rdataset:4>
As stated above, each dataset requires an evaluation pipeline to automatically run the different tests and collect the
results. The base assumption is that the pipeline is robust under any circumstances and can stably run unsupervised for
many hours. In addition, the pipeline will test arbitrary generated untrusted code snippets. This requires a secure
environment to run in.

The secure environment must be able to restrict the amount of compute available to the pipeline, as well as other
resources like memory and disk space. To terminate the pipeline in a more predictable time frame, the pipeline should
terminate test runs taking too long, to prevent infinite loops or other problems.

While adhering to the security requirements, the pipeline needs to be able to create the exact environment for each code
snippet, as described in #rdataset(1).

=== Analysis
Several widely used datasets for code generation exist, such as `MBPP`, `HumanEval`, and `ClassEval`. The following will
analyze these datasets towards the above requirements and note important findings.

==== MBPP.
#acr("MBPP") contains, as the name implies, mostly simple Python code snippets. It has around 1000 rows of data, each
containing a problem statement, a working code solution and test cases to check the functional
correctness@austinProgramSynthesisLarge2021b.

It does not specify the exact environment in which the code is executed, nor does it need to, as it only contains simple
Python code snippets that can be run in any modern Python environment. The only dependencies are $9$ different Python
packages included in the standard library. As the dataset is most basic, it is not focused towards the requirements of
this thesis.

Neither does it contain tests for the approach correctness, nor does it contain examples for the listed scenarios in #rdataset(3),
nor does it contain a secure execution environment.

==== HumanEval.
`HumanEval` is a dataset going slightly beyond #acr("MBPP") in complexity. It contains 164 handwritten Python
programming problems for code completion. Each programming problem has the scope of a single function and includes the
function head with the docstring, the solution and test cases for the functional correctness. The solution is the
completion of the function head and docstring and they can be combined together to form the complete
function@chenEvaluatingLargeLanguage2021.

Similar to #acr("MBPP"), `HumanEval` lacks the same requirements. It only imports 8 packages, all of which are part of
the standard library. In contrast, `HumanEval` contains a evaluation pipeline, but it only secures the execution
rudimentarily, through the addition of a reliability guard.

The reliability guard wraps the to be executed Python code and removes functionality of the programming language
environment that could be used to perform unwanted actions. As the securing does not happen on a system level, it only
serves as a quick fix unsuited to rigorous evaluation.

Next to #acr("MBPP") and `HumanEval`, the dataset `EvalPlus` has recently gained popularity, as it contains a more
rigorous evaluation framework and includes `MBPP+` and `HumanEval+`, which extend the aforementioned datasets with
further tests. It lacks the exact same issues, as it only uses a reliability guard for execution and the fundamental
data for testing is similar@liuYourCodeGenerated.

==== ClassEval.
`ClassEval` is the first dataset containing Python tests at the class-eval. It contains 100 tasks, each with a class and
about 33.1 test cases per class. In contrast to previous datasets, `ClassEval` explicitly mentions the use of different
types of dependencies. Most dependencies are to different parts of the class itself, but some are to external "Library
Dependencies". Of the 100 tasks, only 49% use imports, of which 13% use 6 different external dependencies. Even though
the dataset contains external dependencies, it does not specify the exact version of the dependencies used, or the
version of the Python interpreter. Also the tests only test the functional
correctness@duClassEvalManuallyCraftedBenchmark2023.

A benefit of `ClassEval` is the fine-grained separation of the provided code snippets. Import statement, code skeletons,
class information, test cases and solution are all provided separately and can easily be combined for testing.

==== Conclusion.
None of the datasets analyzed above fit the requirements of this thesis. Almost no datasets contain external
dependencies, while none specify the exact environment. In addition, the only security measue in place is a rudimentary
reliability guard, which is not enough to secure the execution of arbitrary code snippets. There is a need for a new
dataset that fits the above requirements.

=== DependencyEval
To fulfill the above requirements, the dataset `DependencyEval` is proposed. It contains fine-grained information about
the code snippets, including the exact environment, the used dependencies, the import statements, the code skeleton, the
test cases and the solution. In addition, it contains a secure evaluation pipeline that can run the tests and collect
the results reliably. This section will first introduce the structure of each entry in the dataset, followed by how the
data was obtained and lastly the design of the evaluation pipeline. The samples are hand crafted to test changes in
specific Python dependencies.

==== Structure.
Each entry in the dataset shall have the following format described in @code:dataset:format.
As is usual, each entry contains a unique identifier `task_id`. Each entry represents a single task, targeting a single
external dependency. The `task_name` is a name of the task containing the name of the targeted dependency and the index
of the task for that dependency, 1-indexed, such as `pytorch_1`.

The following fields are combined to form the full solution:
#figure(
  prompt()[
    {`import_statements`}\
    \
    {`context`}\
    \
    {`function_signature`}\
    {`function_documentation`}\
    {`solution`}
  ],
  caption: "Combination of fields to form the full solution in DependencyEval",
)<prompt:dataset:fields>

The `import_statements` contains a list of import statements to be performed at the start of the code snippet. The
`context` field contains additional definitions of classes, functions or variables that are required for the code
snippet to run. The remaining three fields form the function body. By combining the fields without the `solution`, the
code snippet can be used as input to a neural code completion model, to compare against the gold standard solution.
Each `docstring` is a Python docstring in the Google docstring format@Styleguide, which was chosen over the many other
docstring formats, such as ReST@PEP287ReStructuredText, as it is widely used and has a compact layout.
// other are sphinx and numpy style
// no reference for widely used

// Maybe mention the format name==major.minor.patch
To reproduce the exact environment, the `package_dependencies` field contains a list of all external dependencies used
in the code snippet, pinned to a specific version. As this dataset is geared towards Python, the `python_version` field
contains the version of the Python interpreter used to run the code snippet. This prevents any issues with dependencies
needing a specific version of Python and else failing.

The field `test_code` contains the full test cases for the functional and approach correctness. It leverages the builtin
`unittest` module for defining the test cases@UnittestUnitTesting. To run the full unit tests, the generated above code
is prepended to the `test_code` field.

Further fields are for transparency and interpretation of the results. They contain additional information on the name
of the function to be executed (`entry_point`), why, when and where the code snippet was sourced. The `date` field
contains the date the dependency was modified, enabling e.g. quick analysis of if the code snippet could be contained in
a training dataset. `changelog` is a direct link to the changelog of the dependency, detailing the change made. The "why"
is stored in the `reason` field, detailing why the dependency and feature was used. This is one of:
- `modification`: The dependency was recently changed
- `uncommon`: The dependency is rarely used and most likely unknown to a model

The `kind` field contains the code kind targeted by the task, such as a changed `field`, `parameter`, `function`,
`method` or `block`. The exact type of modification is stored in the `modification_kind` field, such as `addition`,
`removal`, `deprecation` or `rename`, where `rename` encompasses all types of changes in which the functionality has
moved to a different section of the dependency.

==== Data sourcing.
The data is obtained by searching for public Python dependencies on the #acr("PyPI")@PyPIPythonPackage that have a
changelog. Repositories are then selected based on the different mentioned scenarios. Additionally only the repositories
are kept, for which test cases can easily be written and executed, removing dependencies requiring a complex setup to
use the changed functionality.

Currently, the dataset contains #num-dataset entries for 16 different dependencies:
#{
  show figure: set block(breakable: true)
  figure(
    box(
      columns(2, csvtable("/assets/tables/dataset_dependencies.csv")),
      height: 150pt,
    ),
    caption: "Dependencies in DependencyEval",
  )
}<table:dataset:dependencies>

The following two examples serve as important test cases for the evaluation of neural code completion:

#figure(
  codefile("/assets/code/dataset/pydantic_1.py"),
  caption: "Example code snippet for Pydantic showing the correct completion",
)<code:dataset:pydantic>
@code:dataset:pydantic targets the major change from `Pydantic` version `1.x.x` to `2.x.x`, renaming a few core
methods@SerializationPydantic. `Pydantic` is a data validation library for Python, capable of converting complex data
types to and from Python dictionaries. To converte a `Pydantic` model to a dictionary, previously the method `dict`
would be called. This was renamed to `model_dump`. The previous method is still available and marked as deprecated. As
the library is widely used and the change in April 2023, lots of publicly available code snippets contain the old
method. In addition, the standard library method `dict` is used similarly, making it hard to distinguish between
the two.

#todo()[Example copilot]
// Consequently, all #acrpl("CLM") tested using this code entry could not complete the correct method, but instead are biased towards the method `dict`.
// Even when specifying the name of the correct method, some #acrpl("")
#todo()[Mention in evaluation that all LLMs cannot complete the pydantic example previously, cause biased]

#figure(
  codefile("/assets/code/dataset/textual_1.py"),
  caption: "Example code snippet for Textual showing the correct completion",
)<code:dataset:textual>
While the previous example targets the dereferencing of a method, the example @code:dataset:textual targets the
signature of a function. The parameter `tab_behaviour` was renamed to `tab_behavior` in the widely used library
`Textual` in Februar 2024@TextualHome. As the change occurred recently, we assume and later evaluate that most #acrpl("CLM") were
trained on older versions and do not complete the correct parameter.

Both examples serve as core test cases for the different included information sources, such as completion items and
signature help.

==== Evaluation pipeline.
// can create a virtual Python environment for neural code completion
// code completion and evaluation separate
// evaluation runs in a docker container
// docker container is limited and based off a Python base image
// dependencies installed in docker container

// takes the dataset, a list of models and a list of configurations for the models

// For each combination: Create code with and without method, then run tests for each generated code

The evaluation pipeline takes a version of the dataset, a list of models and a list of hyperparameters for the models as
input. For each different combination, the pipeline runs the approach described in @chapter:design:lsp on the code
snippets in the format described in @prompt:dataset:fields (without the `solution` field). Additionally, it runs a
neural code completion without the approach, to serve as a baseline. Before running the code completion, the pipeline
must first create a virtual Python environment (venv) in which all of the dependencies for the task are installed in.
The code completion occurs inside the venv, such that the approach has access to dependency information.

Afterwards, the generated code snippets are evaluated inside `Docker` containers and the results transmitted back to the
pipeline via the standard output. `Docker` is a containerization platform that allows for the isolation of processes and
the restriction of resources. Through the use of `Docker`, the pipeline can restrict access to resources, such as the
number of CPUs@DockerRunDocker.

To ensure that the pipeline is robust, all calls to the containerized evaluation or neural code completion are wrapped
in a timeout and errors are caught and logged.
