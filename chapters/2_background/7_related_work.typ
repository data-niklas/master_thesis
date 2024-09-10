#import "/utils.typ": *
/*
Approach papers:
Program Synthesis with Large Language Models: Incorporate Human Feedback (in prompt)
- evaluate limits of the current generation of large language models for program synthesis in
general purpose programming languages
- We find that natural language feedback from a human halves the error rate compared to the model’s initial prediction
- Can the feedback be retrieved automatically and embedded into the prompt?

RepoFusion: Training Code Models to Understand Your Repository
- Different strategy for incorporating repository context
- Infuse repository level context during training
- Learn to leverage context, then tooling can add repository level context, which is then properly utilized
- Dependant on further tooling, but paves the way for advanced tooling
- Instead of feedback, the core capabilities are strengthened

De-Hallucinator: Mitigating LLM Hallucinations in Code Generation Tasks via Iterative Grounding
- Iterative meta-strategy
- Find API information based on current version of code
- add found information to iterative prompt
- bonus: does not need high level of integration with LLM, as it uses an interative approach
- requires pre-analysis + RAG
- fails to use static analysis during approach, as it is done upfront
- requires iterative approach, as the code synthesis must be redone with the new information, as the approach fails to analyze the to be generated code ad-hoc
- adds feedback to prompt
- fails to analyze further dependencies, as the pre-analysis only considers the project itself

Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context
- argues that the model may be guided during generation itself, which is an improvement over iterative generation, as the model may be steered quicker
- operates on all dependencies (including project)
- apply constraints to generation through logits shaping
- force logits
- does not allow for nuanced information, such as integrating documentation, which is more easily integrated into the prompt, but allows for guided generation, when guidance is certain
- generalizes, is fast

RepoCoder: Repository-Level Code Completion with Iterative Retrieval and Generation
- uses RAG
- iterative approach, to apply RAG to generated code, then regenerating with new information
- assumes the code can converge to a correct solution
- argues that static analysis tools are insufficient, as they are limited in their scenarios
- paper linked only uses static analysis to extract method calls from a codebase
- static analysis limited to repository and does not consider dependencies
- static analysis retrieval is limited in functionality, as only method calls are considered
- no documentation is considered
- they instead now use full-text contexts

DocPrompting: Generating Code with Documentation as Context
- utilizes documentation
- documentation may be user-provided or extracted through static analysis (devdocs)
- may consider dependencies, if documentation is available
- limited by what is available, but higher quality user documentatino may be available
- generation only guided by the documentation through in-prompt information
- documentation serves as feedback


Enhancing LLM-Based Coding Tools through Native Integration of IDE-Derived Static Context
- above approaches suffer from limited context length (=> and proper filtering of provided information)
- approach: use diagnostic information from IDE (=> LSP)
- also use native static information
- challenges: filter unimportant information, and integrate found information
- uses LSP to extract docstrings etc
- downside: extracts cross-file contexts statically (once at the start), then adds found information
- but IT USES OTHER DEPENDENCIES, finally
- multi-step generation (meta-strategy), which first augments the prompt with analyzed cross-file contexts and then conducts further steps with linting information to refine the output
- uses chain-of-thought in some parts


Dataset papers:
CodeScope: An Execution-based Multilingual Multitask Multidimensional Benchmark for Evaluating LLMs on Code Understanding and Generation (Docker eval env)


1. Prompt-based approaches
1.1 non iterative
1.2 iterative

2. logits reshaping

3. training approaches

4. summary


*/

== Related Work <chapter:bg:related_work>
Several prior works introduce repository level context or global context into neural code completion.
The work `Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context` @agrawalMonitorGuidedDecodingCode by Agrawal et al. is the most advanced framework and uses static analysis to supplement code completion.
Other works, such as `RepoCoder` @zhangRepoCoderRepositoryLevelCode2023 or `DocPrompting` @zhouDocPromptingGeneratingCode2023, use #acr("RAG") techniques to retrieve supplemental context.

=== Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context
The work by Agrawal et al. introduces #acr("MGD"), a technique to guide the decoding by observing the generation using a monitor, combined with static analysis.

During the generation process, the monitor has access to the current token sequence and the logits of the prediction. The monitor then retrieves information from the static-analysis, based on the current token sequence. Depending on internal rules, the monitor decides if the logits should be guided and to what extent @agrawalMonitorGuidedDecodingCode.

The work uses the *#acr("LSP")* to retrieve information about the global context.
It suggests rules to guide the generation of the dereference operator "`.`", names of instantiated classes, the number of arguments in a function call and enumeration options in a switch statement.
They show that smaller models can be augmented to outperform larger models through the use of the monitor. Additionally, compilation rates are consistently improved @agrawalMonitorGuidedDecodingCode.

=== RepoCoder
The work by Zhang et al. introduces `RepoCoder`, a framework to improve neural code completion on a repository level through iterative retrieval and generation of code.

`RepoCoder` is based on a conventional #acr("RAG"), which uses a similarity-based retriever to locate relevant code snippets in the repository and enhance the code completion using the relevant code.
The key insight is to enhance the similarity-based retriever by retrieving code similar to the generated code and regenerating the code with the new retrieved code snippets iteratively @zhangRepoCoderRepositoryLevelCode2023.

// TODO: results

=== DocPrompting
The work by Zhou et al. introduces `DocPrompting`, a framework to improve neural code completion by using documentation as context.

In contrast to Zhang et al., the work uses documentation as context to improve code completion and does not work iteratively. The documentation is sourced from globally available documentation, such as `DevDocs`@DevDocs.

// TODO: results
