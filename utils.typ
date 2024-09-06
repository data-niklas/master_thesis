#import "/template/acronyms.typ": *
#import "@preview/sourcerer:0.2.1": code
#import "@preview/typpuccino:0.1.0": latte, frappe, macchiato, mocha
#import "@preview/oxifmt:0.2.1": strfmt
#import "@preview/cetz:0.2.2"

#let print-mode = true
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
  if print-mode and (
    "print-mode" not in sys.inputs or sys.inputs.at("print-mode") == "true"
  ) {
    return none
  }
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
  evaluations.filter(evaluation => {
    let config = evaluation.at("config")
    if "num_beams" not in config {
      if beams == 1 {
        true
      } else {
        false
      }
    } else {
      config.at("num_beams") == beams
    }
  })
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
#let total-stats(stats) = {
  let full = stats.map(stat => stat.at("full")).sum()
  let partial = stats.map(stat => stat.at("partial")).sum()
  let nil = stats.map(stat => stat.at("none")).sum()
  let error = stats.map(stat => stat.at("error")).sum()
  let total = stats.map(stat => stat.at("total")).sum()


  let stats = (
    "full": full,
    "partial": partial,
    "none": nil,
    "error": error,
    "total": total,
  )
  stats
}
#let average-stats(stats) = {
  let full = stats.map(stat => stat.at("full")).sum()
  let partial = stats.map(stat => stat.at("partial")).sum()
  let nil = stats.map(stat => stat.at("none")).sum()
  let error = stats.map(stat => stat.at("error")).sum()
  let total = stats.map(stat => stat.at("total")).sum()
  let full_p = full / total * 100
  let full_p_f = strfmt("{:.2}", full_p)
  let partial_p = partial / total * 100
  let partial_p_f = strfmt("{:.2}", partial_p)
  let nil_p = nil / total * 100
  let nil_p_f = strfmt("{:.2}", nil_p)
  let error_p = error / total * 100
  let error_p_f = strfmt("{:.2}", error_p)

  let result-stats = (
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
  if "unchanged" in stats.at(0) {
    let unchanged = stats.map(stat => stat.at("unchanged")).sum()
    let unchanged_p = unchanged / total * 100
    let unchanged_p_f = strfmt("{:.2}", unchanged_p)
    result-stats.insert("unchanged", unchanged)
    result-stats.insert("unchanged_p", unchanged_p)
    result-stats.insert("unchanged_p_f", unchanged_p_f)
  }
  result-stats
}
#let fmt-float(number, prefix: false) = {
  let rounded-number = calc.round(number, digits: 2)
  if rounded-number == 0 and prefix {
    sym.plus.minus + str(rounded-number)
  } else if rounded-number > 0 and prefix {
    sym.plus + str(rounded-number)
  } else if rounded-number >= 0 {
    str(rounded-number)
  } else {
    sym.minus + str(rounded-number * -1)
  }
}
#let stats-table(stats, show-total: true, diff: false) = {
  let align = (column, row) => {
    if row == 0 {
      center + horizon
    } else if column == 0 {
      left + horizon
    } else {
      right + horizon

    }
  }
  let header = (
    "Name",
    "Total",
    [Fully\ solved],
    [Partially\ solved],
    [Not\ solved],
    text(hyphenate: false)[Error],
  )
  if not show-total {
    let _ = header.remove(1)
  }
  if diff {
    header += ("Unchanged",)
  }
  let columns = header.len()
  table(
    columns: columns,
    align: align,
    table.header(..header),
    ..stats.map(name-stat => {
      let name = name-stat.at(0)
      let stat = name-stat.at(1)
      let get-stat(key) = {
        let value = stat.at(key)
        if diff and key != "unchanged_p" {
          fmt-float(value, prefix: true)
        } else {
          fmt-float(value, prefix: false)
        }
      }
      let get-p(
        key,
      ) = {
        let key_p = key + "_p"
        if key_p in stat {
          if diff {
            get-stat(key_p) + "%"
          } else {
            get-stat(key_p) + "% (" + get-stat(key) + ")"
          }
        } else {
          get-stat(key)
        }
      }
      let full = get-p("full")
      let partial = get-p("partial")
      let nil = get-p("none")
      let error = get-p("error")
      let result = (name, full, partial, nil, error)
      if show-total {
        let total = stat.at("total")
        let _ = result.insert(1, str(total))
      }
      if diff {
        let unchanged = get-p("unchanged")
        result = result + (unchanged,)
      }
      result
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
#let get-task-stats(evaluations, key: "evaluated_code_llm_lsp") = {
  let tasks = (:)
  for evaluation in evaluations {
    let items = evaluation.at("items")
    for item in items {
      let task = item.at("task_name")
      if task not in tasks {
        tasks.insert(
          task,
          (
            "total": evaluations.len(),
            "full": 0,
            "partial": 0,
            "none": 0,
            "error": 0,
          ),
        )
      }
      let task_stats = tasks.at(task)
      let value = map-evaluated-value(item.at(key))
      task_stats.insert(value, task_stats.at(value) + 1)
      tasks.insert(task, task_stats)
    }
  }
  for task in tasks.keys() {
    // add _p and _p_f values
    let task_stats = tasks.at(task)
    let total = task_stats.at("total")
    let full = task_stats.at(FULL)
    let partial = task_stats.at(PARTIAL)
    let nil = task_stats.at(NONE)
    let error = task_stats.at(ERROR)
    let full_p = full / total * 100
    let full_p_f = strfmt("{:.2}", full_p)
    let partial_p = partial / total * 100
    let partial_p_f = strfmt("{:.2}", partial_p)
    let nil_p = nil / total * 100
    let nil_p_f = strfmt("{:.2}", nil_p)
    let error_p = error / total * 100
    let error_p_f = strfmt("{:.2}", error_p)
    task_stats.insert("full_p", full_p)
    task_stats.insert("full_p_f", full_p_f)
    task_stats.insert("partial_p", partial_p)
    task_stats.insert("partial_p_f", partial_p_f)
    task_stats.insert("none_p", nil_p)
    task_stats.insert("none_p_f", nil_p_f)
    task_stats.insert("error_p", error_p)
    task_stats.insert("error_p_f", error_p_f)
    tasks.insert(task, task_stats)
  }
  tasks
}
#let task-sorted-key(task) = (
  task.at(1).at("full_p"),
  task.at(1).at("partial_p"),
  task.at(1).at("none_p"),
  task.at(1).at("error_p"),
)
#let task-stats-table(task-stats, show-total: true, diff: false) = {
  let final-row = if show-total {
    ("Average", average-stats(task-stats.values()))
  } else {
    ("Total", total-stats(task-stats.values()))
  }
  stats-table(
    show-total: show-total,
    diff: diff,
    task-stats.pairs().sorted(key: task-sorted-key).rev() + (final-row,),
  )
}

