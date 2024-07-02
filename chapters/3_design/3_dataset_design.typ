#import "/utils.typ": *
== Dataset design<chapter:design:dataset>
Finally, the dataset design is critical for the evaluation of the method.

// Important attributes
The most important attributes of the dataset are a pinned environment with known dependencies, a gold standard solution and unit tests which test for functional and approach correctness.

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

// Test approach
// Test method
