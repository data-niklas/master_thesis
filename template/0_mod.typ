#import "acronyms.typ": print-index, init-acronyms
#import "1_title_page.typ": title-page
#import "2_i_did_not_cheat_i_swear.typ": i-did-not-cheat-i-swear
#import "3_abstract.typ": show-abstract
#import "styling.typ": style, hydra-header
#import "generate_bib.typ": generate_bib_entry

#import "@preview/codetastic:0.2.2": qrcode

#let assert-type(value, t, message) = assert.eq(
  type(value),
  t,
  message: message,
)

#let assert-types(
  title,
  abstract,
  author,
  print-mode,
  acronyms,
  bibliography-file,
  matriculation-number,
  date-of-submission,
  thesis-repo,
) = {
  assert-type(title, str, "Title must be a str")
  assert-type(author, str, "Author must be a str")
  assert-type(print-mode, bool, "Print mode must be a boolean")
  assert-type(acronyms, dictionary, "Acronyms must be a dictionary")
  assert-type(bibliography-file, str, "Bibliography file must be a str")
  assert-type(
    matriculation-number,
    str,
    "Matriculation number must be a str",
  )
  assert-type(
    date-of-submission,
    datetime,
    "Date of submission must be a datetime",
  )
  assert-type(thesis-repo, str, "Thesis repository must be a str")

}

#let project(
  title: "",
  abstract: [],
  author: "",
  print-mode: false,
  acronyms: (:),
  body,
  bibliography-file: none,
  matriculation-number: "",
  date-of-submission: datetime.today(),
  date-of-signature: datetime.today(),
  abstract-en: "",
  abstract-de: "",
  thesis-repo: none,
  appendix: none,
  link-style-exception-cb: it => false,
  supervisor: "",
  supervisor-link: "",
) = {
  // Allows overwriting the print-mode when writing the thesis, while building the PDF using whatever default is used else
  if "print-mode" in sys.inputs {
    print-mode = json.decode(sys.inputs.at("print-mode"))
  }
  assert-types(
    title,
    abstract,
    author,
    print-mode,
    acronyms,
    bibliography-file,
    matriculation-number,
    date-of-submission,
    thesis-repo,
  )
  show: doc => {
    style(print-mode, link-style-exception-cb, doc)
  }
  // Set the document's basic properties.
  set document(author: author, title: title)
  init-acronyms(acronyms)
  set heading(numbering: "I")
  context if query(figure.where(kind: "todo")).len() > 0 and not print-mode {
    outline(
      title: [TODOS],
      target: figure.where(kind: "todo"),
    )
  }
  title-page(
    title: title,
    author: author,
    matriculation-number: matriculation-number,
    date-of-submission: date-of-submission,
    supervisor: supervisor,
    supervisor-link: supervisor-link,
    print-mode: print-mode,
  )
  set page(numbering: "I", number-align: center)
  i-did-not-cheat-i-swear(author, print-mode, date-of-signature)
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
  set page(header: hydra-header)
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
  // Do not show the different listings in the main Table of Contents
  show outline: set heading(outlined: false)
  outline(
    title: [List of Figures],
    target: figure.where(kind: image),
  )
  pagebreak(weak: true)
  // TODO: remove bold text
  outline(
    title: [List of Tables],
    target: figure.where(kind: table),
  )
  pagebreak(weak: true)
  outline(
    title: [List of Code],
    target: figure.where(kind: raw),
  )
  pagebreak(weak: true)
  outline(
    title: [List of Examples],
    target: figure.where(kind: "example"),
  )
  show outline: set heading(outlined: true)

  pagebreak(weak: true)
  set figure(supplement: auto, placement: none)
  show figure.where(kind: table): set figure.caption(position: bottom)
  set heading(
    numbering: (..nums) => if nums.pos().len() < 2 {
      none
    } else {
      numbering("A", nums.pos().at(1))
    },
    outlined: true,
  )
  appendix
  set page(header: none)
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
        if not print-mode {
          v(23%)

          align(center, text(size: 14pt, smallcaps("Cite this thesis:")))
          generate_bib_entry(title, author, thesis-repo, date-of-submission)
        }
      },
    )
  }
}
