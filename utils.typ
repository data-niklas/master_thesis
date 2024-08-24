#import "/template/acronyms.typ": *
#import "@preview/sourcerer:0.2.1": code
#import "@preview/typpuccino:0.1.0": latte, frappe, macchiato, mocha
#import "@preview/oxifmt:0.2.1": strfmt

#let print-mode = false
#let theme = mocha

#let example(body, caption: "") = figure(
  body,
  caption: caption,
  kind: "example",
  supplement: "Example",
  placement: none,
)

#let rq(number) = link(label("rq:" + str(number)))[*RQ#str(number)*]
#let rqdataset(number) = link(
  label("rqdataset:" + str(number)),
)[*RQ#sub[dataset]#str(number)*]
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
        inset: 2.5pt,
        radius: (top-left: 1pt, bottom-left: 1pt, rest: 4pt),
        align(left, strong(smallcaps("todo: ")) + text),
      ),
      kind: "todo",
      supplement: "TODO",
      outlined: true,
      caption: text,
      placement: none,
    ),
    baseline: 2.5pt,
  )
}

#let prompt(body) = {
  set text(size: 11pt, font: "New Computer Modern Mono")
  block(
    stroke: 1pt + luma(180),
    fill: luma(246), // Darker than code blocks by luma of 5
    inset: 5pt,
    radius: 4pt,
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
  // Allow comments in the CSV file
  data = data.filter(row => not row.at(0).trim().starts-with("#"))
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
    radius: 4pt,
    body,
  )
}

#let codefile(file) = {
  let file_content = read(file).trim()
  let path_parts = file.split("/")
  let last_part = path_parts.at(path_parts.len() - 1)
  let id = last_part.split(".").at(0)
  let language_extension = last_part.split(".").at(1)
  let language_mapping = (
    "py": "Python",
    "ts": "TypeScript",
    "json": "JSON",
    "terminal": "Terminal",
  )
  let language = language_mapping.at(language_extension)
  let body = none
  let raw_code = raw(file_content, block: true, lang: language_extension)

  if language_extension == "terminal" {
    body = terminal(raw_code)
  } else {
    body = code(
      raw_code,
      lang: language,
    )

  }
  link(
    "https://data-niklas.github.io/master_thesis/#" + id,
    body,
  )
}

#let sys = box(raw("<<SYS>>"))
#let sys- = box(raw("<</SYS>>"))
#let inst = box(raw("[INST]"))
#let inst- = box(raw("[/INST]"))
#let bos = box(raw("<s>"))
#let eos = box(raw("</s>"))

#let bar(fill-angle, width) = context box(
  width: width,
  fill: color.hsv(fill-angle, 100%, 70%, 20%),
  height: 1em,
  baseline: (1em - measure([T]).height) / 2,
)

#let base-configurations = (
  "greedy",
  "greedy_beams_2",
  "greedy_beams_3",
  "sampling",
  "sampling_beams_2",
  "sampling_beams_3",
)
#let models = (
  "codellama_7b",
  "magicoder_s_ds_6.7b",
  "mistralhermes_codepro_7b",
)
#let model-configurations(model) = {
  let configurations = base-configurations.map(c => model + "_" + c)
  configurations
}
#let FULL = "full"
#let PARTIAL = "partial"
#let NONE = "none"
#let ERROR = "error"
#let map-evaluated-value(value) = {
  if value.at(0) == "error" {
    ERROR
  } else if value.at(0) == 0 and value.at(1) == 0 {
    FULL
  } else if value.at(0) < 2 and value.at(1) < 2 {
    PARTIAL
  } else {
    NONE
  }
}

