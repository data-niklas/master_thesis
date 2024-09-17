#import "/utils.typ": *
#import "/plot.typ": *
#import "/eval.typ": *
#import "/eval-values.typ": *
#set figure(placement: none)
== Approach Results <chapter:results:approach>

=== *RQ1* How does the approach affect the use of dependencies?

==== *RQ1.1* In which scenarios does regular code completion fail to use dependencies correctly?
// --------- Models ---------------
@plot:results:approach:baseline-stats displays the average completion rate using the baseline (approach is disabled).
The three models CodeLlama, MistralHermes and Magicoder are able to solve $34.52%$ of the tasks in a traditional sense (fully- + partially solved). When considering the used approach of the model, now only $6%$ are solved (fully solved).
In comparison, Copilot is the superior baseline model, solving $52%$ in a traditional sense and still solving $8%$ when considering the approach.
As can be seen, there is a need for the approach to transform the $28.8%$ partially solved tasks (over all models) into fully solved tasks, by using the correct approach.

To note is that Magicoder and MistralHermes perform more errors than CodeLlama and Copilot, but at the same time have less unsolved tasks.
Possibly Magicoder and MistralHermes fail harder on some tasks.

#figure(
  stats-column-charts((
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
  )),
  caption: [
    Overview over the baseline evaluation. The first three models are averaged due to the use of sampling. The full stats are found in @table:results:approach:baseline-stats.
  ],
)<plot:results:approach:baseline-stats>

// -------------- Model configurations ------------------
After comparing the baseline performance of different models, this paragraph compares baseline results for different model configurations.
@plot:results:approach:baseline-stats-config shows baseline results for different model configurations. The best performing configurations use $3$ beams and sampling.
Only using a single beam performs particularly bad, with $0%$ fully solved tasks and only $10.67%$ partially solved tasks.
This is partially in line with the observations by Austin et al. @austinProgramSynthesisLarge2021a (@chapter:bg:related_work), which noted that sampling performs best.
While they concluded that greedy decoding performs better than beam search, they did not compare sampling beam search to other model configurations.
This paper notes that the high repetition penalty ($1.3$ for CodeLlama), combined with sampling may have led to the high beam search performance, which suffered from high repetitions in Austin et al's. work.

#figure(
  stats-column-charts((
    ("Sampling", sampling-baseline),
    ("No Sampling", no-sampling-baseline),
    ("1 Beam", one-beam-baseline),
    ("2 Beams", two-beams-baseline),
    ("3 Beams", three-beams-baseline),
  )),
  caption: [
    Overview over the baseline evaluation using different model configurations. Copilot is not considered. The full results are found in @table:results:approach:baseline-stats-config.
  ],
)<plot:results:approach:baseline-stats-config>

// ------------ Approach configurations -----------
Next, @plot:results:approach:baseline-stats-approach-config compares the three approach configurations. Thankfully, as can be seen, the three configurations only display a neglegible difference.
As fully expected, the approach configuration does not affect the generation when the approach is disabled. Thus, the plot displays the average task completion over the baseline results, as the approach configuration should not affect the baseline.

#figure(
  stats-column-charts((
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
    The full results are found in @table:results:approach:baseline-stats-approach-config.
  ],
)<plot:results:approach:baseline-stats-approach-config>

// ------------ Scenario performance --------------
The next table, @table:results:approach:baseline-task-stats, shows the results for each task. The tasks are sorted from best to worst solved tasks (sorted by fully solved, partially solved, not solved, then error descending).
As can be seen, only $24% (6)$ of all different tasks are ever fully solved by the baseline, while $76% (19)$ are at least partially solved once #footnote[
// copilot
The exact distribution of task results by Copilot are found in @table:results:copilot. The results are in line with @table:results:approach:baseline-task-stats.
].

The gold solution to these first six tasks `pytorch_1`, `bidict_2`, `rich_2`, `pandas_1`, `dateutil_1` and `polars_1` are found in @code:dataset:task:pytorch_1, @code:dataset:task:bidict_2, @code:dataset:task:rich_2, @code:dataset:task:pandas_1, @code:dataset:task:dateutil_1 and @code:dataset:task:polars_1.
`pytorch_1` is the highest fully solved task with $61.82%$. This task includes changes from 2018, and is one of the tasks with the oldest changes. It has been included to check the behavior of using dependencies with features deprecated in the "far past".
As the baseline evaluations are able to solve the task consistently, it can be assumed that similar code can be found in many training data samples, as developers have migrated away from the previous deprecated parameter to the correct parameter `reduction`.

