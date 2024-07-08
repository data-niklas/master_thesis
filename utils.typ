#import "/template/acronyms.typ": *
#import "@preview/sourcerer:0.2.1": code
#let example(body, caption: "") = figure(
  body,
  caption: caption,
  kind: "example",
  supplement: "Example",
)

#let rq(number) = link(label("rq:" + str(number)))[*RQ#str(number)*]
#let r(number) = link(label("r:" + str(number)))[*R#str(number)*]
#let ribms(number) = link(
  label("ribms:" + str(number)),
)[*R#sub[IBMS]#str(number)*]
#let rdataset(number) = link(
  label("rdataset:" + str(number)),
)[*R#sub[dataset]#str(number)*]
#let thought(body) = align(
  center,
  block(
    fill: luma(250),
    stroke: 1pt + luma(180),
    radius: 6pt,
    outset: 7pt,
    spacing: 20pt,
    width: 90%,
    align(left, body),
  ),
)

#let todo(text) = {
  show figure.caption: it => []
  box(
    figure(
      box(
        fill: rgb("#d7fff1"),
        stroke: (
          left: 2pt + rgb("#219d73"),
        ),
        inset: 4pt,
        radius: 4pt,
        align(left, "TODO: " + text),
      ),
      kind: "todo",
      supplement: "TODO",
      outlined: true,
      caption: text,
      placement: none,
    ),
  )
}

#let prompt(body) = {
  set text(size: 11pt, font: "New Computer Modern Mono")
  block(
    stroke: 1pt + luma(180),
    fill: luma(250),
    inset: 5pt,
    radius: 6pt,
    align(left, body),
  )
}
