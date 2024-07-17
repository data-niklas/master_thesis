#import "/template/acronyms.typ": *
#import "@preview/sourcerer:0.2.1": code
#import "@preview/typpuccino:0.1.0": latte, frappe, macchiato, mocha

#let theme = mocha

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
        inset: 2pt,
        radius: (top-left: 1pt, bottom-left: 1pt, rest: 4pt),
        align(left, strong(smallcaps("todo: ")) + text),
      ),
      kind: "todo",
      supplement: "TODO",
      outlined: true,
      caption: text,
      placement: none,
    ),
    baseline: 2pt,
  )
}

#let prompt(body) = {
  set text(size: 11pt, font: "New Computer Modern Mono")
  block(
    stroke: 1pt + luma(180),
    fill: luma(246), // Darker than code blocks by luma of 5
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
  let path_parts = file.split("/")
  let id = path_parts.at(path_parts.len() - 1).split(".").at(0)
  link(
    "https://data-niklas.github.io/master_thesis/#" + id,
    table(
      columns: data.at(0).len(),
      ..settings,
      table.header(..header.map(strong)),
      ..data.flatten(),
    ),
  )
}

#let terminal(body) = {
  let background = theme.base
  let foreground = theme.text
  let colors = theme.color-entries
  show raw: set text(
    font: "FiraCode Nerd Font Mono",
    size: 9pt,
    fill: foreground,
  )
  show raw.line: line => {
    let styles = ("normal", "italic", "oblique")
    let weights = (
      "thin",
      "extralight",
      "light",
      "regular",
      "medium",
      "semibold",
      "bold",
      "extrabold",
      "black",
    )
    let names = (colors.keys() + styles + weights)
    let whitespace = "\\s*"
    let names-list = "(" + names.join("|") + ")"
    let style-list = "(" + names-list + "(," + whitespace + names-list + ")*" + ")"
    let foreground-regex = regex("\\[" + style-list + "\\]")
    let matches = line.text.matches(foreground-regex)
    let items = []
    let current-color = foreground
    let current-style = "normal"
    let current-weight = "regular"
    let previous-end = 0
    for match in matches {
      items = items + text(
        fill: current-color,
        style: current-style,
        weight: current-weight,
        line.text.slice(previous-end, match.start),
      )
      previous-end = match.end
      let names = match.captures.at(0).split(",").map(s => s.trim())
      for name in names {
        if styles.contains(name) {
          current-style = name
        } else if weights.contains(name) {
          current-weight = name
        } else {
          current-color = colors.at(name)
        }

      }
    }
    items = items + text(
      fill: current-color,
      style: current-style,
      weight: current-weight,
      line.text.slice(previous-end, line.text.len()),
    )
    items
  }
  block(
    stroke: 1pt + luma(180),
    fill: background,
    inset: 5pt,
    radius: 6pt,
    body,
  )
}