The five other tasks feature recent (2024) changes. It is theoretisized that the baseline models solve these tasks due to their easily predictable result, due to e.g. the information found in the documentation string provided in each task, which is especially true for `bidict_2`.

`dateutil_1` tests the behavior when facing changed import behavior. The recent modification in 2024 added lazy import of submodules. Submodules must not be explicitly imported, but can be imported implicitly through the base module. E.g.: `dateutil.tz` can be used by only importing `dateutil`.
As other behavior around the task has not changed over time, the model baseline still solves the task in some cases, not explicitly importing the submodule.

The next $60% (15)$ tasks (up and including `textual_2`) are not fully solved, but at least partially solved. These tasks mainly include tasks with recent deprecations. The baseline still predicts old behavior, passing the output correctness test, but failing the approach correctness test. A prime example are the `pydantic` examples, as introduced in previous chapters.

The last group of tasks are never solved by the baseline. This group includes especially complex tasks that may require multiple steps, or completely unknown packages, that do not see a widespread use.
The three models especially struggle with unknown dependencies, or unknown features in better known dependencies, such as `theflow_1` @code:dataset:task:theflow_1, `tsv2py_1` @code:dataset:task:theflow_1 and `sqlalchemy_1` @code:dataset:task:sqlalchemy_1.
Tasks with recent deprecations in established dependencies are more easily solved, such as `pydantic` examples. The easiest tasks feature other changes, such as changes to imports and code changed in the father past.

The first group of tasks fully solved by the baseline serve to check if the approach worsens the results. The second group of tasks partially solved by the baseline serve to check if the approach can improve the results. The last group of tasks never solved by the baseline serve to check if the approach can solve tasks that are not solvable by the baseline, and to find further interesting results.
#figure(
  task-stats-table(
    show-total: false,
    get-task-stats(
      all-results + (raw-copilot,),
      key: "evaluated_code_vanilla",
    ),
  ),
  caption: [
    Baseline evaluation results for each task. The table is sorted from best to worst solved tasks. Copilot results are included.
  ],
)<table:results:approach:baseline-task-stats>

// in almost most scenarios code completion fails to use dependencies correctly
// pytorch_1, bidict_2, sometimes rich_2, pandas_1 (magicoder, sampling, 3), (polars_1)

// show best evaluation

As could be seen in previous figures, choosing the right configuration changes the results drastically. Even more so when combining the different choices. While the averaged baseline evaluations often do not complete more than $10%$ of tasks fully, this cannot be said for individual evaluations.
@plot:results:approach:baseline-all-stats-best displays the top 5 best configurations.
It is directly apparent, that those individual evaluations only use sampling and 2-3 beams. This is as expected and in line with @plot:results:approach:baseline-stats-config.
Additionally, the best configurations produce substantially less errors and many partially solved tasks.
While a fully solved rate of up to $20%$ is more impressive, it is not sufficient and leaves much room for improvement to the approach.

#figure(
  stats-column-charts(
    all-stats.map(stat-with-name => (
      stat-with-name.at(0),
      stat-with-name.at(1).at(0),
    )).sorted(key: task-sorted-key).rev().slice(0, 3),
  ),
  caption: [
    Overview over the top 3 baseline configurations.
    The full results are found in @table:results:approach:baseline-all-stats-best.
  ],
)<plot:results:approach:baseline-all-stats-best>

In summary, all configurations fail to use dependencies correctly, except for a few tasks that are very similar to training data.
Especially scenarios that include recently deprecated code are affected.
While other tasks like `theflow_1` are not solved by the baseline, this is likely due to proportionally high difficulty of the task.

==== *RQ1.2* Which scenarios does the approach improve best and under which conditions?
This section now looks at the difference between the results using the approach compared against the baseline. In particular, this section looks at improvements in different scenarios.
All improvement percentages are relative to the total tasks, *not* the category (like fully solved).

// -------- Model ---------------
The first table, @table:results:approach:diff-stats, shows the differences between baseline and approach for the three models. CodeLlama is most affected by the approach, improving all fully solved tasks by $7.56%$. This is in stark contrast to MistralHermes, which only shows improvements in fully solved tasks of $1.56%$.

// Show difference between sampling and no sampling
#figure(
  stats-table(
    show-total: false,
    diff: true,
    (
      ("Codellama", total-diff-percentage(codellama-evaluations)),
      ("Magicoder", total-diff-percentage(magicoder-evaluations)),
      ("MistralHermes", total-diff-percentage(codestral-evaluations)),
    ),
  ),
  caption: [
    Effects of using different models for evaluation of the approach, compared against the baseline.
  ],
)<table:results:approach:diff-stats>

