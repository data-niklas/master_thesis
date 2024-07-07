#import "/template/acronyms.typ": *
#import "@preview/sourcerer:0.2.1": code
#let example(body, caption: "") = figure(
  body,
  caption: caption,
  kind: "example",
  supplement: "Example",
)

#let note(note-text, body) = {
  let sidenote = footnote(text(stroke: purple, "Note: ") + note-text)
  underline(
    stroke: (paint: red, thickness: 2pt, dash: "dashed", cap: "round"),
    offset: 2pt,
    body + sidenote,
  )
}

#let rq(number) = link(label("rq:" + str(number)))[*RQ#str(number)*]
#let r(number) = link(label("r:" + str(number)))[*R#str(number)*]
#let ribms(number) = link(
  label("ribms:" + str(number)),
)[*R#sub[IBMS]#str(number)*]
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
  figure(
    block(
      fill: rgb("#d7fff1"),
      stroke: (
        left: 2pt + rgb("#219d73"),
      ),
      width: 100%,
      inset: 4pt,
      radius: 4pt,
      align(left, "TODO: " + text),
    ),
    kind: "todo",
    supplement: "TODO",
    outlined: true,
    caption: text,
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
