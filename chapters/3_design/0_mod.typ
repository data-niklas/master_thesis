#import "/utils.typ": *
= Design <design>
After introducing the necessary background in @background,
this section will first derive the requirements from the motivation and goals. // TODO: in

By analyzing the shortcomings of existing solutions in TODO // TODO: in
the thesis will propose a new design to integrate high quality context into neural code completion. Context retrieval is enhanced with hand crafted filtering rules, to reduce noise and improve completion accuracy.

Lastly, a dataset design is proposed to evaluate the effectiveness of the new design.

== Requirements <chapter:design:requirements>
The general requirements of this thesis are derived from the motivation and goals, namely the design of a Copilot like solution which has *full* knowledge of the local development environment.

The general requirements in descending order of importance are seen in @requirements.
#figure(
  table(
    columns: 2,
    table.header([Identifier], [Keyword]),
    [*R1*],
    [General Correctness],
    [*R2*],
    [Dependency Accuracy],
    [*R3*],
    [Robustness],
    [*R4*],
    [Generalizability],
    [*R5*],
    [Performance],
  ),
  caption: "General requirements of the thesis",
)<requirements>

=== General Correctness <r:1>
The proposed approach builds upon other work to improve especially dependency handling in neural code completion. Still, the basic assumptions on code correctness should still stand.

In particular, the approach should suggest syntactically correct code.
Additionally, the approach should suggest code that is functionally correct and solves the given task.

Both correctness requirements are the essentials, which are expected from any code completion tool, upon which the thesis improves.

=== Dependency Accuracy <r:2>
Neural code completion works under the assumption that the #acr("CLM") has knowledge of the used code dependencies.
This requires either vast amounts of training data on code written using a similar version of the dependencies or the local code to already use the dependency correctly.
The first option has the problem, that the training data is not annotated with the correct dependency version, thus #acrpl("CLM") cannot differentiate between different versions of the same dependency.
The approach works well for widely used dependencies, which have breaking changes rarely and do not have many different used versions.
In contrast, the approach does not work for dependencies which are either too new, or too unused to be known to the #acr("CLM"). Another problematic type of dependency is the often changing dependency, as the model cannot process breaking changes in the dependency.

The second option, in-context learning, allows the #acr("CLM") to dynamically learn a small subset of the dependency. The benefit of such a dynamic approach is that the #acr("CLM") has accurate knowledge of dependency knowledge previously unknown. The huge flaw is that the #acr("CLM") can only copy the developer, thus only achieving quality on par, but not above the developer.
Additionally, the developer has to write the initial code, in which case the developer either misuses the dependency or already acquired knowledge of the dependency, in which case the #acr("CLM") cannot support him in that regard.

1. The proposed approach shall provide neural code completions with a high accuracy, by always considering the *exact local development environment* and the full featureset of each dependency.
2. It shall differentiate between nuances of different versions of the same dependency.
3. To enable diverse code completions, the approach shall be able to handle a wide range of dependencies, even if they have never been used in other public projects before.

The second dependency accuracy requirement has the implication that the approach should follow (some) clean code practices. Dependencies use a "Deprecation" mechanism to gradually change features, without breaking dependant code directly by providing a time window, in which the code can be changed, before the old feature is removed or replaced.
By differentiating between nuances in different versions, the approach can suggest code which is future-proof and does not rely on deprecated features.
The following different scenarios between dependency versions can be distinguished:
1. The dependency has a new feature, which is not available in the old version.
2. The dependency has a feature, which is deprecated in the new version and will either be removed or replaced.
3. The dependency has a feature, which is not available in the new version.

It should be notes, that local code bases are a special case of a dependency and should not be treated differently, as many different works do.
Locally available code is also imported and used alongside remote dependencies. As such, the *scope* of this thesis includes prediction of all possible code.

=== Robustness <r:3>
Developers may work on code in a variety of different environments and using different types of dependencies. The approach should be robust under any circumstances and still provide reasonably good completions.

Specifically, the approach should be able to handle the following scenarios:
1. The size of the project should be irrelevant. The approach should scale to any project size.
2. The approach should be able to handle any type of dependency, irrelevant of the size or complexity of the dependency. It shall not matter if the dependency has no documentation or has pages full of documentation.

=== Generalizability <r:4>
The programming language ecosystem is vast and diverse. Even though only a few programming languages are widely used@StackOverflowDeveloper, the approach should be able to handle most programming languages.
By supporting lesser used programming languages, this approach can be used to help developers in a wider range of projects, such as hobby projects. It could be even used to maintain legacy code.

=== Performance <r:5>

// Problem
// Incompatability between dependencies

// 3 Problems
// As was introduced in @chapter:bg:code_generation, the three main problems with code completion are finding *precise*, *globally scoped* and *up-to-date* context, injecting the context and a working framework for most programming languages.
// The few prior work presented in @chapter:bg:related_work has several weaknesses, such as only improving type-valid identifier dereferences, using deprecated dependencies, using imprecise context or having enough data sources.
//
// // Not enough related work
// // Design wihch will solve prolbems
// This chapter first introduces a general design for a meta-strategy to robustly inject context into code completion in @chapter:design:ibms. Then a specific framework solving the aforementioned problems is detailed in @chapter:design:lsp. Finally, this work creates a dataset to benchmark the implementation of the design.
//
// Each section will include the requirements, evaluation criteria and the components of each design.
// Furthermore, each requirement will be linked to research questions and thus the goals of the work.

#{
  // include "1_interrupt_based_meta_strategy.typ"
  // include "2_lsp_aided_generation.typ"
  // include "3_dataset_design.typ"
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

