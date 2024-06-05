#import "@preview/acrostiche:0.3.1": *
#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper

// Overwrite the default `smallcaps` and `upper` functions with increased spacing between
// characters. Default tracking is 0pt.
#let smallcaps(body) = std-smallcaps(text(tracking: 0.6pt, body))
#let upper(body) = std-upper(text(tracking: 0.6pt, body))

#let title-page(
  title: "",
  author: (),
  date: none
) = {
  let smallskip = 3pt
  let Large = 14.4pt
  let large = 12pt
  let huge = 20.74pt
  // Title page.
  // The page can contain a logo if you pass one with `logo: "logo.png"`.
  place(top+right, image("assets/logo.png", width: 3.8cm, height: 2cm))
  v(1cm)
  align(center, {
    //set par    
    set text(font: "New Computer Modern Sans")
    set text(size: Large)
    v(3cm)
    [*Ruprecht-Karls-Universität Heidelberg*]
    v(smallskip)
    [*Institute of Computer Science*]
    v(smallskip)
    [*Artificial Intelligence for Programming (AIP)*]
    v(smallskip)
    v(3cm)
    text(weight: "bold", size: large)[Master's Thesis]
    [\ #v(smallskip - 1.2em)
    ]
    text(size: huge, title)
  })
  //v(0.65em)
  place(dx: 2cm, dy: 8cm, {
    set text(size: large)
    align(center, 
    table(
      columns: (auto, auto),
      align: left,
      stroke: none,
      column-gutter: 4pt,
      row-gutter: 1pt,
      [Name:], author,
      [Matrikelnummer:], [3737339],
      [Betreuer:], link("https://aip.ifi.uni-heidelberg.de/team/aa", "Prof. Dr. Artur Andrzejak"),
      [Datum der Abgabe], [30.09.2024]
    ))
  })
  pagebreak()
}


#let i-did-not-cheat-i-swear(date: none) = {
  set page(header: none, footer: none)
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  v(100pt)
  [I hereby certify that I have written the work myself and that I have not used any sources
or aids other than those specified and that I have marked what has been taken over from
other people’s works, either verbatim or in terms of content, as foreign. I also certify
that the electronic version of my thesis transmitted completely corresponds in content
and wording to the printed version. I agree that this electronic version is being checked
for plagiarism at the university using plagiarism software.]
  v(50pt)
  line(length: 6cm, stroke: 0.02cm + black)
  [Heidelberg, #date]
  pagebreak(to: "odd", weak: true)
}

#let show-abstract(abstract) = {
    align(horizon, move(dy: -(12pt + 1cm), pad(1.5cm)[
      #align(center, text(weight: "bold", size: 12pt)[Abstract])
      #v(1cm)
      #abstract
    ]))
    pagebreak(weak: true)
}

#let project(
  title: "",
  abstract: [],
  author: (),
  date: none,
  acronyms: (:),
  body,
) = {
  // Set the document's basic properties.
  set text(font: "New Computer Modern Sans", lang: "en")
  set document(author: author, title: title)
  set heading(numbering: "I")
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
  show heading.where(level: 4): set heading(numbering: none)
  show heading.where(level: 5): set heading(numbering: none)
  show math.equation: set text(weight: 400)
  title-page(title: title, author: author, date: date)
  set page(numbering: "I", number-align: center)
  i-did-not-cheat-i-swear(date: date)
  set par(leading: 1em)
  set text(spacing: 150%) // Space text to make it readable (\onehalfspacing)
  // Apparently in LaTeX the spacing is not applied to the following elements
  show footnote: set text(spacing: 100%)
  show figure: set text(spacing: 100%)
  show table: set text(spacing: 100%)
  show link: it => {
    // Workaround for ctheorems package so that its labels keep the default link styling.
    if type(it.dest) == label { return it }
    it
    h(1.6pt)
    super(box(height: 3.8pt, circle(radius: 1.2pt, stroke: 0.7pt + rgb("#993333"))))
  }
  show-abstract(abstract)



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
  print-index(outlined: false, title: "Acronyms")
  pagebreak()

  show heading: set block(
below: 0.85em, 
  above: 1.75em
)
  // Main body.
  // Reset numbering and start counting at 1
  set page(numbering: "1", number-align: center)
  counter(page).update(x => 1)
  // Reset heading styles
  set heading(numbering: "1.1")
  counter(heading).update(0)
  set par(justify: true)
  set text(font: "New Computer Modern", lang: "en")

  body
}
