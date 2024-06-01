= Background
- LLM are versatile and can be used for many tasks
- Code generation is one domain, where LLM used to assist developers: programming, designing architectures, understanding code, etc.


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