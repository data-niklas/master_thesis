#import "/utils.typ": *
= Approach <design>
After introducing the necessary background in @background,
this section will first derive the requirements from the motivation and goals in @chapter:design:requirements.

By analyzing the shortcomings of existing solutions in @chapter:design:analysis,
the thesis will propose a new approach to integrate high quality context into neural code completion. Context retrieval is enhanced with handcrafted filtering rules, to reduce noise and improve completion accuracy.

Lastly, a dataset is introduced to evaluate the effectiveness of the new approach.

== Requirements <chapter:design:requirements>
The general requirements of this thesis are derived from the motivation and goals, namely the approach of a `Copilot` like solution which has *full* knowledge of the local development environment.

The general requirements in descending order of importance are seen in @requirements.
#figure(
  table(
    columns: 2,
    table.header([Identifier], [Keyword]),
    [*R1*],
    [Dependency Accuracy],
    [*R2*],
    [General Correctness],
    [*R3*],
    [Robustness],
    [*R4*],
    [Generalizability],
    [*R5*],
    [Performance],
  ),
  caption: "General requirements of the thesis",
)<requirements>

=== Dependency Accuracy <r:1>
Neural code completion works under the assumption that the #acr("CLM") has knowledge of the used code dependencies.
This requires either vast amounts of training data on code written using a similar version of the dependencies or the local code to already use the dependency correctly.
The first option has the problem, that the training data is not annotated with the correct dependency version, thus #acrpl("CLM") cannot differentiate between different versions of the same dependency.
The approach works well for widely used dependencies, which have breaking changes rarely and do not have many different used versions.
In contrast, the approach does not work for dependencies which are either too new, or too unused to be known to the #acr("CLM"). Another problematic type of dependency is the often changing dependency, as the model cannot process breaking changes in the dependency.

The second option, in-context learning, allows the #acr("CLM") to dynamically learn a small subset of the dependency. The benefit of such a dynamic approach is that the #acr("CLM") has accurate knowledge of dependency knowledge previously unknown. The huge flaw is that the #acr("CLM") can only copy the developer, thus only achieving quality on par, but not above the developer.
Additionally, the developer has to write the initial code, in which case the developer either misuses the dependency or already acquired knowledge of the dependency, in which case the #acr("CLM") cannot support him in that regard.

1. The proposed approach shall provide neural code completions with a high accuracy, by always considering the *exact local development environment* and the full feature set of each dependency.
2. It shall differentiate between nuances of different versions of the same dependency.
3. To enable diverse code completions, the approach shall be able to handle a wide range of dependencies, even if they have never been used in other public projects before.

The second dependency accuracy requirement has the implication that the approach should follow (some) clean code practices. Dependencies use a "Deprecation" mechanism to gradually change features, without breaking dependent code directly by providing a time window, in which the code can be changed, before the old feature is removed or replaced.
By differentiating between nuances in different versions, the approach can suggest code which is future-proof and does not rely on deprecated features.
The following different scenarios between dependency versions can be distinguished:
1. The dependency has a new feature, which is not available in the old version.
2. The dependency has a feature, which is deprecated in the new version and will either be removed or replaced.
3. The dependency has a feature, which is not available in the new version.

It should be noted, that local code bases are a special case of a dependency and should not be treated differently, as many different works do.
Locally available code is also imported and used alongside remote dependencies. As such, the *scope* of this thesis includes prediction of all possible code.

=== General Correctness <r:2>
The proposed approach builds upon other work to improve especially dependency handling in neural code completion. Still, the basic assumptions on code correctness should still stand.
In particular, the approach should suggest syntactically correct code.
Additionally, the approach should suggest code that is functionally correct and solves the given task.

Both correctness requirements are the essentials, which are expected from any code completion tool, upon which the thesis improves.
The focus of this thesis lies on improving methodical correctness through `Dependency Accuracy` and functional correctness and `General Correctness` are secondary.

=== Robustness <r:3>
Developers may work on code in a variety of different environments and using different types of dependencies. The approach should be robust under any circumstances and still provide reasonably good completions.

Specifically, the approach should be able to handle the following scenarios:
1. The size of the project should be irrelevant. The approach should scale to any project size.
2. The approach should be able to handle any type of dependency, irrelevant of the size or complexity of the dependency. It shall not matter if the dependency has no documentation or has pages full of documentation.

=== Generalizability <r:4>
The programming language ecosystem is vast and diverse. Even though only a few programming languages are widely used @StackOverflowDeveloper, the approach should be able to handle most programming languages.
By supporting lesser used programming languages, this approach can be used to help developers in a wider range of projects, such as hobby projects. It could be even used to maintain legacy code.

