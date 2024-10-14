#import "@preview/touying:0.5.2": *
#import "@preview/numbly:0.1.0": numbly
#import "/constants.typ": *
#import "/utils.typ": *
#import "/plot.typ": *
#import "/eval.typ": *
#import "/eval-values.typ": *
#import "/template/styling.typ": link-style, figure-style
#let acronyms = (
  "CLM": "Causal Language Model",
  "IBMS": "Interrupt-Based Meta-Strategy",
  "MGD": "Monitor-Guided-Decoding",
)
#let column-colors = (
  "#57A58C",
  "#7888AD",
  "#D67853",
  "#C475A6",
).map(color.rgb)
#let c(body) = align(horizon + center, body)

#let print-mode = false

#let raw-math-style(doc) = {
  show raw: set text(font: "New Computer Modern Mono", size: 16pt)
  // Else texttt style text in normal backticks is too small
  show raw.where(lang: none, block: false): set text(size: 17pt)
  set math.equation(supplement: "Equation", numbering: "(1.1)")
  doc
}
#show: doc => {
  init-acronyms(acronyms)
  show outline.entry.where(level: 2): it => {
    set text(size: 0.7em)
    it
  }
  doc = link-style(print-mode, x => false, doc)
  let heading-align = left
  let cell-align = left
  set table.hline(stroke: (
    paint: black,
    thickness: 0.4pt,
  ))
  set table(
    align: (x, y) => {
      if y == 0 {
        heading-align
      } else {
        cell-align
      }
    },
    stroke: (x, y) => {
      if y == 0 {
        (
          bottom: (
            paint: black,
            thickness: 0.4pt,
          ),
          top: (
            paint: black,
            thickness: 0.7pt,
          ),
        )
      }
    },
  )
  show table: it => {
    let other_table = it.stroke == none
    if it.children.len() > 0 and it.children.at(it.children.len() - 1).func() == table.hline or other_table {
      it
    } else {
      let items = it.fields()
      let children = items.remove("children")
      table(
        ..items,
        ..children,
        table.hline(stroke: (
          paint: black,
          thickness: 0.7pt,
        )),
      )
    }
  }
  set figure.caption(position: bottom)
  show figure.caption: set text(size: 18pt)
  show figure.caption: set par(leading: 0.5em)
  show outline: set text(size: 0.8em)
  raw-math-style(doc)
}
#set heading(numbering: numbly("{1}.", default: "1.1"))

#import themes.university: *

#let new-section-slide(
  level: 1,
  numbered: true,
  title,
) = touying-slide-wrapper(self => {
  let body = {
    set align(horizon)

    show: pad.with(22%)
    set par(leading: 0.5em, hanging-indent: 1em)
    set text(size: 1.5em, fill: self.colors.primary, weight: "bold")
    stack(
      dir: ttb,
      spacing: .65em,
      utils.display-current-heading(level: level, numbered: numbered),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(
          height: 2pt,
          self.colors.primary,
          self.colors.primary-light,
        ),
      ),
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, body)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set align(horizon)
    block(
      width: 100%,
      inset: 2em,
      {
        components.left-and-right(
          {
            text(size: 1.3em, text(weight: "medium", info.title))
            if info.subtitle != none {
              linebreak()
              text(size: 0.9em, info.subtitle)
            }
          },
          text(2em, utils.call-or-display(self, info.logo)),
        )
        line(length: 100%, stroke: .05em + self.colors.primary-light)
        set text(size: .8em)
        block(height: 0.2em, info.author + [ | 3737339])
        block(height: 0.2em, utils.display-info-date(self))
        set text(size: .8em)
        block()[
          Heidelberg University\
          Institute of Computer Science\
          Artificial Intelligence for Programming (AIP)
        ]
        block()[
          Prof. Dr. Artur Andrzejak
        ]
      },
    )


  }
  touying-slide(self: self, body)
})

#show: university-theme.with(
  aspect-ratio: "16-9",
  config-common(new-section-slide-fn: new-section-slide),
  config-info(
    title: title,
    subtitle: [Master Colloquium],
    author: author,
    institution: [Heidelberg University],
    date: datetime.today(),
  ),
)
#set heading(numbering: "1.1")
#show heading.where(level: 1): set heading(numbering: "1.")