// ------ Model configurations ------------
In similar contrast are the results when comparing different model configurations. @table:results:approach:diff-sampling-stats displays the differences between the sampling and non sampling model configurations.
The sampling model configuration using the approach shows the most improvements of $7.85%$, in contrast to the $1.04%$ when not using sampling. Similar differences are seen in @table:results:approach:diff-beams-stats between the best configuration using $2$ beams ($+8%$), versus the $1$ beam configuration only showing improvements of $1.78%$.

#figure(
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
  caption: [
    Effects of using sampling vs. not using sampling on the evaluation results, compared against the baseline.
  ],
)<table:results:approach:diff-sampling-stats>

#figure(
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
  caption: [
    Effects of using different beam sizes on the evaluation results, compared against the baseline.
  ],
)<table:results:approach:diff-beams-stats>

The next table @table:results:approach:diff-runs-stats moves on to comparing the three approach configurations "Default", "Masking" and "Use Completions".
The configuration with the most impact is the "Default" configuration.
#figure(
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
  caption: [
    Effects of using different approach configurations on the evaluation results, compared against the baseline.
  ],
)<table:results:approach:diff-runs-stats>

After looking at different conditions optimal to improve the tasks, @table:results:approach:diff-task-stats looks at differences in concrete tasks / scenarios. The tasks are sorted from best to worst solved tasks.
#figure(
  highlight-cells(
    cells: (),
    task-stats-table(
      diff: true,
      show-total: false,
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

The first group shows which scenarios the approach improves best. These unique tasks mainly include the `pydantic` tasks and the `textual_1` tasks, which correspond to the second baseline task group.
In the baseline those tasks mainly had a high partial solved rate, as the dependencies were recently changed and included simple deprecations of methods and function parameters.
The approach clearly improves such examples the best, changing the single deprecated method or parameter to an alternative.

#figure(
  stats-table(
    show-total: false,
    all-stats.map(stat-with-name => (
      stat-with-name.at(0),
      stat-with-name.at(1).at(2),
    )).sorted(key: task-sorted-key).rev().slice(0, 3),
    diff: true,
  ),
  caption: [
    Overview over the top 3 configurations improving the baseline using the approach.
  ],
)<table:results:approach:diff-all-stats-best>

To summarize, only certain configuration combinations improve the results.
Especially CodeLlama using sampling and two beams, using the "Default" approach configuration, shows the most improvements. Additionally, only a handful of tasks can be improved. Those are the core tasks in which a method or function parameter was recently deprecated. Other tasks do not show many or any improvements.
To note is that not only does sampling beam search perform best of the baseline results, but is also best suited for the approach.

==== *RQ1.3* Why does the approach not improve the results in other cases?

This section first looks at failing examples in previous figures and analyzes why the approach worsens the results in these cases. It e.g. continues the notes on the different task groups from the last section.

// --------- Look at groups -----------------
As introduced before, the second task group mainly includes tasks unaffected by the approach. The main observation is that many of these tasks are some of the worst performing baseline tasks. E.g. `sklearn_1` and `theflow_1` have a $0%$ completion rate in the baseline and show no improvements using the approach.
These tasks seem to be unaffected due to their proportionally high difficulty, as providing additional context does not improve the base model capabilities.
The only outlier being `bidict_2`, which is one of the best performing tasks in the baseline, but is not improved by the approach. This task is likely to be too simple for the approach to improve, as the baseline already solves it consistently.
// bidict_1, textual_2, emoji_1, sklearn_1, theflow_1, sqlalchemy_1, tsv2py_1, bidict_2

The last group of tasks worsened by the approach mainly correspond to the some of the best performing baseline tasks. This is especially true for the `pytorch` tasks, with `pytorch_1` the main example.
The conclusion is that the simpleness of the tasks is worsened by the approach, as the approach introduces additionaly complexity to the completion, which in some cases causes the generation to end in faulty code, where the model without the approach would not have been guided towards.

// pick examples

When looking at different configurations again, it becomes clear that limiting the search space by using only a single beam, or not using sampling, worsens the results. Exploring many different combinations of completions affected by the approach reduces the amount of errors.

// --------- Examples --------------------
There are several cases where using the approach led to a model confusion. The following four examples show different types of confusions occuring:

// '...' is a fill value for unneeded parameters
In the first example @figure:correct_approach_wrong_code_pydantic_1, the approach guides the generation towards the correct method `model_dump`. The error lies in the uneeded parameter `by_alias`, with the wrong value `...`. As can be seen in the signature of `model_dump`(@code:signature:model_dump), the parameter `by_alias` accepts a boolean. The completed code uses the wrong value, the ellipsis constant.
#figure(
  codefile("/assets/code/correct_approach_wrong_code_pydantic_1.py"),
  caption: [
    Example of the approach confusing the model to use a wrong value for an unneeded parameter. The approach guided the generation towards the correct method `model_dump`.
  ],
)<figure:correct_approach_wrong_code_pydantic_1>

