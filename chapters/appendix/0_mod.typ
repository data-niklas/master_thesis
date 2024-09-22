#import "/utils.typ": *
#import "/eval.typ": *
#import "/plot.typ": *
#import "/eval-values.typ": *

#let masking = load-evaluations("2024-08-27-masking")
#let default = load-evaluations("2024-08-26-default")
#let use-completions = load-evaluations("2024-08-28-use-completions")
#let raw-copilot = load-evaluation("2024-08-23", "copilot")
#let all-stats = get-all-stats((
  ("Default", default),
  ("Masking", masking),
  ("Use Completions", use-completions),
))
= Appendix
#show figure: set block(breakable: true)

// functions
// torch.nn.functional

== Language Server Protocol
// #columns(2)[
//   #figure(
//     csvtable("/assets/tables/lsp_language_ids.csv"),
//     caption: "Possible language ids defined in the LSP specification",
//   )<table:language_ids>
// ]
#figure(
  spread(2, has-header: true, csvtable("/assets/tables/lsp_language_ids.csv")),
  caption: "Possible language ids defined in the LSP specification",
)<table:language_ids>

#pagebreak(weak: true)
#figure(
  codefile("/assets/code/lsp_completion_item_kind.ts"),
  caption: "CompletionItemKind enum",
)<code:completion_item_kind>

#pagebreak(weak: true)
== DependencyEval Dataset
=== Schema
#let schema-code = raw(
  block: true,
  lang: "json",
  read("/assets/DependencyEval.schema.json"),
)
#figure(
  code(
    lang: "JSON Schema",
    lines: (1, 89),
    schema-code,
  ),
  caption: "Full JSON schema of the DependencyEval dataset. The schema defines the structure of each task entry in the distributed JSONL file.",
)<code:dataset:format>

=== Tasks
#show figure: set block(breakable: false)
#figure(
  codefile("/assets/code/dataset/bidict_1.py"),
  caption: [Task: `bidict_1.py`],
)<code:dataset:task:bidict_1>
#figure(
  codefile("/assets/code/dataset/bidict_2.py"),
  caption: [Task: `bidict_2.py`],
)<code:dataset:task:bidict_2>
#figure(
  codefile("/assets/code/dataset/dateutil_1.py"),
  caption: [Task: `dateutil_1.py`],
)<code:dataset:task:dateutil_1>
#figure(
  codefile("/assets/code/dataset/dotted_1.py"),
  caption: [Task: `dotted_1.py`],
)<code:dataset:task:dotted_1>
#figure(
  codefile("/assets/code/dataset/dotted_2.py"),
  caption: [Task: `dotted_2.py`],
)<code:dataset:task:dotted_2>
#figure(
  codefile("/assets/code/dataset/emoji_1.py"),
  caption: [Task: `emoji_1.py`],
)<code:dataset:task:emoji_1>
#figure(
  codefile("/assets/code/dataset/fastapi_1.py"),
  caption: [Task: `fastapi_1.py`],
)<code:dataset:task:fastapi_1>
#figure(
  codefile("/assets/code/dataset/numpy_1.py"),
  caption: [Task: `numpy_1.py`],
)<code:dataset:task:numpy_1>
#figure(
  codefile("/assets/code/dataset/pandas_1.py"),
  caption: [Task: `pandas_1.py`],
)<code:dataset:task:pandas_1>
#figure(
  codefile("/assets/code/dataset/polars_1.py"),
  caption: [Task: `polars_1.py`],
)<code:dataset:task:polars_1>
#figure(
  codefile("/assets/code/dataset/pydantic_1.py"),
  caption: [Task: `pydantic_1.py`],
)<code:dataset:task:pydantic_1>
#figure(
  codefile("/assets/code/dataset/pydantic_2.py"),
  caption: [Task: `pydantic_2.py`],
)<code:dataset:task:pydantic_2>
#figure(
  codefile("/assets/code/dataset/pydantic_3.py"),
  caption: [Task: `pydantic_3.py`],
)<code:dataset:task:pydantic_3>
#figure(
  codefile("/assets/code/dataset/pytorch_1.py"),
  caption: [Task: `pytorch_1.py`],
)<code:dataset:task:pytorch_1>
#figure(
  codefile("/assets/code/dataset/pytorch_2.py"),
  caption: [Task: `pytorch_2.py`],
)<code:dataset:task:pytorch_2>
#figure(
  codefile("/assets/code/dataset/pytorch_3.py"),
  caption: [Task: `pytorch_3.py`],
)<code:dataset:task:pytorch_3>
#figure(
  codefile("/assets/code/dataset/rich_1.py"),
  caption: [Task: `rich_1.py`],
)<code:dataset:task:rich_1>
#figure(
  codefile("/assets/code/dataset/rich_2.py"),
  caption: [Task: `rich_2.py`],
)<code:dataset:task:rich_2>
#figure(
  codefile("/assets/code/dataset/sklearn_1.py"),
  caption: [Task: `sklearn_1.py`],
)<code:dataset:task:sklearn_1>
#figure(
  codefile("/assets/code/dataset/sklearn_2.py"),
  caption: [Task: `sklearn_2.py`],
)<code:dataset:task:sklearn_2>
#figure(
  codefile("/assets/code/dataset/sqlalchemy_1.py"),
  caption: [Task: `sqlalchemy_1.py`],
)<code:dataset:task:sqlalchemy_1>
#figure(
  codefile("/assets/code/dataset/textual_1.py"),
  caption: [Task: `textual_1.py`],
)<code:dataset:task:textual_1>
#figure(
  codefile("/assets/code/dataset/textual_2.py"),
  caption: [Task: `textual_2.py`],
)<code:dataset:task:textual_2>
#figure(
  codefile("/assets/code/dataset/theflow_1.py"),
  caption: [Task: `theflow_1.py`],
)<code:dataset:task:theflow_1>
#figure(
  codefile("/assets/code/dataset/tsv2py_1.py"),
  caption: [Task: `tsv2py_1.py`],
)<code:dataset:task:tsv2py_1>

