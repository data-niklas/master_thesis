#import "acronyms.typ": print-index, init-acronyms
#import "1_title_page.typ": title-page
#import "2_i_did_not_cheat_i_swear.typ": i-did-not-cheat-i-swear
#import "3_abstract.typ": show-abstract
#import "styling.typ": style
#import "@preview/codetastic:0.2.2": qrcode

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
  abstract-de: "",
  thesis-repo: none,
  appendix: none,
) = {
  show: doc => {
    style(doc)
  }
  // Set the document's basic properties.
  set document(author: author, title: title)
  init-acronyms(acronyms)
  set heading(numbering: "I")
  title-page(
    title: title,
    author: author,
    date: date,
    matriculation-number: matriculation-number,
    date-of-submission: date-of-submission,
  )
  set page(numbering: "I", number-align: center)
  i-did-not-cheat-i-swear(author)
  // set text(spacing: 150%) // Space text to make it readable (\onehalfspacing)
  // // Apparently in LaTeX the spacing is not applied to the following elements
  // show footnote: set text(spacing: 100%)
  // show figure: set text(spacing: 100%)
  // show table: set text(spacing: 100%)
  show-abstract(abstract-en, "English")
  show-abstract(abstract-de, "German")



  // Table of contents.

  {
    set page(header: none)
    show outline.entry.where(level: 1): it => {
      v(14pt, weak: true)
      strong(it)
    }
    outline(depth: 2, indent: auto)
  }
  set page(numbering: "1", number-align: center)
  pagebreak(weak: true)

  // Main body.
  // Reset numbering and start counting at 1
  counter(page).update(x => 1)
  // Reset heading styles
  set heading(numbering: "1.1")
  counter(heading).update(0)

  body
  set page(header: none)
  counter(heading).update(0)
  set heading(numbering: none, outlined: true)
  show outline: it => {
    show ref: it => none
    it
  }
  show bibliography: set heading(numbering: none)

  print-index(outlined: true, title: "Acronyms")

  bibliography(bibliography-file)
  show outline: set heading(numbering: none, outlined: true, level: 2)

  heading()[Listings]
  outline(
    title: [List of Figures],
    target: figure.where(kind: image),
  )
  // TODO: remove bold text
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

  pagebreak(weak: true)
  appendix
  pagebreak(weak: true)
  if thesis-repo != none {
    align(
      center + horizon,
      {
        align(center, text(size: 14pt, smallcaps("QR code")))
        v(10pt)
        figure(
          qrcode(thesis-repo),
          caption: [
            Scan the QR code to access the source code of this thesis:\ ] + link(thesis-repo),
          supplement: none,
          kind: "",
        )
      },
    )
  }
}