#let nested-list-style(item) = {
  set par(leading: 0.8em)
  set text(size: 0.8em)
  item
}
#let list-style(item) = {
  show list.item: nested-list-style
  show enum.item: nested-list-style
  item
}
#show list: list-style
#show enum: list-style
// slide, empty-slide, focus-slide

// --------- Content --------------
#title-slide()
#empty-slide(components.adaptive-columns(outline(indent: 1em, depth: 1)))
#set par(leading: 1.5em)
// nothing unusual
= Introduction
== Motivation
#v(0.8em)
- #acrpl("CLM") are used for code completion
- #acrpl("CLM") help reduce writing boilerplate code (e.g. Copilot)
- #acrpl("CLM") trained on data _until cut-off date_
- #acrpl("CLM") have issues with changing dependencies

== Example Pydantic 1 - Copilot
#c(
  highlight(
    (22,),
    max-width: true,
    padding: 2pt,
    codefile(
      "/presentation/assets/invalid_copilot_pydantic.py",
      create-link: false,
    ),
  ),
)
== Example Pydantic 1 - Solution
#c(
  highlight(
    (20,),
    max-width: true,
    padding: 2pt,
    codefile("/presentation/assets/pydantic_1.py", create-link: false),
  ),
)
== Problem Scenarios
#v(0.8em)
1. _Feature recently replaced_
2. Feature recently removed
3. Feature recently added
4. Feature changed in any way, but not represented in training data
// Focus on deprecation: changed attribute / changed method

== Background - Causal Language Models
#image("/presentation/assets/causal-language-model.drawio.svg")
#pause
- $V$: vocabulary of all tokens
- token: subword, word, or character
- $omega_1...omega_n; omega in V$: sequence of tokens (#sym.arrow.double text)
- $p_1...p_(|V|); sum_(i=1)^(|V|) p_i = 1$: probability distribution over $V$

== Goals
#v(0.8em)
1. Retrieval: Retrieve accurate code context using IDE tooling
2. Injection: Inject context into model, to guide it ...
  - ... away from incorrect suggestions (deprecated / removed features)
  - ... towards correct suggestions (new features)
3. Low performance overhead

== Contributions
#v(0.2em)
1. Static Analysis-guided neural code completion
  - Online monitoring of code completion
  - Accurate context retrieval
  - Hybrid injection of context using #acrf("MGD")
  // coined by agrawal? et al.
#pause
2. #acrf("IBMS")
  - Inject context into the prompt "during" generation
  - #sym.arrow.double Low performance overhead
  - Applicable outside of code completion
#pause
3. DependencyEval dataset
  - Handcrafted dataset to evaluate the approach used by the model
  - 25 Python tasks with fully pinned code environments
  - Evaluation framework to evaluate approach

#{
  set par(leading: 0.5em)
  heading(depth: 1)[Comparison to Related Work]
}

== Categories of Related Work
#v(0.8em)
// 1. Training Improvement Works
1. Prompt Injection Works
  - Single-step meta-strategies
  - Multi-step meta-strategies

2. Logit-based Approaches

== Prompt Injection Works
#c(
  image("/presentation/assets/causal-language-model-prompt.drawio.svg"),
)
// the power of hindsight to refine the prompt

== Logit-based Approaches
#c(
  image("/presentation/assets/causal-language-model-logits.drawio.svg"),
)

== DocPrompting @zhouDocPromptingGeneratingCode2023
#v(0.2em)
- Key points
  - Single-step meta-strategy
  - Context source: Online Documentation (DevDocs)
  - Retrieval process: Embedding search
  - Injection point: Once before generation into prompt
#pause
- Benefits
  - Flexible which documentation to embed
  - Documentation may include high quality user-submitted guides / examples
  - Fast
#pause
- Limitations
  - Context retrieved based on given code, _not to-be-generated code_
  - No differentiation between dependency sources

== RepoCoder @zhangRepoCoderRepositoryLevelCode2023

#v(0.8em)
- Key points
  - Multi-step meta-strategy
  - Context source: Repository excluding environment files (`venv`, `node_modules`, etc.)
  - Retrieval process: Embedding search
  - Injection point: Once before generation into prompt
#pause

