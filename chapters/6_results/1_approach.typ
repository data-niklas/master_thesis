#import "/utils.typ": *
#set figure(placement: none)
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
== Approach Results <chapter:results:approach>

// reminder scenarios:
// new feature
// to be removed feature or replaced feature
// removed feature
// hard to know feature

=== RQ1: In which scenarios does normal code completion fail to use dependencies correctly?
// 1. In which scenarios does normal code completion fail to use dependencies correctly?
@table:results:approach:baseline-stats displays the average completion rate using the baseline (approach is disabled).
The three models CodeLlama, MistralHermes and Magicoder are able to solve $34.82%$ of the tasks in a traditional sense. When considering the used approach of the model, now only $5.93%$ are solved.
In comparison, Copilot is the superior baseline model, solving $52%$ in a traditional sense and still solving $8%$ when considering the approach.
As can be seen, there is a need for the approach to transform the $39.16%$ partially solved tasks (over all models) into fully solved tasks, by using the correct approach.

To note is that Magicoder and MistralHermes perform more errors than CodeLlama and Copilot, but at the same time have less unsolved tasks.
Possibly Magicoder and MistralHermes fail harder on some tasks.

#figure(
  highlight-cells(
    cells: ((2, 4), (3, 4), (4, 2), (5, 4)),
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
  ),
  caption: [
    Overview over the baseline evaluation. Copilot is included separately, next to the averaged baseline results over three different runs. Averaging is included due to sampled generation.
  ],
)<table:results:approach:baseline-stats>

@table:results:approach:baseline-stats-config shows baseline results for different model configurations. The best performing configurations use $3$ beams and sampling.
Only using a single beam performs particularly bad, with $0%$ fully solved tasks and only $10.67%$ partially solved tasks.
This is as expected, as sampling combined with beam search is a common method to improve the model results generally.
#figure(
  highlight-cells(
    cells: ((2, 5), (2, 1)),
    stats-table((
      ("Sampling", sampling-baseline),
      (
        "No Sampling",
        no-sampling-baseline,
      ),
      (
        "1 Beam",
        one-beam-baseline,
      ),
      (
        "2 Beams",
        two-beams-baseline,
      ),
      (
        "3 Beams",
        three-beams-baseline,
      ),
    )),
  ),
  caption: [
    Overview over the baseline evaluation using different model configurations. Copilot is not considered.
  ],
)<table:results:approach:baseline-stats-config>

// // different approach configurations
// differences due to sampling TODO, difference is not large
// #figure(
//   highlight-cells(
//     cells: (),
//     stats-table((
//       ("Default", default-baseline),
//       (
//         "Masking",
//         masking-baseline,
//       ),
//       (
//         "Use Completions",
//         use-completions-baseline,
//       ),
//     )),
//   ),
//   caption: [
//     Overview over the baseline evaluation using different approach configurations.
//   ],
// )<table:results:approach:baseline-stats-approach-config>

The next table, @table:results:approach:baseline-task-stats, shows the results for each task. The tasks are sorted from best to worst solved tasks.
As can be seen, only $24% (6)$ of all different tasks are ever fully solved by the baseline, while $76% (19)$ are at least partially solved once.

The gold solution to these first six tasks `pytorch_1`, `bidict_2`, `rich_2`, `pandas_1`, `dateutil_1` and `polars_1` are found in @code:dataset:task:pytorch_1, @code:dataset:task:bidict_2, @code:dataset:task:rich_2, @code:dataset:task:pandas_1, @code:dataset:task:dateutil_1 and @code:dataset:task:polars_1.
`pytorch_1` is the highest fully solved task with $61.82%$. This task includes changes from 2018, and is one of the tasks with the oldest changes. It has been included to check the behavior of using dependencies with features deprecated in the "far past".
As the baseline evaluations are able to solve the task consistently, it can be assumed that similar code can be found in many training data samples, as developers have migrated away from the previous deprecated parameter to the correct parameter `reduction`.

The five other tasks feature recent (2024) changes. It is theoretisized that the baseline models solve these tasks due to their easily predictable result, due to e.g. the information found in the documentation string provided in each task, which is especially true for `bidict_2`.

`dateutil_1` tests the behavior when facing changed import behavior. The recent modification in 2024 added lazy import of submodules. Submodules must not be explicitly imported, but can be imported implicitly through the base module. E.g.: `dateutil.tz` can be used by only importing `dateutil`.
As other behavior around the task has not changed over time, the model baseline still solves the task in some cases, not explicitly importing the submodule.

The next $60% (15)$ tasks (up and including `textual_2`) are not fully solved, but at least partially solved. These tasks mainly include tasks with recent deprecations. The baseline still predicts old behavior, passing the output correctness test, but failing the approach correctness test. A prime example are the `pydantic` examples, as introduced in previous chapters.

