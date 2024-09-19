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
Several prior works pave the way towards enhancing neural code completion through the integration of additional context.
The prior works use different strategies to control the generation process.
The first group focuses on improving the training process itself, to enhance future code completion. While these approaches are static and cannot adapt to specific dependencies, they serve as auxiliary steps in more dynamic approaches, by improving the general robustness of improved models.

The second group of papers embed additional context into the prompt, modifying the generation externally. This often leads to a simpler integration, allowing the approach to be used with even cloud-based model offerings, where there is almost no control over the generation.

Other papers modify the logits during the generation itself, increasing the flexibility even furthe, but integrating into the generation even tighter. This group can rarely be used with cloud-based model offerings, but is powerful due to the high level of control.
The following sections describe prior works, grouped into these three groups. Beforehand, an introductory work is presented.

=== Introductory related work
/*
Program Synthesis with Large Language Models: Incorporate Human Feedback (in prompt)
- evaluate limits of the current generation of large language models for program synthesis in
general purpose programming languages
- We find that natural language feedback from a human halves the error rate compared to the model’s initial prediction
- Can the feedback be retrieved automatically and embedded into the prompt?
*/
The prior work "Program Synthesis with Large Language Models" by Austin et al. @austinProgramSynthesisLarge2021a is the oldest prior related work, being published in 2021.
It serves as the basis for the following works, as it analyzes the limits of #acrpl("CLM") for program synthesis in general purpose programming languages.

One observation the paper presents is that the chosen sampling strategy is critical for good performance in code synthesis.
Beam search performs extremely poorly, greedy decoding performs better and sampling performs best when allowing several samples. As the paper empirically determines, beam search often produces looped or repeated code @austinProgramSynthesisLarge2021a.
The effect of a sampling beam search is not analyzed. The observations of Austin et al. mirror the results obtained by evaluating neural code completion using this approach.

The second observation stems from analyzing dialogue capabilities of models for code synthesis.
The authors observe that natural language feedback from a human halves the error rate compared to the model's initial prediction @austinProgramSynthesisLarge2021a.
These corrections often include small context errors, such as import and identifier errors.
While the authors state that feedback in natural language can correct small context errors, can this feedback be automated by a machine? Can a program determine additional natural language feedback before or after generation and add it to the prompt?
These questions serve as the basis for the prompt-based related works, which automate this step and use similar model capabilities to steer the models towards an improved code completion.

=== Training-based related works
The result of the work RepoFusion by Shrivastava et al. @shrivastavaRepoFusionTrainingCode2023 is a framework for training models with improved capabilities of using code context correctly.
The paper paints the scenario of a model performing code completion, in which it is unable to use the given code context correctly, as its ability of using correct #acrpl("API") are low.
The proposed framework uses a technique called #acr("FiD") to combine information from different code contexts (i.e. code files) into the training @shrivastavaRepoFusionTrainingCode2023.

As RepoFusion controls the model training, the trained model still has limited knowledge during code completion, but can utilize the available knowledge even more so.
As stated in the work, it is dependant on further tooling, which supplies the needed knowledge before code completion, such that the provided knowledge may be used.
While that leaves many problems unsolved towards using correct dependency information, it shows how model training may complement other approaches, which solve the tooling aspect.
RepoFusion possibly lays the groundwork for complex future tools, such that they may fully utilize code context embedded into the prompt.

=== Prompt-based related works
The next group of papers focus on embedding additional information into the prompt (and could benefit from training improvements similar to RepoFusion).
These related works propose meta-strategies, which use a strategy to retrieve additional information, which is then embedded into the prompt. The model is either used to directly generate a result, or used in a multi-step generation.
First the single-step generation works are discussed, after which the multi-step works follow.

==== Single-step generation related works.
/*
DocPrompting: Generating Code with Documentation as Context
- utilizes documentation
- documentation may be user-provided or extracted through static analysis (devdocs)
- may consider dependencies, if documentation is available
- limited by what is available, but higher quality user documentatino may be available
- generation only guided by the documentation through in-prompt information
- documentation serves as feedback
*/
The work DocPrompting by Zhou et al. @zhouDocPromptingGeneratingCode2023 focuses on utilizing code documentation. It presents a general approach to retrieve documentation relevant to the code generation beforehand, embed it into the prompt and then proceed generating the result code.
The documentation is sourced from online available documentation sites, such as DevDocs @DevDocs.
The retrieved documentation is then embedded. Relevant documentation is found by finding embeddings of documentation near the embedding of the prompt.

//
The benefit of such an approach is the high flexibility. It may be used with any model, as the only requirement is the regular generation interface. Additionally, documentation may be sourced from any source.
Sites such as DevDocs may include additional documentation over regular documentation in dependencies, which may provide further high-quality documentation not available elsewhere.

//
The downside of DocPrompting is that official code documentation of dependencies is used indirectly. Instead of directly retrieving documentation of dependencies, it is sourced elsewhere. The sources must be kept up-to-date. Additionally, the paper only aims for the latest documentation, not considering scenarios in which models work on legacy code bases. Using embeddings of documentation, it is hard to distinguish between different versions of the same code documentation.
The next downside is that searching for relevant documentation is based on the current prompt and not incomplete code during generation. The model is not provided with the information it requires *during* generation, but with information it may require due to the input.
This problem will now be referred to as the "context retrieval problem".

The issue is that such information is unknown before the first generation. This leads to more complex multi-step generation approaches, or even approaches controlling the model during generation.

//
Nonetheless, DocPrompting demonstrates how integrating up-to-date code documentation improves code completion and the importance of code documentation for this thesis.

