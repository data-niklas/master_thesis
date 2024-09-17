#import "/utils.typ": *
#import "/plot.typ": *
#import "/eval.typ": *

#let masking = load-evaluations("2024-08-27-masking")
#let default = load-evaluations("2024-08-26-default")
#let use-completions = load-evaluations("2024-08-28-use-completions")
#let all-results = masking + default + use-completions
#let raw-copilot = load-evaluation("2024-08-23", "copilot")
#let copilot = aggregate-stats(
  get-baseline((raw-copilot,)),
)
#let masking-baseline = aggregate-stats(get-baseline(masking))
#let masking-llm-lsp = aggregate-stats(get-llm-lsp(masking))
#let default-baseline = aggregate-stats(get-baseline(default))
#let default-llm-lsp = aggregate-stats(get-llm-lsp(default))
#let use-completions-baseline = aggregate-stats(get-baseline(use-completions))
#let use-completions-llm-lsp = aggregate-stats(get-llm-lsp(use-completions))
#let dependency-stats = json("/assets/evaluations/dependency_stats.json")

#let codellama-evaluations = filter-evaluations-by-model(
  default,
  codellama,
) + filter-evaluations-by-model(
  masking,
  codellama,
) + filter-evaluations-by-model(use-completions, codellama)
#let codellama-baseline-stats = aggregate-stats(
  get-baseline(codellama-evaluations),
)
#let codellama-llm-lsp = aggregate-stats(get-llm-lsp(codellama-evaluations))
#let magicoder-evaluations = filter-evaluations-by-model(
  default,
  magicoder,
) + filter-evaluations-by-model(
  masking,
  magicoder,
) + filter-evaluations-by-model(use-completions, magicoder)
#let magicoder-llm-lsp = aggregate-stats(get-llm-lsp(magicoder-evaluations))
#let magicoder-baseline-stats = aggregate-stats(
  get-baseline(magicoder-evaluations),
)
#let codestral-evaluations = filter-evaluations-by-model(
  default,
  codestral,
) + filter-evaluations-by-model(
  masking,
  codestral,
) + filter-evaluations-by-model(use-completions, codestral)
#let codestral-llm-lsp = aggregate-stats(get-llm-lsp(codestral-evaluations))
#let codestral-baseline-stats = aggregate-stats(
  get-baseline(codestral-evaluations),
)

#let sampling-evaluations = filter-evaluations-by-sampling(
  default,
  true,
) + filter-evaluations-by-sampling(
  masking,
  true,
) + filter-evaluations-by-sampling(use-completions, true)
#let sampling-llm-lsp = aggregate-stats(get-llm-lsp(sampling-evaluations))
#let sampling-baseline = aggregate-stats(get-baseline(sampling-evaluations))
#let no-sampling-evaluations = filter-evaluations-by-sampling(
  default,
  false,
) + filter-evaluations-by-sampling(
  masking,
  false,
) + filter-evaluations-by-sampling(use-completions, false)
#let no-sampling-llm-lsp = aggregate-stats(get-llm-lsp(no-sampling-evaluations))
#let no-sampling-baseline = aggregate-stats(
  get-baseline(no-sampling-evaluations),
)

#let one-beam-evaluations = filter-evaluations-by-beams(
  default,
  1,
) + filter-evaluations-by-beams(
  masking,
  1,
) + filter-evaluations-by-beams(use-completions, 1)
#let one-beam-llm-lsp = aggregate-stats(get-llm-lsp(one-beam-evaluations))
#let one-beam-baseline = aggregate-stats(get-baseline(one-beam-evaluations))
#let two-beams-evaluations = filter-evaluations-by-beams(
  default,
  2,
) + filter-evaluations-by-beams(
  masking,
  2,
) + filter-evaluations-by-beams(use-completions, 2)
#let two-beams-llm-lsp = aggregate-stats(get-llm-lsp(two-beams-evaluations))
#let two-beams-baseline = aggregate-stats(get-baseline(two-beams-evaluations))
#let three-beams-evaluations = filter-evaluations-by-beams(
  default,
  3,
) + filter-evaluations-by-beams(
  masking,
  3,
) + filter-evaluations-by-beams(use-completions, 3)
#let three-beams-llm-lsp = aggregate-stats(get-llm-lsp(three-beams-evaluations))
#let three-beams-baseline = aggregate-stats(
  get-baseline(three-beams-evaluations),
)
#let all-stats = get-all-stats((
  ("Default", default),
  ("Masking", masking),
  ("Use Completions", use-completions),
))
#let count-array-entries(list, to-str: str) = {
  let counter = (:)
  let map = (:)
  for item in list {
    map.insert(to-str(item), item)
    counter.insert(to-str(item), counter.at(to-str(item), default: 0) + 1)
  }
  counter.pairs().map(item => (
    map.at(item.at(0)),
    item.at(1),
  )).sorted(key: item => item.at(1)).rev()
}
#let create-groupings(items) = {
  (
    "total": items.len(),
    "by-task": count-array-entries(
      items.map(item => item.at("task-name")),
      to-str: item => item,
    ),
    "by-model": count-array-entries(
      items.map(item => get-model-name(item.at("evaluation").at("model"))),
      to-str: item => item,
    ),
    "by-beams": count-array-entries(
      items.map(item => item.at("evaluation").at("config").at(
        "num_beams",
        default: 1,
      )),
      to-str: item => str(item),
    ),
    "by-sampling": count-array-entries(
      items.map(item => item.at("evaluation").at("config").at(
        "do_sample",
        default: false,
      )),
      to-str: item => if item {
        "true"
      } else {
        "false"
      },
    ),
    "by-approach": count-array-entries(
      items.map(item => item.at("approach")),
      to-str: item => item,
    ),
    "errors-generation": count-array-entries(
      items.map(i => i.at("generation-error_llm_lsp")).filter(i => i != none),
    ),
    "errors-evaluation": count-array-entries(
      items.map(i => i.at("evaluation-error_llm_lsp")).filter(i => i != none),
    ),
  )
}

