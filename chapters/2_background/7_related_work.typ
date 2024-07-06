#import "/utils.typ": *
== Related Work <chapter:bg:related_work>
Several prior works introduce repository level context or global context into neural code completion.
The work `Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context` @agrawalMonitorGuidedDecodingCode by Agrawal et al. is the most advanced framework and uses static analysis to supplement code completion.
Other works, such as `RepoCoder` @zhangRepoCoderRepositoryLevelCode2023 or `DocPrompting` @zhouDocPromptingGeneratingCode2023, use #acr("RAG") techniques to retrieve supplemental context.

=== Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context
The work by Agrawal et al. introduces #acr("MGD"), a technique to guide the decoding by observing the generation using a monitor, combined with static analysis.

During the generation process, the monitor has access to the current token sequence and the logits of the prediction. The monitor then retrieves information from the static-analysis, based on the current token sequence. Depending on internal rules, the monitor decides if the logits should be guided and to what extent@agrawalMonitorGuidedDecodingCode.

The work uses the *#acr("LSP")* to retrieve information about the global context.
It suggests rules to guide the generation of the dereference operator "`.`", names of instantiated classes, the number of arguments in a function call and enumeration options in a switch statement.
They show that smaller models can be augmented to outperform larger models through the use of the monitor. Additionally, compilation rates are consistently improved@agrawalMonitorGuidedDecodingCode.

=== RepoCoder
The work by Zhang et al. introduces `RepoCoder`, a framework to improve neural code completion on a repository level through iterative retrieval and generation of code.

`RepoCoder` is based on a conventional #acr("RAG"), which uses a similarity-based retriever to locate relevant code snippets in the repository and enhance the code completion using the relevant code.
The key insight is to enhance the similarity-based retriever by retrieving code similar to the generated code and regenerating the code with the new retrieved code snippets iteratively@zhangRepoCoderRepositoryLevelCode2023.

// TODO: results

=== DocPrompting
The work by Zhou et al. introduces `DocPrompting`, a framework to improve neural code completion by using documentation as context.

In contrast to Zhang et al., the work uses documentation as context to improve code completion and does not work iteratively. The documentation is sourced from globally available documentation, such as `DevDocs`@DevDocs.

// TODO: results
