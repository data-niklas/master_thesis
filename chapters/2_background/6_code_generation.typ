#import "/utils.typ": *
== Code Generation <bg_code_generation>
Code generation is a task in the general domain of text generation. It refers to the generation of any type of source code. This section will first introduce several important applications for code generation. Then it will list several problems common to specifically code generation. At last general approaches to improve code generation are shown.

=== Uses
This section will introduce three common use cases, which slightly differ in their requirements. Common requirements are the following:
- The generated code should be syntactically correct.
- The generated code should be semantically correct.
- To increase maintainability, the generated code should follow best practices.
- The developer might be working on a single file or a large project.
- The developer could work on a project of *any* programming language.
- Knowledge about related code:
The #acr("CLM") performing the task should take the following context into consideration when generating code: At the core, the #acr("CLM") has the context of the local file that is edited. The next wider context is code in a local repository, when working on a larger project. At last, the model should use knowledge of installed packages.

The first use case is *code completion* for use in #acrpl("IDE"). In this scenario, a developer will have installed tooling to run autocomplete in parallel to his typing. To display the autocompletion before the developer continues writing, the code must be generated in a timely fashion.

The second use case is for generation of *unit tests*. This scenario differs in the size of the generated code. Generated unit tests generally are larger than code generated as inline code completion.
Additionally, the generated code // TODO: needs other function to test
// TODO: his / her
// TODO: image of onion: the center is the local file, around is the local repository, around are foreign code pieces / repositories

The last use case is for prototyping, in which a single or several files are generated. The difference to other use cases is the increased runtime. Moreover, the code is generated from a task the developer provided.

// TODO: rename developer to user?

=== Problems
Current code generation models and strategies are capable of the following:
- Generating syntactically correct code.
- Generating semantically correct code.
- Generating code for any programming language.

Current techniques still struggle generating code, which is aware of the local code base.

Requirements, which current techniques do not fulfill are topics, such as following best practices and having knowledge about related code.

=== General approaches
// iterative process to add information needed
