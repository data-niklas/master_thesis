#import "@preview/touying:0.5.2": *
#import "@preview/numbly:0.1.0": numbly
#import "/constants.typ": *
#import "/utils.typ": *
#import "/template/styling.typ": link-style, figure-style
#let acronyms = (
  "IBMS": "Interrupt-Based Meta-Strategy",
  "CLM": "Causal Language Model",
  "MGD": "Monitor-Guided-Decoding",
)

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
== Causal Language Models
#image("/presentation/assets/causal-language-model.drawio.svg")
- $V$: vocabulary of all tokens
- token: subword, word, or character
- $omega_1...omega_n; omega in V$: sequence of tokens (#sym.arrow.double text)
- $p_1...p_(|V|); sum_(i=1)^(|V|) p_i = 1$: probability distribution over $V$

== Motivation
- #acrpl("CLM") help reduce writing boilerplate code
- Copilot is widely used
- #acrpl("CLM") trained on data _until cut-off date_
- #acrpl("CLM") have issues with changing dependencies

== Problem Scenarios
1. _Feature recently changed (deprecation)_
2. Feature recently added
3. Feature recently removed
4. Feature changed in any way, but not represented in training data
// Focus on deprecation: changed attribute / changed method

== Interlude: Example Pydantic 1 - Copilot
#figure(
  highlight(
    (22,),
    max-width: true,
    padding: 2pt,
    codefile("/assets/code/invalid_copilot_pydantic.py", create-link: false),
  ),
  caption: [Invalid completion by Copilot, even when guided by code comments.],
)
== Interlude: Example Pydantic 1 - Solution
#figure(
  highlight(
    (20,),
    max-width: true,
    padding: 2pt,
    codefile("/assets/code/dataset/pydantic_1.py", create-link: false),
  ),
  caption: [Gold solution highlighted in purple.],
)

== Goals
1. Retrieval: Retrieve accurate code context using IDE tooling
2. Injection: Inject context into model, to guide it ...
  - ... away from incorrect suggestions (deprecated / removed features)
  - ... towards correct suggestions (new features)
3. Low performance overhead

== Contributions
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

= Comparison to Related Work
== Categories of Related Work
// 1. Training Improvement Works
1. Prompt Injection Works
  - Single-step meta-strategies
  - Multi-step meta-strategies

2. Logit-based Approaches

== DocPrompting @zhouDocPromptingGeneratingCode2023
- Key points
  - Single-step meta-strategy
  - Context source: Online Documentation (DevDocs)
  - Retrieval process: Embedding search
  - Injection point: Once before generation into prompt

- Benefits
  - Flexible which documentation to embed
  - Documentation may include high quality user-submitted guides / examples
  - Fast

- Limitations
  - Context retrieved based on given code, _not to-be-generated code_
  - No differentiation between dependency sources

== RepoCoder @zhangRepoCoderRepositoryLevelCode2023
- Key points
  - Multi-step meta-strategy
  - Context source: Repository excluding environment files (`venv`, `node_modules`, etc.)
  - Retrieval process: Embedding search
  - Injection point: Once before generation into prompt

- Benefits

- Limitations

// #utils.slide-counter.update(1)

// 1: massive filtering and which sources were used
// 2: where is context injected, how and for how long
// 3: how much performance impact does it have
= Interrupt-Based Meta-Strategy
== Monitor-Guided-Decoding
==

= Full Approach
- Complexity lies in implementation, as many issues hinder stability
- How to filter?

= Results
== DependencyEval Dataset
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

== Baseline Results
- Fails to use dependencies in following cases:
  - Pydantic
  - Textual
- Differences between configurations
== Results using the Approach
- Improves following situations
- Differences between configurations
== Issues with the Approach

= Discussion
- Which assumptions does the approach hold about the model?
// - Model has capability to predict entrypoint into completed code
// i.e.: the model has to make the start for the approach to guide it
// - "guiding", the model performs brunt work
- Could the evaluation have included tasks of the standard library?
// yes, but Python std is slower moving than other areas
// i.e.: look at c++ and its std library

= One-Click-Demo™

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
