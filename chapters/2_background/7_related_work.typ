#import "/utils.typ": *
== Related Work <bg_related_work>
// Not many related work has focused on enhancing code completion specifically
// No solution that works for large codebases, with up-to-date code for any language and precision to provide high quality context
Not many related work has focused on enhancing code completion specifically. The few works that enhance code completion fail to solve all three problems introduced in @bg_code_generation. Other work introduces general techniques to improve #acr("CLM") generation for complex tasks, but does not apply such techniques on code completion.

// Monitor guided generation
// 1. finds relevant identifiers using language server protocol!
// 1.1 scope: global, but limited to type consistent identifiers
// 1.2 precision: provided identifiers are highly relevant
// 1.3 up-to-date: as language server protocol, highly up-to-date
// 2. Injection: guided generation
// 3. Cross platform: yes
The most promising previous work is "Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context"@agrawalMonitorGuidedDecodingCode. It uses static analysis of the generated code using #acr("LSP") to constrain the completion of the dereference operator "`.`", names of instantiated classes, the number of arguments in a function call and enumeration options in a switch statement.

Relevant context is provided by the #acr("LSP"). The information provided is precise, up-to-date and includes information on dependencies. The context is injected through watching and manipulating the logits using controlled generation, such as the `LogitsProcessor`. And finally the work is programming language independent through the use of #acr("LSP").

Generally, by combining static analysis through the #acr("LSP") with controlled generation, most problems can be solved.

The work is currently partially limited to Java, as some features only support Java features and some features Java-style features, such as the `new` statement.
Additionally, it does not disallow deprecated items and does not improve function arguments in constructors and other general functions.

// embeddings
Other work, such as "RepoCoder" @zhangRepoCoderRepositoryLevelCode2023 or "DocPrompting" @zhouDocPromptingGeneratingCode2023, improve code completion on a repository level through #acr("RAG") techniques, but fail in the scope and precision.

RepoCoder uses embeddings of the repository to retrieve relevant code context. This approach is not able to provide context on dependencies and does not propose an update mechanism for the local embeddings.
Additionally, the precision is only as high as the quality of the embeddings.

DocCoder in contrast uses embeddings of documentation as context. The work does not propose specific documentation sources, as such the scope is not specified.
As with RepoCoder, the precision is only as high as the quality of the embeddings.
Lastly, the work does not propose an update mechanism for the embeddings.

// planning
// CodePlan?