#let load-evaluation(directory, configuration) = {
  let path = "/assets/evaluations/" + directory + "/" + configuration + ".json"
  let data = json(path)
  data
}
#let load-model-evaluations(directory, model) = {
  let configurations = model-configurations(model)
  let evaluations = ()
  for configuration in configurations {
    let data = load-evaluation(directory, configuration)
    evaluations = evaluations + (data,)
  }
  evaluations
}
#let load-evaluations(directory) = {
  let evaluations = ()
  for model in models {
    let model_evaluations = load-model-evaluations(directory, model)
    evaluations = evaluations + model_evaluations
  }
  evaluations
}
#let filter-evaluations(evaluations, filter) = {
  evaluations.map(evaluation => evaluation.filter(filter))
}
#let codellama = "codellama/CodeLlama-7b-Instruct-hf"
#let magicoder = "ise-uiuc/Magicoder-S-DS-6.7B"
#let codestral = "beowolx/MistralHermes-CodePro-7B-v1"
#let filter-evaluations-by-model(evaluations, model) = {
  evaluations.filter(evaluation => evaluation.at("model") == model)
}
#let filter-evaluations-by-sampling(evaluations, sampling) = {
  evaluations.filter(evaluation => evaluation.at("config").at("do_sample") == sampling)
}
#let filter-evaluations-by-beams(evaluations, beams) = {
  evaluations.filter(evaluation => evaluation.at("config").at("num_beams") == beams)
}
#let filter-items(evaluations, key, value) = {
  evaluations.map(evaluation => {
    let items = evaluation.at("items")
    evaluation.insert("items", items.filter(item => item.at(key) == value))
    evaluation
  })
}
#let filter-items-by-kind(evaluations, kind) = {
  filter-items(evaluations, "kind", kind)
}
#let filter-items-by-modification-kind(evaluations, kind) = {
  filter-items(evaluations, "modification_kind", kind)
}
#let filter-items-by-code-kind(evaluations, kind) = {
  filter-items(evaluations, "code_kind", kind)
}
#let get-baseline(evaluations) = {
  evaluations.map(evaluation => evaluation.at("items").map(item => item.at("evaluated_code_vanilla")))
}
#let get-llm-lsp(evaluations) = {
  evaluations.map(evaluation => evaluation.at("items").map(item => item.at("evaluated_code_llm_lsp")))
}
#let aggregate-stats(evaluation-selections) = {
  evaluation-selections = evaluation-selections.map(evaluation => evaluation.map(item => map-evaluated-value(item)))
  let total = evaluation-selections.map(selection => selection.len()).sum()
  let full = evaluation-selections.map(selection => selection.filter(value => value == FULL).len()).sum()
  let partial = evaluation-selections.map(selection => selection.filter(value => value == PARTIAL).len()).sum()
  let nil = evaluation-selections.map(selection => selection.filter(value => value == NONE).len()).sum()
  let error = evaluation-selections.map(selection => selection.filter(value => value == ERROR).len()).sum()
  let full_p = full / total * 100
  let full_p_f = strfmt("{:.2}", full_p)
  let partial_p = partial / total * 100
  let partial_p_f = strfmt("{:.2}", partial_p)
  let nil_p = nil / total * 100
  let nil_p_f = strfmt("{:.2}", nil_p)
  let error_p = error / total * 100
  let error_p_f = strfmt("{:.2}", error_p)

  let stats = (
    "total": total,
    "full": full,
    "partial": partial,
    "none": nil,
    "error": error,
    "full_p": full_p,
    "partial_p": partial_p,
    "none_p": nil_p,
    "error_p": error_p,
    "full_p_f": full_p_f,
    "partial_p_f": partial_p_f,
    "none_p_f": nil_p_f,
    "error_p_f": error_p_f,
  )
  stats
}
#let average-stats(stats) = {
  let total = stats.map(stat => stat.at("total")).sum()
  let full = stats.map(stat => stat.at("full")).sum()
  let partial = stats.map(stat => stat.at("partial")).sum()
  let nil = stats.map(stat => stat.at("none")).sum()
  let error = stats.map(stat => stat.at("error")).sum()
  let full_p = full / total * 100
  let full_p_f = strfmt("{:.2}", full_p)
  let partial_p = partial / total * 100
  let partial_p_f = strfmt("{:.2}", partial_p)
  let nil_p = nil / total * 100
  let nil_p_f = strfmt("{:.2}", nil_p)
  let error_p = error / total * 100
  let error_p_f = strfmt("{:.2}", error_p)

  let stats = (
    "total": total,
    "full": full,
    "partial": partial,
    "none": nil,
    "error": error,
    "full_p": full_p,
    "partial_p": partial_p,
    "none_p": nil_p,
    "error_p": error_p,
    "full_p_f": full_p_f,
    "partial_p_f": partial_p_f,
    "none_p_f": nil_p_f,
    "error_p_f": error_p_f,
  )
  stats
}
#let stats-table(stats) = {
  table(
    columns: 6,
    align: (left, right, right, right, right, right),
    table.header(..(
      "Name",
      "Total",
      "Fully solved",
      "Partially Solved",
      "Not solved",
      "Error",
    )),
    ..stats.map(name-stat => {
      let name = name-stat.at(0)
      let stat = name-stat.at(1)
      let get-p(
        key,
      ) = stat.at(key + "_p_f") + "% (" + str(stat.at(key)) + ")"
      let total = stat.at("total")
      let full = get-p("full")
      let partial = get-p("partial")
      let nil = get-p("none")
      let error = get-p("error")
      (name, str(total), full, partial, nil, error)
    }).flatten(),
  )
}
#let highlight-cells(
  cells: (),
  body,
) = {
  show table.cell: it => {
    if cells.any(cell => cell == (it.x, it.y)) {
      strong(it)
    } else {
      it
    }
  }

  body
}
#let num-dataset = 25

