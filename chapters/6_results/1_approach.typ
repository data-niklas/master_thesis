#import "/utils.typ": *
#let masking = load-evaluations("2024-08-16-masking")
#let default = load-evaluations("2024-08-22-default")
#let use-completions = load-evaluations("2024-08-23-use-completions")
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

== Approach Results <chapter:results:approach>
The provided results will show the absolute count for each category instead of the percentage, as there are only #num-dataset tasks.

// reminder scenarios:
// new feature
// to be removed feature or replaced feature
// removed feature
// hard to know feature

=== RQ1: In which scenarios does normal code completion fail to use dependencies correctly?
// 1. In which scenarios does normal code completion fail to use dependencies correctly?

#figure(
  highlight-cells(
    cells: ((2, 2), (3, 2), (4, 2), (5, 2)),
    stats-table((
      (
        [Averaged w.o.\ Copilot],
        average-stats((
          default-baseline,
          masking-baseline,
          use-completions-baseline,
        )),
      ),
      (
        "Copilot",
        copilot,
      ),
    )),
  ),
  caption: [
    Overview over the baseline evaluation. Copilot is included separately, next to the averaged baseline results over three different runs. Averaging is included due to sampled generation.
  ],
)<table:results:approach:baseline-stats>

#figure(
  highlight-cells(
    cells: (),
    task-stats-table(
      get-task-stats(
        all-results + (raw-copilot,),
        key: "evaluated_code_vanilla",
      ),
    ),
  ),
  caption: [
    Baseline evaluation results for each task. The table is sorted from best to worst solved tasks.
  ],
)

#figure(
  highlight-cells(
    cells: ((2, 1), (3, 1), (4, 2), (5, 1)),
    stats-table((
      ("CodeLlama", codellama-baseline-stats),
      (
        "Magicoder",
        magicoder-baseline-stats,
      ),
      (
        "Codestral",
        codestral-baseline-stats,
      ),
    )),
  ),
  caption: [
    Baseline evaluation results for each model. The results are averaged over three different runs.
  ],
)

// in almost most scenarios code completion fails to use dependencies correctly
// pytorch_1, bidict_2, sometimes rich_2, pandas_1 (magicoder, sampling, 3), (polars_1)

// no sampling worse than sampling
// the less beams the worse

// copilot
The evaluation results of Copilot can be seen in @table:results:copilot:

#figure(
  csvtable("/assets/tables/results/copilot.csv"),
  caption: [Copilot evaluation results],
)<table:results:copilot>

// list scenarios and talk on
Copilot only partially solves 11 tasks, not passing the approach correctness test. The first scenario in which it struggles is when methods were deprecated, as seen in the `pydantic` tasks. In these tasks it uses the deprecated method, such as `dict` instead of `model_dump` (@code:dataset:task:pydantic_1), the new replacement. It is expected, as Copilot has been most likely trained on data before the deprecation.

Another similar example is related to renaming method parameters, such as in the `textual_1` task.

=== RQ2: Which scenarios does the approach improve best and under which conditions?
// 2. Which scenarios does the approach improve best and under which conditions?

#figure(
  highlight-cells(
    cells: (),
    task-stats-table(
      diff: true,
      task-stats-diff(
        get-task-stats(
          all-results,
          key: "evaluated_code_llm_lsp",
        ),
        get-task-stats(
          all-results,
          key: "evaluated_code_vanilla",
        ),
      ),
    ),
  ),
  caption: [
    Difference between the baseline and the approach evaluation results for each task. The table is sorted from best to worst solved tasks.
  ],
)

// Show difference between sampling and no sampling
#figure(
  highlight-cells(
    cells: ((1, 2),),
    stats-table(
      show-total: false,
      diff: true,
      (
        (
          "Sampling",
          total-diff-percentage(sampling-evaluations),
        ),
        (
          "No Sampling",
          total-diff-percentage(no-sampling-evaluations),
        ),
      ).rev(),
    ),
  ),
  caption: [
    Effects of using sampling vs. not using sampling on the evaluation results, compared against the baseline.
  ],
)

#figure(
  highlight-cells(
    cells: ((1, 2),),
    stats-table(
      show-total: false,
      diff: true,
      (
        (
          "3 Beams",
          total-diff-percentage(three-beams-evaluations),
        ),
        (
          "2 Beams",
          total-diff-percentage(two-beams-evaluations),
        ),
        (
          "1 Beam",
          total-diff-percentage(one-beam-evaluations),
        ),
      ).rev(),
    ),
  ),
  caption: [
    Effects of using different beam sizes on the evaluation results, compared against the baseline.
  ],
)
#figure(
  highlight-cells(
    cells: ((1, 1),),
    stats-table(
      show-total: false,
      diff: true,
      (
        ("Codellama", total-diff-percentage(codellama-evaluations)),
        ("Magicoder", total-diff-percentage(magicoder-evaluations)),
        ("Codestral", total-diff-percentage(codestral-evaluations)),
      ),
    ),
  ),
  caption: [
    Effects of using different models on the evaluation results, compared against the baseline.
  ],
)

