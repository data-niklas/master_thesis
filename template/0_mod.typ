#import "acronyms.typ": print-index, init-acronyms
#import "1_title_page.typ": title-page
#import "2_i_did_not_cheat_i_swear.typ": i-did-not-cheat-i-swear
#import "3_abstract.typ": show-abstract


#let project(
  title: "",
  abstract: [],
  author: (),
  date: none,
  acronyms: (:),
  body,
  bibliography-file: none,
  matriculation-number: "",
  date-of-submission: "",
  abstract-en: "",
  abstract-de: ""
) = {
set page(margin: (
  outside: 2.7cm,
  inside: 2.5cm,
  top: 2.5cm,
  bottom: 2.5cm,
))
set cite(style: "association-for-computing-machinery")
set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
set text(font: "New Computer Modern", spacing: 150%)
show footnote: set text(spacing: 100%)
show figure: set text(spacing: 100%)
show table: set text(spacing: 100%)
show raw: set text(font: "New Computer Modern Mono")
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
show heading.where(level: 4): set block(above: 1.4em, below: -0.2em)
show heading.where(level: 5): set heading(numbering: none)
show heading.where(level: 5): set block(above: 1.4em, below: -0.2em)
  // Set the document's basic properties.
  set document(author: author, title: title)
  set heading(numbering: "I")
  title-page(title: title, author: author, date: date, matriculation-number: matriculation-number, date-of-submission: date-of-submission)
  set page(numbering: "I", number-align: center)
  i-did-not-cheat-i-swear(author)
  // set text(spacing: 150%) // Space text to make it readable (\onehalfspacing)
  // // Apparently in LaTeX the spacing is not applied to the following elements
  // show footnote: set text(spacing: 100%)
  // show figure: set text(spacing: 100%)
  // show table: set text(spacing: 100%)
  // show link: it => {
  //   // Workaround for ctheorems package so that its labels keep the default link styling.
  //   if type(it.dest) == label { return it }
  //   it
  //   h(1.6pt)
  //   super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))))
  // }
  show-abstract(abstract-en, "English")
  show-abstract(abstract-de, "German")



  // Table of contents.
    show outline.entry.where(
    level: 1
  ): it => {
    v(14pt, weak: true)
    strong(it)
  }
  outline(depth: 2, indent: auto)
  pagebreak()
  init-acronyms(acronyms)

  // Main body.
  // Reset numbering and start counting at 1
  set page(numbering: "1", number-align: center)
  counter(page).update(x => 1)
  // Reset heading styles
  set heading(numbering: "1.1")
  counter(heading).update(0)

  body
  show outline: set heading(numbering: "I")
  show bibliography: set heading(numbering: "I")
  bibliography(bibliography-file)
  outline(
    title: [List of Figures],
    target: figure.where(kind: image),
  )
  outline(
    title: [List of Tables],
    target: figure.where(kind: table),
  )
  outline(
    title: [List of Code],
    target: figure.where(kind: raw),
  )
  outline(
    title: [List of Examples],
    target: figure.where(kind: "example"),
  )

  print-index(outlined: false, title: "Acronyms")
  pagebreak()
}