// Literal type instead of direct value
In the next example @figure:correct_approach_wrong_code_textual_1, now the correct function and parameter were chosen. For comparison, the function signature can be found in @code:signature:text_area. The confusion lies in `Literal`. `Literal` is a type class representing a literal value, to be specified directly. This can be seen in the default value set in the function signature.
In contrast, the completed code tries to construct the parameter value using the `Literal` class, erronously predicting that it is a real class and not a type hint.
#figure(
  codefile("/assets/code/correct_approach_wrong_code_textual_1.py"),
  caption: [
    Example of the approach confusing the model to use a wrong type for a parameter value. The approach guided the generation towards the correct method `text_area`, but was confused by the `Literal` type hint.
  ],
)<figure:correct_approach_wrong_code_textual_1>

// correct parameters, but wrong syntax, as return value
The third example @figure:correct_approach_wrong_code_fastapi_1 goes one step further.
The used function and parameters use the correct approach, similar to the correct result @code:dataset:task:fastapi_1. The difference is the generation of a type hint for the return type, which is incorrect outside of function definitions.
#figure(
  codefile("/assets/code/correct_approach_wrong_code_fastapi_1.py"),
  caption: [
    Example of the approach confusing the model to use a wrong type hint for a return value. The approach guided the generation towards the correct method `app`, but was confused by the type hint.
  ],
)<figure:correct_approach_wrong_code_fastapi_1>

// correct method, but invalid parameters, due to LRU cache decorator proxying
Next, @figure:correct_approach_wrong_code_rich_1 calls the correct method, but is confused by the method parameters.
While the `clear_meta_and_links` takes no parameters (except `self`), the completed code passes the value `True`.
This can be explained by the method being decorated with `@lru_cache`, which proxies the method. This destroys the original function signature @FunctoolsCacheDestroys, leading to the function signature found in @code:signature:clear_meta_and_links.

#figure(
  codefile("/assets/code/correct_approach_wrong_code_rich_1.py"),
  caption: [
    Example of the approach confusing the model to use invalid parameters for a method. The approach guided the generation towards the correct method `clear_meta_and_links`, but was confused by the method signature.
  ],
)<figure:correct_approach_wrong_code_rich_1>

And lastly, @figure:correct_approach_wrong_code_rich_2 completed the correct code, followed by an invalid postfix. The model is generally confused and instead of stopping the generation, continues in an invalid format.
#figure(
  codefile("/assets/code/correct_approach_wrong_code_rich_2.py"),
  caption: [
    Example of the correct code followed by an incorrect postfix, due to a bad format.
  ],
)<figure:correct_approach_wrong_code_rich_2>

// Summary: Type information causes issues
In summary, most errors are caused due to issues with type information. Some other errors are caused due to wrong formatting.
// - Second group, partial results:
// - pytorch_3
// - dotted_1
// - pytorch_2
// - pydantic_1
// - pydantic_3
// - sklearn_2
// - pydantic_2
// - rich_1
// - numpy_1
// - textual_1
// - dotted_2
// - fastapi_1

// 2. Which errors are most common?

// Function decorator prevents knowledge (see rich_1.py)
// https://github.com/python-lsp/python-lsp-server/issues/352
// Out of GPU mem
// Bugs
// debug session afterwards
// reuse previous tables
// show error types
After looking at general causes for erroneously generated code, this section will analyze the two distinct error classes of runtime and evaluation errors.
It distinguishes between two types of errors:
1. Generation errors, which occur during the generation of the code due to issues in the runtime.
2. Evaluation errors, which occur during the evaluation of the generated code.

// Generation errors in generate

