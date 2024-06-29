= Design <design>
// 3 Problems
As was introduced in @chapter:bg:code_generation, the three main problems with code completion are finding *precise*, *globally scoped* and *up-to-date* context, injecting the context and a working framework for most programming languages.
The few prior work presented in @chapter:bg:related_work has several weaknesses, such as only improving type-valid identifier dereferences, using deprecated dependencies, using imprecise context or having enough data sources.

// Not enough related work
// Design wihch will solve prolbems
This chapter first introduces a general design for a meta-strategy to robustly inject context into code completion in @chapter:design:ibms. Then a specific framework solving the aforementioned problems is detailed in @chapter:design:lsp. Finally, this work creates a dataset to benchmark the implementation of the design.

Each section will include the requirements, evaluation criteria and the components of each design.
Furthermore, each requirement will be linked to research questions and thus the goals of the work.

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