#let INDENT = "    "
#let errors = {
  // get all llm_lsp data

  let INDENT = "    "
  let item-code(item) = {
    let code = item.at("import_statements").join("\n") + "\n\n"
    if item.at("context") != "" {
      code += item.at("context") + "\n\n"
    }
    code += item.at("function_signature") + "\n" + INDENT + item.at("function_documentation") + "\n"
    code
  }

  let error-regex = regex("[a-zA-Z]+Error")
  let raise-regex = regex("raise [a-zA-Z]+Error")
  let traceback-regex = regex("Traceback \\(most recent call last\\):")
  let find-error(text) = {
    if text.find(traceback-regex) == none {
      none
    } else {
      text.find(error-regex)
    }
  }
  let error-item-map-k(evaluation, item, key) = {
    let evaluated_key = "evaluated_code_" + key
    let generated_key = "generated_code_" + key
    let evaluation_error_key = "evaluation_error_" + key
    let is-error = (
      item.at(evaluated_key).at(0) != 0 or item.at(evaluated_key).at(1) != 0
    ) and item.at(evaluated_key).at(0) != "error"
    let generated_code = item.at(generated_key)
    let generation-error = find-error(generated_code)
    let evaluation-error = if generation-error != none or evaluation_error_key not in item {
      none
    } else {
      item.at(evaluation_error_key).find(error-regex)
    }
    let found-error = generation-error != none or evaluation-error != none
    let task-name = item.at("task_name")
    let matching = not (not is-error and found-error) or (
      is-error and not found-error
    )
    let code-text = item-code(item) + item.at(generated_key) + "\n" + item.at("test_code")
    (
      "is-error_"+key: is-error,
      key + "_error": item.at(evaluated_key),
      "generation-error_" + key: generation-error,
      "evaluation-error_" + key: evaluation-error,
      "task-name": task-name,
      "matching_" + key: matching,
      "evaluation-error-text_" + key: if evaluation_error_key in item {
        item.at(evaluation_error_key)
      } else {
        none
      },
      "code_" + key: code-text,
      // "code-block": code(raw(block: true, lang: "py", code-text)),
      // "evaluation-name": stat-name(evaluation, "maybe"),
      "evaluation": evaluation
    )

  }
  let error-item-map(evaluation, item) = {
    error-item-map-k(evaluation, item, "llm_lsp") + error-item-map-k(
      evaluation,
      item,
      "vanilla",
    )
  }
  let calc-errors(
    evaluations,
    name,
  ) = evaluations.map(evaluation => evaluation.at("items").map(item => error-item-map(
    evaluation,
    item,
  ))).flatten().map(item => {
    item.insert("approach", name)
    item
  })
  let errors = calc-errors(default, "default") + calc-errors(
    masking,
    "masking",
  ) + calc-errors(
    use-completions,
    "use-completions",
  )
  errors
}
#let approach-generation-errors = errors.filter(item => item.at("generation-error_llm_lsp") != none)
#let approach-generation-error-groups = create-groupings(approach-generation-errors)

// errors where vanilla does not have errors, but approach has evaluation errors
#let new-evaluation-errors = errors.filter(item => item.at("is-error_llm_lsp") and not item.at("is-error_vanilla"))
#let new-evaluation-error-groups = create-groupings(new-evaluation-errors)