// Errors not in the baseline
The first table, @table:generation-errors-card, displays all occuring model generation errors when using the approach.
Only a single error occurs, the error `OutOfMemoryError`. This error is caused by the generation trying to consume more than 24GB GPU memory (full GPU memory of 1 GPU used for generation).
When looking at the used approach configuration, it becomes that the error only occurs when the "use completion" configuration is used.
The "Use Completion" configuration enables the approach to directly infer a method name using a secondary model generation.
It seems that the secondary generation consumes additional memory over the total capacity of the used GPU. This seems to be an issue especially when using beam search, which consumes more resources.
With greedy decoding the error does not occur.
Additionally it only occurs for certain tasks. This leads to the conclusion that the high GPU memory use is due to an unbounded generation, likely due to model repetition.
Using a model configuration or no beam search or other tasks yields higher quality results, possibly terminating the generation quicker, consuming less resources.
To note is that no runtime errors occured when using MistralHermes.

#figure(
  error-card(approach-generation-error-groups),
  caption: [
    All runtime errors occuring during the model generation when using the approach. The card displays the in total $#approach-generation-error-groups.at("total")$ errors, grouped into different categories, such as the models, model configurations, etc..
  ],
)<table:generation-errors-card>

The second table, @table:evaluation-errors-card, displays all evaluation errors occuring when using the approach, which did _not_ occur in the baseline. The values here are different to errors in previous sections, as runtime errors are not considered. Additionally, the effect of the approach solving a previously erroneous task is not considered, which is why numbers vary, compared to previous sections.
The first note is that errors are split evenly between different model configurations. This indicates that while beam search is suited for the baseline _and_ the approach, that if the model fails, it fails hard, without (almost) any difference between model configuration.
Applying beam search with sampling may improve the approach without having an effect on failing examples.
Additionally, beam search using $2$ beams slightly outperforms other configurations.

When looking at approach configurations, using the "Masking" approach configuration leads produces the most new evaluation errors, indicating that slightly nudging the model logits during generation prevents cases where due to the hard masking helpful alternatives are removed, which would have otherwise been chosen due to sampling.

Now the different tasks in which new errors occur due to the approach can be compared to tasks, for which the average amount of errors increased. It becomes clear, that entries with a high amount of errors in the baseline are either not listed, or have a low score. As those entries already have many errors, almost no new errors can occur. This is the case for e.g. "theflow_1".

The next note is that "pandas_1" has a high increase in (absolute) errors, even though the average amount of errors sinks, as seen in @table:results:approach:diff-task-stats.
This is likely due to the approach either strongly guiding the generation to a solution, thus reducing the error average, or strongly mistakenly guiding the generation towards a new error.

When looking at error categories, unexpectedly, a large portion of errors are due to incorrect indentation. After reviewing examples, these are often due to Magicoder incorrectly indenting the line with $2$ instead of $4$ whitespace. This error was mainly found when using greedy decoding and rarely with beam search.
// TODO: show example?

// bidict_2, pytorch_1, rich_2, pandas_1, dateutil_1

#pagebreak(weak: true)
#{
  show figure: set block(breakable: true)
  [#figure(
      kind: table,
      spread(
        2,
        has-header: true,
        error-card(
          new-evaluation-error-groups,
          errors-field: "errors-evaluation",
        ),
      ),
      caption: [
        All evaluation errors occuring when using the approach, which did _not_ occur in the baseline. The card displays the in total $#new-evaluation-error-groups.at("total")$ errors, grouped into different categories, such as the models, model configurations, etc..
      ],
    )<table:evaluation-errors-card>]
}

In summary, some tasks like "theflow_1" in DependencyEval are very hard, leading to a $100%$ error rate in the baseline and approach. Additionally, the added complexity of the approach causes some simple tasks to fail, such as "pytorch_1". Next to such evaluation errors, the model Magicoder causes indentation errors when using greedy decoding. Additionally, the approach configuration "Use Completions" causes a high GPU usage, sometimes causing out of memory exceptions at runtime.

=== *RQ2* How does the approach handle different types of dependencies?
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
          [#calc.round(item.at(1).at("documentation_percentage"), digits: 2)%],
        )).flatten()
      ),
    ),
    caption: [Size of dependencies, as counted using pygount. Documentation percentage is relative to the lines of code, thus excluding empty lines, etc.],
  )
}
==== *RQ2.1* How does the availability of documentation affect the results?
==== *RQ2.2* How does the approach handle differently sized code bases?
=== *RQ3* How well can the approach be extended to other languages?
=== *RQ4* How much overhead does the approach introduce?
// reminder scenarios:
// new feature
// to be removed feature or replaced feature
// removed feature
// hard to know feature

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