#let stats-percentage(stats) = {
  let full = stats.at("full")
  let partial = stats.at("partial")
  let nil = stats.at("none")
  let error = stats.at("error")
  let unchanged = stats.at("unchanged")
  let total = stats.at("total")
  let full_p = full / total * 100
  let full_p_f = strfmt("{:.2}", full_p)
  let partial_p = partial / total * 100
  let partial_p_f = strfmt("{:.2}", partial_p)
  let nil_p = nil / total * 100
  let nil_p_f = strfmt("{:.2}", nil_p)
  let error_p = error / total * 100
  let error_p_f = strfmt("{:.2}", error_p)
  let unchanged_p = unchanged / total * 100
  let unchanged_p_f = strfmt("{:.2}", unchanged_p)
  let stats = (
    "unchanged": unchanged,
    "unchanged_p": unchanged_p,
    "unchanged_p_f": unchanged_p_f,
    "total": total,
    "full": full,
    "partial": partial,
    "none": nil,
    "error": error,
    "full_p": full_p,
    "full_p_f": full_p_f,
    "partial_p": partial_p,
    "partial_p_f": partial_p_f,
    "none_p": nil_p,
    "none_p_f": nil_p_f,
    "error_p": error_p,
    "error_p_f": error_p_f,
  )
  stats
}

#let task-stats-diff(task-stats-new, task-stats-old) = {
  let diff = (:)
  for task in task-stats-new.keys() {
    let new_stats = task-stats-new.at(task)
    let old_stats = task-stats-old.at(task)
    let total = new_stats.at("total")
    let full_diff = new_stats.at(FULL) - old_stats.at(FULL)
    let partial_diff = new_stats.at(PARTIAL) - old_stats.at(PARTIAL)
    let nil_diff = new_stats.at(NONE) - old_stats.at(NONE)
    let error_diff = new_stats.at(ERROR) - old_stats.at(ERROR)
    let full_p_diff = full_diff / total * 100
    let partial_p_diff = partial_diff / total * 100
    let nil_p_diff = nil_diff / total * 100
    let error_p_diff = error_diff / total * 100
    // either total - all positive diffs or sum of all minima between versions
    let unchanged_count = total - (
      full_diff,
      partial_diff,
      nil_diff,
      error_diff,
    ).filter(x => x >= 0).sum()
    let unchanged_p = unchanged_count / total * 100
    let unchanged_p_f = strfmt("{:.2}", unchanged_p)
    diff.insert(
      task,
      (
        "total": total,
        "unchanged": unchanged_count,
        "unchanged_p": unchanged_p,
        "unchanged_p_f": unchanged_p_f,
        "full": full_diff,
        "partial": partial_diff,
        "none": nil_diff,
        "error": error_diff,
        "full_p": full_p_diff,
        "partial_p": partial_p_diff,
        "none_p": nil_p_diff,
        "error_p": error_p_diff,
        "full_p_f": strfmt("{:.2}", full_p_diff),
        "partial_p_f": strfmt("{:.2}", partial_p_diff),
        "none_p_f": strfmt("{:.2}", nil_p_diff),
        "error_p_f": strfmt("{:.2}", error_p_diff),
      ),
    )
  }
  diff
}