- Benefits
  - Full source code as context, including docstrings
  - Bases retrieval on generated code
#pause

- Limitations
  - Slower due to multiple steps
  - No retrieval from dependencies

== Monitor-Guided-Decoding#footnote[
Monitor-Guided Decoding of Code LMs with Static Analysis of Repository Context
] @agrawalMonitorGuidedDecodingCode
#v(0.8em)
- Key points
  - Online monitoring / manipulation of token sequence
  - Context source: IDE completion entries
  - Retrieval process: Request language server
  - Injection point: Next token probability distribution
#pause

- Benefits
  - Accurate context retrieval
  - Low performance overhead
#pause

- Limitations
  - Injection of unstructured context (docstring) hard
  - Only focuses on available code, should disallow deprecated code

// #utils.slide-counter.update(1)

// 1: massive filtering and which sources were used
// 2: where is context injected, how and for how long
// 3: how much performance impact does it have
= Interrupt-Based Meta-Strategy
== Goals
#v(0.8em)
- Online injection of context into the prompt (e.g. docstrings)
- #sym.arrow.double Enable #acr("MGD") to inject unstructured context
- Full resumption of generation after injection\ (do not regenerate current partial result#footnote(text(size: 14pt)[_Details massively simplified here_]))
- #sym.arrow.double Support beam search decoding strategy

== Approach
#v(0.8em)
- Add special "interruption" token to model / tokenizer
- Stop generation on interrupt token
- #acr("MGD") sets interrupt token when context available
- Edit prompt with provided context (_location_ / _scope_)
- Patched model generation to enable full resumption#footnote(text(size: 14pt)[_To fully enable beam search decoding_])

== Example
#{
  show raw: set text(font: "New Computer Modern Mono", size: 15pt)
  // Else texttt style text in normal backticks is too small
  show raw.where(lang: none, block: false): set text(size: 16pt)
  c(
    highlight(
      (20,),
      max-width: true,
      padding: 2pt,
      bg: color.hsv(240deg, 100%, 70%, 20%),
      codefile("/presentation/assets/pydantic_ibms_1.py", create-link: false),
    ),
  )
  pagebreak()
  c(
    move(
      dy: 0pt,
      highlight(
        (24,),
        max-width: true,
        padding: 2pt,
        bg: color.hsv(240deg, 100%, 70%, 20%),
        highlight(
          (20, 21, 22, 23),
          max-width: true,
          padding: 2pt,
          codefile(
            "/presentation/assets/pydantic_ibms_2.py",
            create-link: false,
          ),
        ),
      ),
    ),
  )
  pagebreak()
  c(
    highlight(
      (20,),
      max-width: true,
      padding: 2pt,
      bg: color.hsv(240deg, 100%, 70%, 20%),
      codefile("/presentation/assets/pydantic_ibms_3.py", create-link: false),
    ),
  )

}

== Refresher: Key points
#v(0.8em)
- Inject context into the prompt "during" generation
- #sym.arrow.double Low performance overhead
- Applicable outside of code completion

= Full Approach
== Key points
#v(0.8em)
- Hybrid approach using #acr("MGD") and #acr("IBMS")
- Retrieve context from IDE tooling in real-time:
  - Code completion entries
  - Signature help
- Downrank deprecated code completions
- Uprank other code completions
- #acr("IBMS") is main tool to guide model, prediction manipulation secondary

== Overview
#c(
  image(
    "/presentation/assets/causal-language-model-approach.drawio.svg",
    width: 110%,
  ),
)

// by combining the two, it gets the best of both worlds
// performance of online monitoring and allows changing predictions ad-hoc
// also bases context on current predictions
// interruption enables fast prompt modification, injecting  context efficiently
// difficulty lies in the implementation, to enable full support and opitimizations

= Results
== DependencyEval Dataset
#v(0.8em)
- Handcrafted dataset to evaluate the approach used by the model
- 25 Python tasks with fully pinned code environments
- Evaluation framework to evaluate approach
- Captures tasks for different problem scenarios:
  - Feature recently _replaced_
  - Feature recently added
  - Feature recently removed
  - Feature changed in any way, but not represented in training data

#pagebreak()

#c(
  codefile("/presentation/assets/example_task.json", create-link: false),
)
== DependencyEval Dataset - Tests
1. Output Correctness Test
  - Check the output of the function
  - Check set attributes, etc.

