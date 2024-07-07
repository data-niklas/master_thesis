#import "/utils.typ": *
== Dataset Design<chapter:design:dataset>
Evaluation of the approach described in @chapter:design:lsp requires a fitting dataset.
This section will first list the requirements for such a dataset, then shortly analyze why current datasets do not fit these requirements.
Lastly, it will propose a hand-crafted dataset that fits the requirements.

=== Requirements

The exact requirements are listed in @table:dataset:requirements.
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
=== Analysis
// HumanEval
@chenEvaluatingLargeLanguage2021
- only prompt, solution, test with index
- no dependencies
- only general programming problems

@liuYourCodeGenerated evalplus

@duClassEvalManuallyCraftedBenchmark2023 ClassEval
- includes complex problems, such as working on classes
- captures import statements, but does not have the exact needed version
- mostly only builtin dependencies or self-dependency

=== DependencyEval
Each entry in the dataset shall have the following format:
#figure(
  code(
    lang: "JSON",
    ```json
    {
    	"task_id": "PackageEval_{int}",
    	"task_name": "{string}_{int}",
    	"test_code": "{string}",
    	"import_statements": ["{string}"],
    	"package_dependencies": ["{string}"],
    	"context": "{string}",
    	"function_signature": "{string}",
    	"function_documentation": "{string}",
    	"entry_point": "{string}",
    	"solution": "{string}",
    	"reason": "{string}",
    	"kind": "{kind}",
    	"date": "%Y-%m-%d",
    	"code_kind": "{code_kind}",
    	"modification_kind": "{modification_kind}",
    	"changelog": "{url}"
    }
    ```,
  ),
  caption: "Dataset format",
)<code:dataset>
// TODO: explain attributes

Kind:
- modification: recently changed
- uncommon: rarely used

Code kind:
- field
- parameter
- function
- method
- block

Modification kind:
- addition
- removal
- deprecation
- renaming
#todo()[rename renaming to rename]

// Test approach
// Test method
