#import "/utils.typ": *
#let masking = load-evaluations("2024-08-16-masking")
#let default = load-evaluations("2024-08-22-default")
#let use-completions = load-evaluations("2024-08-23-use-completions")
#let copilot = aggregate-stats(
  get-baseline((load-evaluation("2024-08-23", "copilot"),)),
)
#let masking-baseline = aggregate-stats(get-baseline(masking))
#let masking-llm-lsp = aggregate-stats(get-llm-lsp(masking))
#let default-baseline = aggregate-stats(get-baseline(default))
#let default-llm-lsp = aggregate-stats(get-llm-lsp(default))
#let use-completions-baseline = aggregate-stats(get-baseline(use-completions))
#let use-completions-llm-lsp = aggregate-stats(get-llm-lsp(use-completions))

#highlight-cells(
  cells: ((2, 4), (3, 4), (4, 3), (5, 4)),
  stats-table((
    (
      "Default",
      default-baseline,
    ),
    (
      "Masking",
      masking-baseline,
    ),
    (
      "Use Completions",
      use-completions-baseline,
    ),
    (
      "Copilot",
      copilot,
    ),
    (
      "Average",
      average-stats((
        default-baseline,
        masking-baseline,
        use-completions-baseline,
        copilot,
      )),
    ),
  )),
)
#stats-table((
  (
    "Test",
    aggregate-stats(get-llm-lsp(filter-items-by-kind(default, "modification"))),
  ),
))
== Approach Results <chapter:results:approach>
The provided results will show the absolute count for each category instead of the percentage, as there are only #num-dataset tasks.

// reminder scenarios:
// new feature
// to be removed feature or replaced feature
// removed feature
// hard to know feature

=== RQ1: In which scenarios does normal code completion fail to use dependencies correctly?
// 1. In which scenarios does normal code completion fail to use dependencies correctly?

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
=== RQ3: Why does the approach not improve the results in other cases?
// 3. Why does the approach not improve the results in other cases?

// Function decorator prevents knowledge (see rich_1.py)
// https://github.com/python-lsp/python-lsp-server/issues/352
// Out of GPU mem
// Bugs

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
