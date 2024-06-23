#import "/utils.typ": *
== Related Work <bg_related_work>
This section is divided into related work that introduces general techniques and related work specific to code completion.
Related work is evaluated based on the criteria introduced in @bg_code_generation.
// #set cite(form: "prose")

=== General Techniques
The first related work are meta-strategies that improve decision making through a multi-step process.
The meta-strategies could be then combined with data sources specific to code completion to improve code completion.

The first technique is Tree-of-Thoughts, as described in @bg_controllable_generation @yaoTreeThoughtsDeliberate2023a. A meta-strategy which generalizes this concept even further is Graph of Thoughts @bestaGraphThoughtsSolving2023.

// TODO: what is graph of thought

Such techniques can improve the syntax of the generated code, only when paired with the grammar of the programming language as a data source, and when reasoning about the syntax.
Similarly, these approaches can improve the semantics of the generated code, only when paired with data sources such as documentation and when reasoning about the documentation.
Generally, these general meta-strategies lack an integration into a strategy that finds relevant data sources.
// it is hard

=== Specific Techniques
// Outlines
The work "Outlines" @willardEfficientGuidedGeneration2023 that enables controlling the generation based on a provided syntax. Naturally, one could combine the syntax of a programming language with "Outlines" to force the model to generate syntactically correct code.
This work only focuses on syntax and does not consider other requirements.

A work that focuses on semantics is "RepoCoder" @zhangRepoCoderRepositoryLevelCode2023. It uses repository level embeddings, paired with retrieval-augmented generation, to provide a repository level data source to the generation.
This work only focuses on semantics and does not consider other requirements.
As the work uses embeddings for relevant code retrieval, the quality of the embeddings is crucial for the quality of the generated code. Additionally, each repository must be embedded before use of this technique and it currently cannot retrieve information regarding external dependencies.



// Training
// Enabling code completion using repo level information through training
// @shrivastavaRepoFusionTrainingCode2023

// Techniques for documentation:
// Only uses information using RAG...
@zhouDocPromptingGeneratingCode2023
Similar to "RepoCoder" is "DocPrompting"@zhouDocPromptingGeneratingCode2023, which uses embeddings of general documentation to provide relevant documentation as a data source.

// works on edits
// multi-step planning
// static analysis!!!!
// tree-sitter
// why no language tooling, like LSP?
@bairiCodePlanRepositorylevelCoding2023

// does most with LSP
// why does it exist!?!?!
// Downsides:
// - only triggered on '.'
// - only finds type consistent identifiers
@agrawalMonitorGuidedDecodingCode

// => no function signatures

