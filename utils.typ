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
