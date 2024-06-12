#import "/utils.typ": *
= Background & Related Work <background>
This chapter provides important background information and related work, necessary to understand the main contributions of this thesis.
Firstly, #acrpl("CLM") are introduced in @bg_llms. Thereafter, @bg_text_generation discusses commonly used text generation strategies.

The section @bg_controllable_generation showcases strategies to modify the text generation of a fixed pretrained #acr("CLM").
@bg_transformers displays important components of the popular Hugging Face libary, which enables #acr("CLM") workflows using all of the techniques introduced in the sections before.

Thereafter, @bg_code_generation highlights important aspects of code generation. Continuing, @bg_lsp introduces the functionality of the #acr("LSP"). At last, @bg_related_work introduces previous work.

/*
- LLM are versatile and can be used for many tasks
- Code generation is one domain, where LLM used to assist developers: programming, designing architectures, understanding code, etc.
*/

#{
  include "1_llm.typ"
  include "2_text_generation.typ"
  include "3_meta_strategies.typ"
  include "4_huggingface.typ"
  include "5_code_generation.typ"
  include "6_lsp.typ"
  include "7_related_work.typ"
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