The last group of tasks are never solved by the baseline. This group includes especially complex tasks that may require multiple steps, or completely unknown packages, that do not see a widespread use.
The three models especially struggle with unknown dependencies, or unknown features in better known dependencies, such as `theflow_1`@code:dataset:task:theflow_1, `tsv2py_1`@code:dataset:task:theflow_1 and `sqlalchemy_1`@code:dataset:task:sqlalchemy_1.
Tasks with recent deprecations in established dependencies are more easily solved, such as `pydantic` examples. The easiest tasks feature other changes, such as changes to imports and code changed in the father past.

The first group of tasks fully solved by the baseline serve to check if the approach worsens the results. The second group of tasks partially solved by the baseline serve to check if the approach can improve the results. The last group of tasks never solved by the baseline serve to check if the approach can solve tasks that are not solvable by the baseline, and to find further interesting results.

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
    Baseline evaluation results for each task. The table is sorted from best to worst solved tasks. Copilot results are included.
  ],
)<table:results:approach:baseline-task-stats>

// in almost most scenarios code completion fails to use dependencies correctly
// pytorch_1, bidict_2, sometimes rich_2, pandas_1 (magicoder, sampling, 3), (polars_1)

// show best evaluation
#figure(
  highlight-cells(
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
  ),
  caption: [
    Overview over the baseline evaluation using different approach configurations.
  ],
)<table:results:approach:baseline-stats-approach-config>

As could be seen in previous tables, choosing the right configuration changes the results drastically. Even more so when combining the different choices. While the averaged baseline evaluations often do not complete more than $10%$ of tasks fully, this cannot be said for individual evaluations.
@table:results:approach:baseline-all-stats-best displays the top 5 best configurations.
It is directly apparent, that those individual evaluations only use sampling and 2-3 beams. This is as expected and in line with @table:results:approach:baseline-stats-config.
Additionally, the best configurations produce substantially less errors and many partially solved tasks.
While a fully solved rate of up to $20%$ is more impressive, it is not sufficient and leaves much room for improvement to the approach.

#figure(
  highlight-cells(
    stats-table(
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(0),
      )).sorted(key: task-sorted-key).rev().slice(0, 3),
    ),
  ),
  caption: [
    Overview over the top 3 baseline configurations.
  ],
)<table:results:approach:baseline-all-stats-best>
// #figure(
//   highlight-cells(
//     stats-table(
//       all-stats.map(stat-with-name => (
//         stat-with-name.at(0),
//         stat-with-name.at(1).at(0),
//       )).sorted(key: task-sorted-key).slice(0, 5),
//     ),
//   ),
//   caption: [
//     Overview over the worst 5 baseline configurations.
//   ],
// )<table:results:approach:baseline-all-stats-worst>

// copilot
The exact distribution of tasks results by Copilot are found in @table:results:copilot. The results are in line with @table:results:approach:baseline-task-stats.

#figure(
  csvtable("/assets/tables/results/copilot.csv"),
  caption: [Copilot evaluation results],
)<table:results:copilot>

In summary, all configurations fail to use dependencies correctly, except for a few tasks that are very similar to training data.
Especially scenarios that include recently deprecated code are affected.
While other tasks like `theflow_1` are not solved by the baseline, this is likely due to proportionally high difficulty of the task.

=== RQ2: Which scenarios does the approach improve best and under which conditions?
// 2. Which scenarios does the approach improve best and under which conditions?
This section now looks at the difference between the results using the approach compared against the baseline. In particular, this section looks at improvements in different scenarios.
All improvement percentages are relative to the total tasks, *not* the category (like fully solved).

The first table, @table:results:approach:diff-stats, shows the differences between baseline and approach for the three models. CodeLlama is most affected by the approach, improving all fully solved tasks by $7.56%$. This is in stark contrast to MistralHermes, which only shows improvements in fully solved tasks of $1.56%$.

// Show difference between sampling and no sampling
#figure(
  highlight-cells(
    cells: ((1, 1),),
    stats-table(
      show-total: false,
      diff: true,
      (
        ("Codellama", total-diff-percentage(codellama-evaluations)),
        ("Magicoder", total-diff-percentage(magicoder-evaluations)),
        ("MistralHermes", total-diff-percentage(codestral-evaluations)),
      ),
    ),
  ),
  caption: [
    Effects of using different models on the evaluation results, compared against the baseline.
  ],
)<table:results:approach:diff-stats>

In similar contrast are the results when comparing different model configurations. @table:results:approach:diff-sampling-stats displays the differences between the sampling and non sampling model configurations.
The sampling model configuration using the approach shows the most improvements of $7.85%$, in contrast to the $1.04%$ when not using sampling. Similar differences are seen in @table:results:approach:diff-beams-stats between the best configuration using $2$ beams ($+8%$), versus the $1$ beam configuration only showing improvements of $1.78%$.

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
)<table:results:approach:diff-sampling-stats>

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
)<table:results:approach:diff-beams-stats>

The next table @table:results:approach:diff-runs-stats moves on to comparing the three approach configurations Default, Masking and Use Completions.
The configuration with the most impact is the Default configuration.
#figure(
  highlight-cells(
    cells: ((1, 1),),
    stats-table(
      show-total: false,
      diff: true,
      (
        (
          "Default",
          total-diff-percentage(default),
        ),
        (
          "Masking",
          total-diff-percentage(masking),
        ),
        (
          "Use Completions",
          total-diff-percentage(use-completions),
        ),
      ),
    ),
  ),
  caption: [
    Effects of using different approach configurations on the evaluation results, compared against the baseline.
  ],
)<table:results:approach:diff-runs-stats>

