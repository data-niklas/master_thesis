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

// Similar to column, but sets a fixed height to force the element to use the columns
#let spread(count, has-header: false, body) = context {
  let header-height = 0pt
  if has-header {
    header-height = measure(table(table.header([hi]))).height
  }
  let height = ((measure(body).height - header-height) / count) + header-height
  box(
    columns(count, body),
    height: height,
  )
}

#let highlight(
  lines,
  max-width: false,
  padding: 0pt,
  bg: color.hsv(300deg, 100%, 70%, 20%),
  body,
) = {
  let attrs = (:)
  if max-width {
    attrs.insert("width", 100%)
  }
  show raw.line: line => {
    if lines.contains(line.number) and line.count > 1 {
      box(
        line,
        fill: bg,
        ..attrs,
        height: measure(line).height + padding * 2,
        inset: (top: padding),
      )
    } else {
      line
    }
  }
  set table(fill: (x, y) => {
    if lines.contains(y) {
      bg
    }
  })
  body
}

#let csvtable(settings: (:), delimiter: ",", file) = {
  let data = csv(delimiter: delimiter, file)
  let header = data.remove(0)
  table(
    columns: data.at(0).len(),
    ..settings,
    table.header(..header.map(strong)),
    ..data.flatten(),
  )
}
