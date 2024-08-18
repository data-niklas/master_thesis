#import "/utils.typ": *

== Dataset Research Questions <chapter:experiments:dataset>
After evaluating the approach using the dataset, the dataset itself is evaluated, answering the research questions posed in the following sections.
As before, the research questions are directly derived from the requirements in @table:dataset:requirements.
For the evaluation, the DependencyEval code will be analyzed to determine if the requirements are met.
Additionally, statistics of the tasks will be collected to answer the research questions.

=== General Requirements
While @table:dataset:requirements introduces special requirements towards DependencyEval, the dataset should still follow general requirements towards datasets.

=== Captures exact environment
The first requirement is for DependencyEval to capture the exact environment of the tasks.

==== RQ#sub[dataset]1: Which parts of the environment are captured?
// pip install order PipInstallPip, system dependencies, etc, environment variables, etc.

=== Test functional and approach correctness

==== RQ#sub[dataset]2: How many tasks are correctly evaluated?

=== Include examples of deprecated code

// Are there examples for each different scenario:
//

=== Secure evaluation pipeline
// Sandboxing
// against which cases does the security pipeline protect
// limitations of security pipeline

/*
    alternative:
    do not list per requirement, but list total
    many requirements are booleans, eithre therer or not, and they are there
    so, ask targeted questions towards dataset attributes

*/