After looking at different conditions optimal to improve the tasks, @table:results:approach:diff-task-stats, looks at differences in concrete tasks / scenarios. The tasks are sorted from best to worst solved tasks.
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
)<table:results:approach:diff-task-stats>

After looking at the tasks, three groups emerge:
1. A few tasks heavily improved by the approach,
2. Many tasks unaffected by the approach,
3. A few tasks worsened by the approach.

The first group answers #rq(2), showing which scenarios the approach improves best. These unique tasks mainly include the `pydantic` tasks and the `textual_1` tasks, which correspond to the second baseline task group.
In the baseline those tasks mainly had a high partial solved rate, as the dependencies were recently changed and included simple deprecations of methods and function parameters.
The approach clearly improves such examples the best, changing the single deprecated method or parameter to an alternative.

#figure(
  highlight-cells(
    stats-table(
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(2),
      )).sorted(key: task-sorted-key).rev().slice(0, 3),
      diff: true,
    ),
  ),
  caption: [
    Overview over the top 3 configurations improving the baseline using the approach.
  ],
)<table:results:approach:diff-all-stats-best>

To summarize, only certain configuration combinations improve the results.
Especially CodeLlama using sampling and two beams, using the Default approach configuration, shows the most improvements. Additionally, only a handful of tasks can be improved. Those are the core tasks in which a method or function parameter was recently deprecated. Other tasks do not show many or any improvements.

=== RQ3: Why does the approach not improve the results in other cases?
// 3. Why does the approach not improve the results in other cases?

This section uses the same figures as the last section, but now looks at the examples in which the approach worsens the results. It e.g. continues the notes on the different task groups from the last section.

As introduced before, the second task group mainly includes tasks unaffected by the approach. The main observation is that many of these tasks are some of the worst performing baseline tasks. E.g. `sklearn-1` and `theflow_1` have a $0%$ completion rate in the baseline and show no improvements using the approach.
These tasks seem to be unaffected due to their proportionally high difficulty, as providing additional context does not improve the base model capabilities.
The only outlier being `bidict_2`, which is one of the best performing tasks in the baseline, but is not improved by the approach. This task is likely to be too simple for the approach to improve, as the baseline already solves it consistently.
// bidict_1, textual_2, emoji_1, sklearn_1, theflow_1, sqlalchemy_1, tsv2py_1, bidict_2

The last group of tasks worsened by the approach mainly correspond to the some of the best performing baseline tasks. This is especially true for the `pytorch` tasks, with `pytorch_1` the main example.
The conclusion is that the simpleness of the tasks is worsened by the approach, as the approach introduces additionaly complexity to the completion, which is unneeded and confuses the model.

// pick examples

When looking at different configurations again, it becomes clear that limiting the search space by using only a single beam, or not using sampling, worsens the results. Exploring many different combinations of completions affected by the approach reduces the amount of errors.

=== RQ4: How easily does the approach confuse the model?
// 1. How easily does the approach confuse the model?
#todo[Search for correct looking tasks where approach is correct, but syntax error]
- Second group, partial results:
- pytorch_3
- dotted_1
- pytorch_2
- pydantic_1
- pydantic_3
- sklearn_2
- pydantic_2
- rich_1
- numpy_1
- textual_1
- dotted_2
- fastapi_1

=== RQ5: Which errors are most common when applying the approach?
// 2. Which errors are most common?

// Function decorator prevents knowledge (see rich_1.py)
// https://github.com/python-lsp/python-lsp-server/issues/352
// Out of GPU mem
// Bugs
// debug session afterwards
// reuse previous tables
// show error types
#{
  // get all llm_lsp data
  let map-error(message) = {

  }
  let is-oom(code) = {
    "torch.cuda.OutOfMemoryError: CUDA out of memory" in code
  }
  let is-lsp-error(code) = {

  }
  let with-errors(evaluations, filter) = {
    evaluations.map(evaluation => evaluation.at("items").filter(item => item.at("evaluated_code_llm_lsp").at(0) == "error").filter(item => filter(item))).flatten().len()
  }
  let total-oom = with-errors(
    all-results,
    item => is-oom(item.at("generated_code_llm_lsp")),
  )
  let total-pip-eval-error = with-errors(
    all-results,
    item => " pip " in item.at("evaluation_error_llm_lsp"),
  )
  let total-errors = with-errors(all-results, item => true)
  let pip-errors = all-results.map(evaluation => evaluation.at("items").filter(item => item.at("evaluated_code_llm_lsp").at(0) == "error").filter(item => " wheel " in item.at("evaluation_error_llm_lsp")).map(item => item.at("evaluation_error_llm_lsp"))).flatten().len()
  (total-errors, total-oom, total-pip-eval-error)
}

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