2. Approach Correctness Test
  - Check used variables _during_ the function call
// #c(
//   codefile("/presentation/assets/full_tests.py", create-link: false),
// )

// Issues: finding testable high quality tasks

== Experiment Environment
#table(
  columns: 2,
  align: (column, row) => {
    if (row == 0) {
      center
    } else if (column == 0) {
      left
    } else {
      left
    }
  },
  table.header([*Component*], [*Value*]),
  [*GPU*],
  [4x NVIDIA GeForce RTX 3090],
  [*OS*],
  [Ubuntu 21.04],
  [*Docker*],
  [20.10.7],
)

== Experiment Setup
#v(0.8em)
1. Models:
  - Code Llama Instruct 7B (CodeLlama)
  - Magicoder-S-DS 6.7B (Magicoder)
  - MistalHermes-CodePro 7B (MistalHermes)
  - Copilot (only for baseline)
  - _(each for 6 different decoding strategies)_

2. Baseline: Default model generation
3. Approach: Use one of the three configurations:
  - Default
  - Masked
  - Use completion

== Result Labels
1. Full / Fully solved
  - _both_ unit tests pass (functional and approach correctness)
2. Partial / Partially solved
  - only _one_ of the unit tests pass
3. Not solved
  - neither of the unit tests pass
  - includes runtime exceptions, which the test framework catches
4. Error
  - evaluation cannot be made
// Goal: move partially solved tasks to fully solved

== Baseline Results - Models
#{
  set text(size: 0.8em)
  stats-column-charts(
    width: 20,
    height: 10,
    x-label: none,
    colors: column-colors,
    (
      ("CodeLlama", codellama-baseline-stats),
      (
        "Magicoder",
        magicoder-baseline-stats,
      ),
      (
        "MistralHermes",
        codestral-baseline-stats,
      ),
      (
        "Copilot",
        copilot,
      ),
    ),
  )
}// Error: evaluation cannot be made, e.g.: fails due to syntax error
// Allows distinguishing e.g.: GPU memory limit errors in later stages
// Not solved: Evaluation proceeds and unit tests fail
// Partially solved: Only the functional test passes (usually the approach correctness test is stricter)
// fully solved: both tests pass
// sampling finds more perfect solutions, but without sampling generally solutions are found more consistently
// beam search performs better than greedy decoding (1 beam task)

== Baseline Results - Task Scenarios
#box(
  width: 100%,
  height: 75%,
  context {
    set text(size: 0.6em)
    set par(leading: 0.5em)
    let t = task-stats-table(
      show-total: false,
      get-task-stats(
        all-results + (raw-copilot,),
        key: "evaluated_code_vanilla",
      ),
    )
    t = modify(
      t,
      "children",
      children => {
        children.insert(5 * 6, table.hline())
        children.insert(5 * 19, table.hline())
        children.insert(5 * 23, table.hline())
        children.insert(5 * 25, table.hline())
        children
      },
      variadic: "children",
    )
    set table.hline(stroke: 1.5pt + gray)
    spread(2, has-header: true, t)
  },
)
// #pause
#place(
  top + left,
  box(width: 60pt, height: 138pt, stroke: 2.5pt + fuchsia, []),
  dx: 144pt,
  dy: 37pt + 120pt,
)
#place(
  top + left,
  box(width: 60pt, height: 59pt, stroke: 2.5pt + fuchsia, []),
  dx: 530pt,
  dy: 38pt,
)

== Approach Results - Task Scenarios
#c(
  box(
    width: 110%,
    height: 75%,
    context {
      set text(size: 0.6em)
      set par(leading: 0.5em)
      let t = task-stats-table(
        diff: true,
        show-total: false,
        task-stats-diff(
          get-task-stats(
            all-results,
            key: "evaluated_code_llm_lsp",
          ),
          get-task-stats(
            all-results,
            key: "evaluated_code_vanilla",
          ),
        ),
      )
      t = modify(
        t,
        "children",
        children => {
          children.insert(6 * 10, table.hline())
          children.insert(6 * 12, table.hline())
          children.insert(6 * 15, table.hline())
          children.insert(6 * 25, table.hline())
          children
        },
        variadic: "children",
      )
      set table.hline(stroke: 1.5pt + gray)
      spread(2, has-header: true, t)
    },
  ),
)
// #pause
#place(
  top + left,
  box(width: 58pt, height: 158pt, stroke: 2.5pt + fuchsia, []),
  dx: 40pt,
  dy: 86pt,
)

