#import "/utils.typ": *
= Background & Related Work <background>
Before talking about the main contributions, first the relevant background is given and related work shown. Firstly, fundamental properties of #acrpl("CLM") are introduced in @bg_llms. Afterwards, @bg_code_generation provides an overview over different types of code generation. Thereafter, @bg_meta_strategies discusses several strategies to incorporate #acrpl("CLM") into broader processes for code generation. @bg_guided_generation continues the discussion whilst focusing on sampling strategies. At last, @bg_lsp introduces the functionality of the #acr("LSP").


/*
- LLM are versatile and can be used for many tasks
- Code generation is one domain, where LLM used to assist developers: programming, designing architectures, understanding code, etc.
*/

#{
  include "1_llm.typ"
  include "2_code_generation.typ"
  include "3_meta_strategies.typ"
  include "4_guided_generation.typ"
  include "5_lsp.typ"
  // TODO: where do I talk about benchmarks
}

/* ~ General flow ~
  1. What are LLMs generally?
  2. How do they relate to code generation?
  3. General generation strategies (1) (outside the generation loop)
  4. General generation strategies (2) (inside the generation loop)
  (4.5 How to benchmark?)
  5. Logical part 2: Tooling

  ~ Goals ~
  List papers which define terms and introduce general methods

  ~ Non goals ~
  Do not go into details on these methods for code gen, move these details to related work
*/


/*
== Metrics
== Benchmarks
=== HumanEval
- Simplistic semantic benchmakr

=== ClassEval
- Advanced semantic benchmark

=== Other Eval

- Where are stylstic benchmarks?!
*/