=== Performance <r:5>
Using editor tooling feels fast, as responses in interactions with toolings only take a few milliseconds, up to a second. Integrating #acr("CLM") for code completion increases the latency by a significant margin, as inference takes several seconds up to a minute. // TODO: ref

While the goal of this thesis is not to reduce the latency in neural code generation, the approach should not impose a significant overhead on the default code completion.

== Analysis <chapter:design:analysis>
After introducing the five requirements in the previous section, this section will analyze the shortcomings of existing solutions in regard to the requirements. In particular, the analysis will focus on the work by Agrawal et al. @agrawalMonitorGuidedDecodingCode, as it is the most promising work.
While this thesis has evolved without the knowledge of the work by Agrawal et al. and is not based on it, the general design choices are similar enough to show initial observations and design choices.

=== Monitor-Guided Decoding
In short, the work by Agrawal et al. fulfills all requirements except the `Dependency Accuracy`, but is limited in scope when considering dependencies.

By guiding the neural code completion selectively through the monitor, the approach improves upon the default code completion and fulfills the requirement of `General Correctness`.
Meanwhile, the `Dependency Accuracy` is only partially fulfilled. The work takes an important step in using #acr("LSP"), as it enables retrieving context globally of the exact version of used dependencies.
As the work only guides the dereference operation and function arguments count, the approach does not consider changes between dependency versions, such as deprecated items.
// second case does not work
It cannot guide the model away from now deprecated features.

Additionally, other code items, such as function signature parameters are not considered in the work.

As the work depends on the #acr("LSP"), it is robust under the assumption, that the running language server is robust.
By abstracting language dependent features, the work is generalizable to other programming languages, though the implementation of the work relies on Java specific functionality.
Through the use of #acr("MGD"), the only performance overhead of this method is the additional processing for each token. The bulk of the processing is shifted towards the language server, which performs the static analysis. As the language servers are optimized towards these analyses, the performance impact is $O(n)$, where $n$ is the token count @agrawalMonitorGuidedDecodingCode.

=== RepoCoder
The work by Zhang et al. fails in most requirements, only fulfilling basic requirements.
It improves the default neural code completion through the use of repository level code snippets, thus fulfilling the `General Correctness` requirement.
But in only considering repository level code, it fails to work on remote dependencies and cannot capture the nuances between different versions of dependencies. Thus, it also fails the `Robustness`, especially as embedding of the local repository must be performed upfront. This upfront embedding of local code scales with the repository size and taking a considerable time for larger projects.
By reusing local code, the approach is generalizable to other programming languages, as the retrieved context is of the same language.
Under the assumption taht the embedding is performed upfront, the performance decreases by the iteration count $i$.

=== DocPrompting
The work by Zhou et al. fails similarly to `RepoCoder`, as it uses a similar approach, but tuned towards globally available documentation. As no iterations are used, the performance impact is a single similarity search using embeddings.

=== Summary
While `DocPrompting` and `RepoCoder` show that using documentation and available code can improve neural code completion, they fail to improve completions for very specific installed dependencies.
The work by Agrawal et al. fulfills the most requirements, through the clever use of #acr("LSP").
#acr("LSP") is a protocol abstracting programming language features, thus enabling generalizable approaches using global context of the exact installed dependencies.

A possible approach would use available information, such as the `CompletionItemTag` in a `CompletionItem`, to check if an item was deprecated and should not be used anymore.
Furthermore, additional language features, such as signature completions, could be used to guide the neural code completion of parameters in function calls.

A full #acr("MGD") is not possible, due to deprecated completion items. A typical #acr("MGD") approach would keep the logits of completion item to guide the dereference operation, as seen in Agrawal et al., but mask other tokens.

When combined with deprecated completion items, tokens of deprecated completion items would need to be masked, *while* tokens of non deprecated completion items would not be masked.
The problem arises when deprecated and non deprecated completion items share the same prefix when represented as a token sequence. Now the same token would need masking and retaining.

The thesis will thus propose an alternative approach, which enables the use of both types of information sources, by reranking logits of the #acr("CLM") locally in the monitor and globally by altering the prompt with injected information.
The approach is threefold and includes a novel meta-strategy to guide the model through prompt-engineering, with dynamically obtained information from static analysis. The second part is the approach based on the first novel meta-strategy. Lastly, the approach of a new dataset is introduced, to evaluate the performance of the proposed approach.

#{
  include "1_interrupt_based_meta_strategy.typ"
  include "2_lsp_aided_generation.typ"
  include "3_dataset_design.typ"
}

/* ~ General flow ~
  1. General new meta-strategy
  2. Use meta-strategy to implement codegen with LSP
  3. Benchmark method using dataset and pipeline

  ~ Goals ~
  General design, so talk about how goals can be generally achieved through architecture
  Top-down

  ~ Non goals ~
  Talk about implementation details and tweaks / hacks
*/