#pagebreak(weak: true)
== Evaluation Result Tables
#show figure: set block(breakable: true)

#figure(
  stats-table((
    ("CodeLlama", codellama-baseline-stats),
    (
      "Magicoder",
      magicoder-baseline-stats,
    ),
    (
      "MistralHermes",
      codestral-baseline-stats,
    ),
    (
      "Copilot",
      copilot,
    ),
    (
      [Averaged w.o.\ Copilot],
      average-stats((
        default-baseline,
        masking-baseline,
        use-completions-baseline,
      )),
    ),
    (
      [Averaged],
      average-stats((
        default-baseline,
        masking-baseline,
        use-completions-baseline,
        copilot,
      )),
    ),
  )),
  caption: [
    Overview over the baseline evaluation. The first three models are averaged due to the use of sampling.
  ],
)<table:results:approach:baseline-stats>

#figure(
  stats-table((
    ("Sampling", sampling-baseline),
    ("No Sampling", no-sampling-baseline),
    ("1 Beam", one-beam-baseline),
    ("2 Beams", two-beams-baseline),
    ("3 Beams", three-beams-baseline),
  )),
  caption: [
    Overview over the baseline evaluation using different model configurations. Copilot is not considered.
  ],
)<table:results:approach:baseline-stats-config>

#figure(
  stats-table((
    ("Default", default-baseline),
    (
      "Masking",
      masking-baseline,
    ),
    (
      "Use Completions",
      use-completions-baseline,
    ),
  )),
  caption: [
    Overview over the baseline evaluation using different approach configurations.
  ],
)<table:results:approach:baseline-stats-approach-config>

#figure(
  stats-table(
    all-stats.map(stat-with-name => (
      stat-with-name.at(0),
      stat-with-name.at(1).at(0),
    )).sorted(key: task-sorted-key).rev().slice(0, 3),
  ),
  caption: [
    Overview over the top 3 baseline configurations.
  ],
)<table:results:approach:baseline-all-stats-best>
#figure(
  csvtable("/assets/tables/results/copilot.csv"),
  caption: [Copilot evaluation results],
)<table:results:copilot>
// === Baseline
// #figure(
//   stats-table(
//     (
//       all-stats.map(stat-with-name => (
//         stat-with-name.at(0),
//         stat-with-name.at(1).at(0),
//       )) + (("Copilot", aggregate-stats(get-baseline((raw-copilot,)))),)
//     ).sorted(key: task-sorted-key).rev(),
//   ),
//   caption: [
//     All evaluation baseline results.
//   ],
// )<table:results:approach:baseline-all-stats-all>
//
// // #pagebreak(weak: true)
// === Approach
// #figure(
//   stats-table(
//     all-stats.map(stat-with-name => (
//       stat-with-name.at(0),
//       stat-with-name.at(1).at(1),
//     )).sorted(key: task-sorted-key).rev(),
//   ),
//   caption: [
//     All evaluation results using the approach.
//   ],
// )<table:results:approach:llm-lsp-all-stats-all>
//
// #pagebreak(weak: true)
// === Improvements
// #figure(
//   stats-table(
//     all-stats.map(stat-with-name => (
//       stat-with-name.at(0),
//       stat-with-name.at(1).at(2),
//     )).sorted(key: task-sorted-key).rev(),
//     diff: true,
//   ),
//   caption: [
//     All differences between the evaluation with and without the approach.
//   ],
// )<table:results:approach:diff-all-stats-all>
//
#pagebreak(weak: true)
== Evaluation Result Details
The following code snippets contain signature help information on different functions used in tasks from the DependencyEval dataset.
The Pydantic `model_dump` method has the following signature:
#figure(
  codefile("/assets/code/model_dump_signature.py"),
  caption: [Signature of the `model_dump` method],
)<code:signature:model_dump>

The `TextArea` class of the rich library has the following signature:
#figure(
  codefile("/assets/code/text_area_signature.py"),
  caption: [Signature of the `TextArea` class],
)<code:signature:text_area>

The method `clear_meta_and_links` of the `Style` class in the rich library has the following signature:
#figure(
  codefile("/assets/code/clear_meta_and_links_signature.py"),
  caption: [Signature of the `clear_meta_and_links` method],
)<code:signature:clear_meta_and_links>
As seen, the signature is not as expected, as the method is decorated with `@lru_cache`, which destroys the original signature @FunctoolsCacheDestroys.