// #figure(
//   task-stats-table(
//     task-stats-diff(
//       get-task-stats(sampling-evaluations),
//       get-task-stats(sampling-evaluations, key: "evaluated_code_vanilla"),
//     ),
//     show-total: false,
//   ),
//   caption: [
//
//   ]
// )

=== RQ3: Why does the approach not improve the results in other cases?
// 3. Why does the approach not improve the results in other cases?

// Function decorator prevents knowledge (see rich_1.py)
// https://github.com/python-lsp/python-lsp-server/issues/352
// Out of GPU mem
// Bugs

// reuse previous tables
// show error types
// #{
//   // get all llm_lsp data
//   all-results.map(evaluation => evaluation.at("items").filter(item => item.at("evaluated_code_llm_lsp").at(0) == "error").map(item => item.at("generated_code_llm_lsp")))
// }

// pick examples

=== RQ4: How easily does the approach confuse the model?
// 1. How easily does the approach confuse the model?
#todo[Search for correct looking tasks where approach is correct, but syntax error]

=== RQ5: Which errors are most common when applying the approach?
// 2. Which errors are most common?

// debug session afterwards

=== RQ6: How does the availability of documentation affect the results?
// 2: How does the length of available documentation affect the results?

// sort tasks by amount of documentation descending

// show documentation summary

=== RQ7: How does the approach handle differently sized code bases?
// 3: Does the approach scale from single code files to large code bases?
#{
  figure(
    table(
      columns: 3,
      align: (row, column) => {
        if row == 0 {
          center
        } else if column == 0 {
          left
        } else {
          right
        }
      },
      table.header(
        [Dependency],
        [Lines of Code],
        [Documentation Percentage],
      ),
      ..(
        dependency-stats.pairs().sorted(key: item => item.at(1).at("lines_of_code")).rev().map(item => (
          [#item.at(0)],
          [#item.at(1).at("lines_of_code")],
          [#calc.round(item.at(1).at("lines_of_doc")/item.at(1).at("lines_of_code")*100, digits: 2)%],
        )).flatten()
      ),
    ),
    caption: [Size of dependencies, as counted using pygount. Documentation percentage is relative to the lines of code, thus excluding empty lines, etc.],
  )
}
=== RQ8: How well can the approach (implementation) be extended to other languages?
// 1: How well can the approach be extended to other languages?
=== RQ9: For which languages does the approach not work?
// 2: For which languages does the approach not work?

=== RQ10: How much overhead does the approach introduce?
// 1: How much overhead does the approach introduce?
// generation_duration_vanilal, generation_duration_llm_lsp
#let evaluation-duration(evaluation) = {
  let items = evaluation.at("items").map(item => (
    item.at("generation_duration_vanilla"),
    item.at("generation_duration_llm_lsp"),
  ))
  items.fold(
    (0, 0),
    (acc, item) => (acc.at(0) + item.at(0), acc.at(1) + item.at(1)),
  ).map(item => item / items.len())
}
#let evaluation-duration-map(item) = (
  item.at(0),
  item.at(1).map(evaluation-duration),
)
#let duration-entries(items) = {
  items.map(item => {
    let name = item.at(0)
    let evaluations = item.at(1)
    let vanilla-sum = evaluations.map(evaluation => evaluation.at("items").map(item => item.at("generation_duration_vanilla")).sum()).sum()
    let llm-lsp-sum = evaluations.map(evaluation => evaluation.at("items").map(item => item.at("generation_duration_llm_lsp")).sum()).sum()
    let total-count = evaluations.map(evaluation => evaluation.at("items").len()).sum()
    let vanilla-average = vanilla-sum / total-count
    let llm-lsp-average = llm-lsp-sum / total-count
    let median(list) = {
      let sorted = list.sorted()
      let len = sorted.len()
      if calc.rem(len, 2) == 0 {
        (
          sorted.at(int(calc.round(len / 2)) - 1) + sorted.at(
            int(calc.round(len / 2)),
          )
        ) / 2
      } else {
        sorted.at(len / 2)
      }
    }
    // calculate the median over all durations
    let vanilla-median = median(
      evaluations.map(evaluation => evaluation.at("items").map(item => item.at("generation_duration_vanilla"))).flatten(),
    )
    let llm-lsp-median = median(
      evaluations.map(evaluation => evaluation.at("items").map(item => item.at("generation_duration_llm_lsp"))).flatten(),
    )
    (
      name,
      calc.round(vanilla-average, digits: 2),
      calc.round(llm-lsp-average, digits: 2),
      calc.round(vanilla-median, digits: 2),
      calc.round(llm-lsp-median, digits: 2),
    ).map(str)
  }).flatten()
}
#figure(
  table(
    columns: 5,
    align: (row, column) => {
      if row == 0 {
        center
      } else if column == 0 {
        left
      } else {
        right
      }
    },
    table.header(
      [Name],
      [Average\ Baseline (s)],
      [Average\ Approach (s)],
      [Median\ Baseline (s)],
      [Median\ Approach (s)],
    ),
    ..duration-entries((
      ("All", all-results),
      ("Default", default),
      ("Masking", masking),
      ("Use Completions", use-completions),
    )),
  ),
  caption: [Average runtime in seconds per task, comparing the baseline and the approach.],
)