= One-Click-Demo
= Discussion
- Which assumptions does the approach hold about the model?
// - Model has capability to predict entrypoint into completed code
// i.e.: the model has to make the start for the approach to guide it
// - "guiding", the model performs brunt work
- Could the evaluation have included tasks of the standard library?
// yes, but Python std is slower moving than other areas
// i.e.: look at c++ and its std library
- What is the difference between multi-step meta-strategies and the #acr("IBMS")?
- Which further enhancements would improve the approach?
- Which assumptions does the approach hold about the programming language?
// - Language server support for the language
// - Completion entries
// - There is a deprecation mechanism (no mechanism is ok, but then the approach is less applicable)
// - There is a dereference operator
// CURRENT IMPLEMENTATION ASSUMPTIONS:
// () for function calls
// . for dereferencing

== Implementation difficulties
1. Model generating unwanted tokens (repetitions; descriptive sentences after generating code)
2. Runtime does not provide enough control over decoding internals
3. _Beam search_:
  - sequence reordering
  - separate state for different sequences
4. Detokenization not inverse of tokenization in practice
5. Model ignoring injected context
6. Use of different virtual environments
7. Language servers not providing accurate deprecation information

== Baseline Results - Best combinations
#figure(
  {
    set text(size: 0.8em)
    set par(leading: 0.5em)
    stats-column-charts(
      width: 18,
      height: 9,
      colors: column-colors,
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(0),
      )).sorted(key: task-sorted-key).rev().slice(0, 3),
    )
  },
  caption: [
    Overview over the top 3 baseline configurations.
  ],
)

== Approach Results - Best combinations
#figure(
  {
    set text(size: 0.8em)
    set par(leading: 0.5em)
    stats-table(
      show-total: false,
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(2),
      )).sorted(key: task-sorted-key).rev().slice(0, 3),
      diff: true,
    )
  },
  caption: [
    Overview over the top 3 approach configurations.
  ],
)
== Baseline Results - Worst combinations
#figure(
  {
    set text(size: 0.8em)
    set par(leading: 0.5em)
    stats-column-charts(
      width: 18,
      height: 9,
      colors: column-colors,
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(0),
      )).sorted(key: task-sorted-key).slice(0, 3),
    )
  },
  caption: [
    Overview over the top 3 baseline configurations.
  ],
)

== Approach Results - Worst combinations
#figure(
  {
    set text(size: 0.8em)
    set par(leading: 0.5em)
    stats-table(
      show-total: false,
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(2),
      )).sorted(key: task-sorted-key).slice(0, 3),
      diff: true,
    )
  },
  caption: [
    Overview over the top 3 approach configurations.
  ],
)
== Full Experiment Environment
#table(
  columns: 2,
  align: (column, row) => {
    if (row == 0) {
      center
    } else if (column == 0) {
      left
    } else {
      left
    }
  },
  table.header([*Component*], [*Value*]),
  [*CPU*],
  [2x AMD EPYC 7713 64-Core],
  [*Memory*],
  [1 TB],
  [*GPU*],
  [4x NVIDIA GeForce RTX 3090],
  [*OS*],
  [Ubuntu 21.04],
  [*Kernel*],
  [5.15.0],
  [*Docker*],
  [20.10.7],
  [*Python*],
  [3.9.18],
  [*Transformers*],
  [4.39.0],
  [*PyTorch*],
  [2.2.1],
  [*CUDA*],
  [11.8],
)
== Baseline Results - Model configurations
Sampling
#{
  set text(size: 0.8em)
  stats-column-charts(
    width: 20,
    height: 10,
    colors: column-colors,
    x-label: none,
    (
      ("Sampling", sampling-baseline),
      ("No Sampling", no-sampling-baseline),
    ),
  )
}
// sampling finds more perfect solutions, but without sampling generally solutions are found more consistently
// beam search performs better than greedy decoding (1 beam task)

