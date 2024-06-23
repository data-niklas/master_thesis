#import "/utils.typ": *
== Code Completion <bg_code_generation>
// TODO: sub headings
// What is it generally?
Code completion is a task in the domain of code generation. Generally, code generation predicts code or program structure from multimodal data sources@leDeepLearningSource2021. These sources include incomplete code, programs in other programming languages, natural language descriptions, or execution examples@leDeepLearningSource2021. Code generation is a vast field with many applications, from generating tests, to debugging code, to completing code.

// What is code completion
Code completion predicts code of an incomplete code snippet. While the incomplete code snippet is the main data source, other secondary multimodal data sources can be used. The main use is for integration in #acrpl("IDE").

// Generated code = full code
// completed code = only code withouth the input

// Differences to normal generation
In contrast to normal generation, code completion can leverage many properties specific to code.
The first main property is the syntax of the programming language of the to be completed code. The syntax of the full generated code must be valid according to the grammar of the programming language.
The second main property is the semantics of the generated code. The generated code must be semantically correct. The code should execute without errors, such as using incorrect functions, methods, function parameters and types.
Available documentation is the third property. Often code is documented to improve maintainability.

// Validation
// Syntax
// Semantics
// -testing is a part of semantic
// Documentation
// Testing

All three properties can be used as additionaly data sources for code completion.

As the code completion is intended for use in #acrpl("IDE"), the following requirements are important:
- The generated code should be syntactically correct.
- The generated code should be semantically correct.
- To increase maintainability, the generated code should follow best practices. // TODO: elaborate
- The developer might be working on a single file or a large project. For large projects, the generated code should be aware of the local code base.
- The developer could work on a project of *any* programming language.
- Knowledge about related code:
The #acr("CLM") performing the task should take the following context into consideration when generating code: At the core, the #acr("CLM") has the context of the local file that is edited. The next wider context is code in a local repository, when working on a larger project. At last, the model should use knowledge of installed packages.

=== Problems
Current code generation models and strategies are capable of the following:
- Generating syntactically correct code.
- Generating semantically correct code.
- Generating code for any programming language.

Current techniques still struggle generating code that is aware of the local code base.

Requirements, which current techniques do not fulfill are topics, such as following best practices and having knowledge about related code.

