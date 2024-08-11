#let title-page(
  title: "",
  author: (),
  matriculation-number: "",
  date-of-submission: none,
  supervisor: "",
  supervisor-link: ""
) = {
  let smallskip = 3pt
  let Large = 14.4pt
  let large = 12pt
  let huge = 20.74pt
  page(
    margin: 2.5cm,
    header: none,
    {
      v(1cm)
      align(
        center,
        {
          //set par
          set text(font: "New Computer Modern Sans")
          set text(size: Large)
          v(1cm)
          [*Heidelberg University*]
          v(smallskip)
          [*Institute of Computer Science*]
          v(smallskip)
          [*Artificial Intelligence for Programming (AIP)*]
          v(smallskip)
          v(2cm)
          text(weight: "bold", size: large)[Master's Thesis]
          v(smallskip)
          box(
            width: 300pt,
            text(
              size: huge,
              hyphenate: false,
              title,
            ),
          )
        },
      )
      v(2cm)
      place(
        dx: 1cm,
        dy: 8cm,
        {
          set text(size: large)
          align(
            center,
            table(
              columns: (auto, auto),
              align: left,
              stroke: none,
              column-gutter: 4pt,
              row-gutter: 1pt,
              [Name:],
              author,
              [Matrikelnummer:],
              matriculation-number,
              [Betreuer:],
              link(
                supervisor-link,
                supervisor,
              ),
              [Datum der Abgabe],
              date-of-submission.display(),
            ),
          )
        },
      )
    },
  )
}