== Baseline Results - Model configurations
Beam search
#{
  set text(size: 0.8em)
  stats-column-charts(
    width: 20,
    height: 10,
    colors: column-colors,
    x-label: none,
    (
      ("1 Beam", one-beam-baseline),
      ("2 Beams", two-beams-baseline),
      ("3 Beams", three-beams-baseline),
    ),
  )
}
== Tasks
#show figure: set block(breakable: false)
#figure(
  codefile("/assets/code/dataset/bidict_1.py"),
  caption: [Task: `bidict_1.py`],
)
#figure(
  codefile("/assets/code/dataset/bidict_2.py"),
  caption: [Task: `bidict_2.py`],
)
#figure(
  codefile("/assets/code/dataset/dateutil_1.py"),
  caption: [Task: `dateutil_1.py`],
)
#figure(
  codefile("/assets/code/dataset/dotted_1.py"),
  caption: [Task: `dotted_1.py`],
)
#figure(
  codefile("/assets/code/dataset/dotted_2.py"),
  caption: [Task: `dotted_2.py`],
)
#figure(
  codefile("/assets/code/dataset/emoji_1.py"),
  caption: [Task: `emoji_1.py`],
)
#figure(
  codefile("/assets/code/dataset/fastapi_1.py"),
  caption: [Task: `fastapi_1.py`],
)
#figure(
  codefile("/assets/code/dataset/numpy_1.py"),
  caption: [Task: `numpy_1.py`],
)
#figure(
  codefile("/assets/code/dataset/pandas_1.py"),
  caption: [Task: `pandas_1.py`],
)
#figure(
  codefile("/assets/code/dataset/polars_1.py"),
  caption: [Task: `polars_1.py`],
)
#figure(
  codefile("/assets/code/dataset/pydantic_1.py"),
  caption: [Task: `pydantic_1.py`],
)
#figure(
  codefile("/assets/code/dataset/pydantic_2.py"),
  caption: [Task: `pydantic_2.py`],
)
#figure(
  codefile("/assets/code/dataset/pydantic_3.py"),
  caption: [Task: `pydantic_3.py`],
)
#figure(
  codefile("/assets/code/dataset/pytorch_1.py"),
  caption: [Task: `pytorch_1.py`],
)
#figure(
  codefile("/assets/code/dataset/pytorch_2.py"),
  caption: [Task: `pytorch_2.py`],
)
#figure(
  codefile("/assets/code/dataset/pytorch_3.py"),
  caption: [Task: `pytorch_3.py`],
)
#figure(
  codefile("/assets/code/dataset/rich_1.py"),
  caption: [Task: `rich_1.py`],
)
#figure(
  codefile("/assets/code/dataset/rich_2.py"),
  caption: [Task: `rich_2.py`],
)
#figure(
  codefile("/assets/code/dataset/sklearn_1.py"),
  caption: [Task: `sklearn_1.py`],
)
#figure(
  codefile("/assets/code/dataset/sklearn_2.py"),
  caption: [Task: `sklearn_2.py`],
)
#figure(
  codefile("/assets/code/dataset/sqlalchemy_1.py"),
  caption: [Task: `sqlalchemy_1.py`],
)
#figure(
  codefile("/assets/code/dataset/textual_1.py"),
  caption: [Task: `textual_1.py`],
)
#figure(
  codefile("/assets/code/dataset/textual_2.py"),
  caption: [Task: `textual_2.py`],
)
#figure(
  codefile("/assets/code/dataset/theflow_1.py", lines: (1, 21)),
  caption: [Task: `theflow_1.py`],
)
#figure(
  codefile("/assets/code/dataset/theflow_1.py", lines: (23, auto)),
  caption: [Task: `theflow_1.py`],
)
#figure(
  codefile("/assets/code/dataset/tsv2py_1.py"),
  caption: [Task: `tsv2py_1.py`],
)

= Appendix
#empty-slide[#print-index(outlined: true, title: "Acronyms", level: 2)]
#show bibliography: it => {
  show heading: set text(size: text.size)
  set text(size: 13pt)
  it
}
// TODO: fix empty slide
== Bibliography
#empty-slide[
  #bibliography(
    bibliography-file,
    title: none,
  )
]

// TODO: save definition of phrases, such as causal language model
