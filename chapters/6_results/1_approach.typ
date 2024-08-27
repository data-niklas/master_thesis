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

=== RQ4: How easily does the approach confuse the model?
// 1. How easily does the approach confuse the model?

=== RQ5: Which errors are most common when applying the approach?
// 2. Which errors are most common?

=== RQ6: How does the availability of documentation affect the results?
// 2: How does the length of available documentation affect the results?

=== RQ7: How does the approach handle differently sized code bases?
// 3: Does the approach scale from single code files to large code bases?
=== RQ8: How well can the approach (implementation) be extended to other languages?
// 1: How well can the approach be extended to other languages?
=== RQ9: For which languages does the approach not work?
// 2: For which languages does the approach not work?

=== RQ10: How much overhead does the approach introduce?
// 1: How much overhead does the approach introduce?
