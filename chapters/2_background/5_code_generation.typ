#import "/utils.typ": *
== Code Completion <chapter:bg:code_generation>
// TODO: sub headings

=== Special Properties

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

=== Requirements
As the code completion is intended for use in #acrpl("IDE"), the following requirements are important:
- The generated code should be syntactically correct.
- The generated code should be semantically correct.
- To increase maintainability, the generated code should follow best practices. // TODO: elaborate
- The developer might be working on a single file or a large project. For large projects, the generated code should be aware of the local code base.
- The developer could work on a project of *any* programming language.
- Knowledge about related code:
The #acr("CLM") performing the task should take the following context into consideration when generating code: At the core, the #acr("CLM") has the context of the local file that is edited. The next wider context is code in a local repository, when working on a larger project. At last, the model should use knowledge of installed packages.

=== Problems
Fulfilling all requirements using #acrpl("CLM") is hard. By solving the following problems, the requirements can be met:
1. Finding relevant context
2. Injecting context into generation process
3. Supporting most programming languages

The problems are discussed in the following sections.

=== Finding relevant context
Each #acr("CLM") has ingrained knowledge about the data it was trained on. #acrpl("CLM") trained on code have limited knowledge about the language itself, the standard library and other dependencies. // E.g. PyTorch
The problem with the inbuilt knowledge is that it is insufficient or outdated, especially for large projects with many dependencies. In addition, the knowledge only reaches until the cut-off date of the training data and does not include changes afterwards. In contrast, working on legacy projects poses the same problem, as the knowledge the model was trained on is too new.

The conclusion is that a framework must find all needed information and supply it to the #acr("CLM") - the "context". The following attributes are of importance:
1. *Scope*: The context should include information about the local file, repository and installed packages.
2. *Precision*: The context should not "drown" the model in information, but still provide all relevant information as compact as possible.
3. *Up-to-date*: The provided information on dependencies should be up-to-date with the version of the dependencies used in the local repository.

=== Injecting context into generation process
The next step in a framework is to inject the collected context into the generation process of a #acr("CLM"). As seen in previous sections, many different approaches are possible and can be combined.

=== Supporting most programming languages
Finally, the framework should support most programming languages. This is crucial for the framework to be used in a wide range of projects. As each programming language has different syntax, semantic and package management, this problem is especially hard.
