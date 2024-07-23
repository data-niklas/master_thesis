#import "@preview/hydra:0.4.0": hydra
#import "@preview/equate:0.2.0": equate

#let link-style(print-mode, doc) = {
  show link: it => {
    // Workaround for ctheorems package so that its labels keep the default link styling.
    // Ignore research question links
    if type(it.dest) == label and not str(it.dest).starts-with("rq:") {
      return it
    }
    let ignored-items = (table, figure)
    if ignored-items.contains(it.body.func()) {
      return it
    }
    if print-mode {
      let body-fields = it.body.fields()
      if type(it.dest) == str and (
        "text" not in body-fields or body-fields.at("text") != it.dest
      ) {
        it + footnote(link(it.dest))
      } else {
        it
      }
    } else {
      it
      h(1.6pt)
      super(
        box(
          height: 3.8pt,
          circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333")),
        ),
      )
    }
  }
  doc
}

#let style(print-mode, doc) = {
  set page(
    margin: (
      outside: 2.7cm,
      inside: 2.5cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    header: context {
      if calc.odd(here().page()) {
        align(right, smallcaps(hydra(1, book: true)))
      } else {
        align(left, smallcaps(hydra(2, book: true)))
      }
      line(length: 100%)
      counter(footnote).update(0)
    },
  )
  set par(
    leading: 0.55em,
    first-line-indent: 1.8em,
    justify: true,
    linebreaks: "optimized",
  )
  set text(font: "New Computer Modern", spacing: 150%)
  show footnote: set text(spacing: 100%)
  show figure: set text(spacing: 100%)
  show table: set text(spacing: 100%)
  set math.equation(supplement: "Equation", numbering: "(1.1)")
  show: equate.with(breakable: true, sub-numbering: true)

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: "listing"): set figure.caption(position: top)
  set figure(supplement: auto, placement: auto)
  show figure.where(kind: "listing"): fig => {
    align(
      center,
      {
        block(
          width: 100%,
          breakable: false,
          {
            align(center)[#fig.body]
            v(-0.7em)
            set align(left)
            set par(hanging-indent: 0.5cm, justify: true)
            pad(x: 0.5cm)[#fig.caption]
          },
        )
      },
    )
  }
  show figure.caption: caption => {
    let text-width = page.width - page.margin.inside - page.margin.outside
    let caption-width = calc.min(text-width, measure(caption).width)
    block(
      width: caption-width,
      {
        set par(hanging-indent: 0.5cm, justify: true)
        align(left, caption)
      },
    )
  }
  let heading-align = left
  let cell-align = left
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
    if it.children.len() > 0 and it.children.at(it.children.len() - 1) == table.hline() or other_table {
      it
    } else {
      let items = it.fields()
      let children = items.remove("children")
      table(
        ..items,
        ..children,
        table.hline(),
      )
    }
  }
  show raw: set text(font: "New Computer Modern Mono")
  // Else texttt style text in normal backticks is too small
  show raw.where(lang: none, block: false): set text(size: 11pt)

  show par: set block(spacing: 0.55em)
  show heading: set block(above: 1.4em, below: 0.3em)
  show heading: it => {
    set text(font: "New Computer Modern Sans")
    it
    v(1em)
  }
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }
  show heading.where(level: 3): set heading(numbering: none)
  show heading.where(level: 3): set block(above: 1.4em, below: -0.2em)
  show heading.where(level: 4): set heading(numbering: none)
  // show heading.where(level: 4): it => [\ ] + strong(it.body) + [ ]
  show heading.where(level: 4): it => {
    set text(font: "New Computer Modern Sans", spacing: 150%)
    [ \ ] + text(weight: "regular", style: "italic", it.body)
  }
  link-style(print-mode, doc)
}