#let stats-diff(stats-new, stats-old) = {
  let total = stats-new.at("total")
  let full_diff = stats-new.at("full") - stats-old.at("full")
  let partial_diff = stats-new.at("partial") - stats-old.at("partial")
  let nil_diff = stats-new.at("none") - stats-old.at("none")
  let error_diff = stats-new.at("error") - stats-old.at("error")
  let unchanged_count = total - (
    full_diff,
    partial_diff,
    nil_diff,
    error_diff,
  ).filter(x => x >= 0).sum()
  let unchanged_p = unchanged_count / total * 100
  let unchanged_p_f = strfmt("{:.2}", unchanged_p)
  let full_p_diff = full_diff / total * 100
  let partial_p_diff = partial_diff / total * 100
  let nil_p_diff = nil_diff / total * 100
  let error_p_diff = error_diff / total * 100
  let total = stats-new.at("total")
  let diff = (
    "total": total,
    "unchanged": unchanged_count,
    "full": full_diff,
    "partial": partial_diff,
    "none": nil_diff,
    "error": error_diff,
    "full_p": full_p_diff,
    "partial_p": partial_p_diff,
    "none_p": nil_p_diff,
    "error_p": error_p_diff,
    "full_p_f": strfmt("{:.2}", full_p_diff),
    "partial_p_f": strfmt("{:.2}", partial_p_diff),
    "none_p_f": strfmt("{:.2}", nil_p_diff),
    "error_p_f": strfmt("{:.2}", error_p_diff),
  )
  diff
}

#let total-diff-percentage(evaluations) = {
  stats-percentage(
    stats-diff(
      total-stats(get-task-stats(evaluations).values()),
      total-stats(
        get-task-stats(evaluations, key: "evaluated_code_vanilla").values(),
      ),
    ),
  )
}
#let get-model-name(model) = {
  if model == codellama {
    "CodeLlama"
  } else if model == magicoder {
    "Magicoder"
  } else {
    "MistralHermes"
  }
}
#let stat-name(evaluation, run-name) = {
  let config = evaluation.at("config")
  let sampling-text = if config.at("do_sample") {
    "sampling"
  } else {
    "greedy"
  }
  let beams = if "num_beams" in config {
    config.at("num_beams")
  } else {
    1
  }
  // add sampling and num beams
  let model = evaluation.at("model")
  let model-name = get-model-name(model)
  let name = run-name + " " + model-name + " " + sampling-text + " " + str(beams) + if beams == 1 {
    " beam"
  } else {
    " beams"
  }
  let content-name = [
    #run-name\
    #model-name\
    #sampling-text #beams #{
      if beams == 1 {
        " beam"
      } else {
        " beams"
      }
    }
  ]
  content-name
}

#let debug-best-evaluation(runs-with-name, worst: false, baseline: false) = {
  let best-value = if worst {
    100.0
  } else {
    0.0
  }
  let best-name = ""
  for run in runs-with-name {
    let run-name = run.at(0)
    let evaluations = run.at(1)
    let evaluation-stats = if baseline {
      get-baseline(evaluations)
    } else {
      get-llm-lsp(evaluations)
    }
    let stats = evaluation-stats.map(evaluation => aggregate-stats((
      evaluation,
    )))
    for (i, stat) in stats.enumerate() {
      if (stat.at("full_p") > best-value and not worst) or (
        stat.at("full_p") < best-value and worst
      ) {
        best-value = stat.at("full_p")
        best-name = stat-name(evaluations.at(i), run-name)
      }
    }
  }
  (best-name, best-value)
}

#let debug-best-diff-evaluation(runs-with-name, worst: false) = {
  let best-value = if worst {
    100.0
  } else {
    0.0
  }
  let best-name = ""
  for run in runs-with-name {
    let run-name = run.at(0)
    let evaluations = run.at(1)
    let stats = evaluations.map(evaluation => total-diff-percentage((
      evaluation,
    )))
    for (i, stat) in stats.enumerate() {
      if (stat.at("full_p") > best-value and not worst) or (
        stat.at("full_p") < best-value and worst
      ) {
        best-value = stat.at("full_p")
        let config = evaluations.at(i).at("config")
        best-name = stat-name(evaluations.at(i), run-name)
      }
    }
  }
  (best-name, best-value)
}

#let get-all-stats(runs-with-name) = {
  let stats = ()
  for run in runs-with-name {
    let run-name = run.at(0)
    let evaluations = run.at(1)
    let evaluation-baseline-stats = get-baseline(evaluations)
    let evaluation-llm-lsp-stats = get-llm-lsp(evaluations)
    let baseline-stats = evaluation-baseline-stats.map(evaluation => aggregate-stats((
      evaluation,
    )))
    let llm-lsp-stats = evaluation-llm-lsp-stats.map(evaluation => aggregate-stats((
      evaluation,
    )))
    let evaluation-diff-stats = evaluations.map(evaluation => total-diff-percentage((
      evaluation,
    )))
    for (i, stat) in baseline-stats.zip(
      llm-lsp-stats,
      evaluation-diff-stats,
    ).enumerate() {
      let name = stat-name(evaluations.at(i), run-name)
      stats = stats + ((name, stat),)
    }

  }
  stats
}

#let num-dataset = 25