==== Multi-step generation related works.
/*
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
*/
DocPrompting displayed the "context retrieval problem". Multi-step generation approaches remediate the issue by iterating on the result, retrieving relevant context after generation, then restarting the generation with more accurate context.

RepoCoder by Zhang et al. @zhangRepoCoderRepositoryLevelCode2023 is one such work. At its core, the work is similar to DocPrompting. The context is retrieved using #acr("RAG"), based on a pre-built index. The #acr("RAG") is based on the current version of the code and the result is embedded into the prompt.
The main difference is that instead of indexing documentation, RepoCoder indexes all project files. The idea is for the meta-strategy to allow the model to properly utilize repository code and converge to an ideal solution.

The downside of such a work is clear. As the index only considers repository files#footnote[
Only the persistent core project files are considered project files.
This excludes temporary project environment directories, such as `node_modules` or `venv` directories.
], no other dependencies are indexed. Thus, RepoCoder cannot provide relevant context on a specific version of a dependency.
Additionally, the solution to the "context retrieval problem" is slow, as multiple iterations are needed, to arrive at a satisfactory code solution.
As before, the upside is that by integrating the model generation into a wider strategy, this work can be used with cloud-based model providers.

// TODO: note that authors bash static analysis

/*
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
*/
A similar work is De-Hallucinator by Eghbali et al. @eghbaliDeHallucinatorMitigatingLLM2024.
It also uses an iterative generation to solve the "context retrieval problem". A difference is the index from which context is retrieved.
Instead of indexing the project files before generation, the authors propose to index #acr("API") references. They define an #acr("API") reference as either a function, class or attribute reference @eghbaliDeHallucinatorMitigatingLLM2024.
These are extracted using CodeQL#footnote[https://codeql.github.com/].

As both works are similar, both the benefits and downsides are the same.

/*
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
*/
The last work is IDECoder by Li et al. @liEnhancingLLMBasedCoding2024.
Compared to previous works, the authors identify that such #acr("RAG") approaches suffer from too many returned results and proper filtering is necessary.
The authors propose to use #acr("IDE")-native tooling to extract relevant information.
This is the first work in this group to leverage #acr("LSP") to extract information from code.

IDECoder uses a slightly different approach than the previous two works.
The first difference is that static information is added to the initial prompt, such as docstrings, project paths, member functions, class attributes, etc., which are extracted from the project.
An important note is how IDECoder processes dependencies. When encountering imports of third-party dependencies, the version is included as context, such that the model may differentiate between versions. The assumption is that the model has the capability to distinguish between versions as has enough knowledge about the third-party dependency.

The information is then merged and added to the initial generation prompt. The resulting code is then refined using a secondary process.
The assumption here is that relevant context has been found and only other errors need to be corrected. Here the #acr("LSP") is used to obtain diagnostics information about the generated code, such as mismatching types. The information is embedded into the prompt, resulting in a refined version of the code.

IDECoder showcases similar benefits as previous approaches. It can still be used with cloud-based model offerings, as the model is only used for generation. Additionally, high quality context information is used through language servers, even providing automated human feedback on the code.

While the approach shows less downsides, it may still struggle when using specific versions of dependencies, as the approach requires the model to be trained on samples of the dependency. This is not sustainable and IDECoder does *not* use the language server to provide such accurate context information.

=== Logits manipulation-based related works

/*
Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context
- argues that the model may be guided during generation itself, which is an improvement over iterative generation, as the model may be steered quicker
- operates on all dependencies (including project)
- apply constraints to generation through logits shaping
- force logits
- does not allow for nuanced information, such as integrating documentation, which is more easily integrated into the prompt, but allows for guided generation, when guidance is certain
- generalizes, is fast
*/
Previous works can be widely integrated into different runtimes an even be used with cloud-based model offerings. However, common issues include the slow runtime due to multiple generation steps and unrelevant context due to the "context retrieval problem".
More recent works propose to control the generation process itself, by modifying the logits during generation. This allows for a more nuanced control over the generation process, but may require a higher level of integration with the model.
#acr("MGD") by Zhang et al. @agrawalMonitorGuidedDecodingCode is one such technique.
The authors note that the model way be monitored during generation, such that relevant context may be retrieved and used ad-hoc. This allows for a quicker guided generation, as only a single generation step is necessary.
The proposed approach combines a generation hook with static analysis through language servers with logits manipulation. The generation hook obtains the current incomplete version of the code, enabling online static analysis.
#acr("MGD") focuses on type-consistent object-dereferencing, guiding the model when generating a dereference operation on an object, such as accessing a member function or attribute.
The generation is restricted to only allow available member functions or attributes of the type. Restriction occurs by modifying the logits of the current generation step.

In contrast to previous approaches, this work is more complex. It uses both static analysis through a language server and operating during the generation itself. While this increases the overall complexity, it achieves higher speeds while accurately pinpointing relevant context. Using the language server even enables the model to generate type-consistent object-dereferences for types of any source, such as third-party dependencies @agrawalMonitorGuidedDecodingCode.
#acr("MGD") is the first listed approach to correctly provide accurate context information for third-party dependencies.
While this is a great basis for further works, it fails to address the issue of code versioning, such as deprecated functions.
When guiding the model towards an attribute of a type, no distinction is made between deprecated and non-deprecated attributes.
This leads to models generating code using deprecated attributes.

Additionally, the scope of retrieved information is limited. By using a constraint based guided generation, modifying logits, embedding information such as docstrings is hard.
Simple guidance with little state between generated tokens is feasible, but shifting logit scores based on docstrings is not.
As shown before, guiding the model using docstrings is more easily done through the prompt.
A hybrid approach could leverage a language server to integrate textual information into the prompt, then further guide the model during generation using other context.
