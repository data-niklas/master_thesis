#import "/utils.typ": *

/*

    - Dependency Accuracy
        - In which scenarios does regular code completion fail to use dependencies correctly?
        - Which scenarios does the approach improve best and under which conditions?
        - Why does the approach not improve the results in other cases?
    - General Correctness
        - How does the approach confuse the model?
        - Which errors are most common when applying the approach?
    - Robustness
        - How does the availability of documentation affect the results?
        - How does the approach handle differently sized code bases?
    - generalizability
        - How well can the approach (implementation) be extended to other languages?
        - For which languages does the approach not work?
    - Performance
        - How much overhead does the approach introduce?

    Group into top level research questions with subquestions:

    - How does the approach affect the use of dependencies?
        - In which scenarios does regular code completion fail to use dependencies correctly?
        - Which scenarios does the approach improve best and under which conditions?
        - Why does the approach not improve the results in other cases?
            - How does the approach confuse the model?
            - Which errors are most common when applying the approach?
    // Does the type of dependency make a difference? size and documentation percentage
    - How does the approach handle different types of dependencies?
        - How does the availability of documentation affect the results?
        - How does the approach handle differently sized code bases?
    - How well can the approach be extended to other languages?
    - How much overhead does the approach introduce?

*/

== Research Questions <chapter:experiments:rq>
This section lists the research question for the thesis.
The research questions for the approach are directly derived from the requirements of the thesis listed in @requirements. Each research question corresponds to one or several requirements.
The following research questions are posed to evaluate the approach in the results chapter:
#blist(
  [RQ1],
  [How does the approach affect the use of dependencies?],
  [RQ2],
  [How does the approach handle different types of dependencies?],
  [RQ3],
  [How well can the approach be extended to other languages?],
  [RQ4],
  [How much overhead does the approach introduce?],
)<rq>

#v(10pt)

=== *RQ1* How does the approach affect the use of dependencies?<rq:1>
The first research question combines questions derived from the requirements #r(1) and #r(2).
It aims to understand how the models use of dependencies changes when applying the approach.
This research question is further divided into three subquestions:
#blist(
  [RQ1.1],
  [In which scenarios does regular code completion fail to use dependencies correctly?],
  [RQ1.2],
  [Which scenarios does the approach improve best and under which conditions?],
  [RQ1.3],
  [Why does the approach not improve the results in other cases?],
)<rq1sub>

==== *RQ1.1* In which scenarios does regular code completion fail to use dependencies correctly?<rq:1.1>
While further subquestions focus on possible improvements using the approach, this question starts with the current state of code completion.
It goes beyond simply evaluating the accuracy of the baseline, but aims to identify concrete scenarios where the baseline fails to use dependencies correctly.
Further research subquestions shall analyze how the approach impacts these scenarios.

In the evaluation, only the results of the baseline are considered. The results are mainly grouped by the scenario of the task.
To further distinguish trends between model configurations and models, the results are also grouped by each model and different configurations.
For each scenario, failing tasks are analyzed, concretely identifying the issues.

Additionally, Copilot is used to evaluate DependencyEval, obtaining further baseline results.

==== *RQ1.2* Which scenarios does the approach improve best and under which conditions?<rq:1.2>
After identifying issues with the baseline, the approach is applied to improve the results. This research subquestion focuses on the cases where the approach improves the results the most.
It aims to understand why the improvement occurs and under which conditions the approach is most effective.
Next to analyzing differences in the prompt and logits manipulation, also differences between model configurations and capabilities are considered.

Both the results of the baseline and the approach are considered.
Similar to #rq(1.1), the results are mainly grouped by the scenario of the task, and secondly by each model and different configurations.
The difference is that now only the successful tasks are analyzed.

==== *RQ1.3* Why does the approach not improve the results in other cases?<rq:1.3>
In contrast to the previous research subquestion, this subquestions focuses on the remaining cases where the approach does _not_ improve the results, or even worsens them.
It aims to understand why the approach fails, to identify shortcomings and limitations of current models, model configurations, and the approach itself.

The remaining tasks in the experiments are analyzed, focusing on the differences between the baseline and the approach.

=== *RQ2* How does the approach handle different types of dependencies?<rq:2>
The second research question focuses on the dependencies themselves. It is derived from the requirements #r(3). In contrast to #rq(1), which analyzes code scenarios of DependencyEval, this research question discusses the performance of the approach on used dependencies, based on different attributes of the dependency.
It analyzes and discusses the attributes dependency size and documentation availability.
This research question is further divided into two subquestions:
#blist(
  [RQ2.1],
  [How does the availability of documentation affect the results?],
  [RQ2.2],
  [How does the approach handle differently sized code bases?],
)<rq2sub>

==== *RQ2.1* How does the availability of documentation affect the results?<rq:2.1>
The first subquestion analyzes the use of the information source, code documentation.
Can the approach improve the results when almost no documentation is available?
Does the approach struggle with too much documentation?

==== *RQ2.2* How does the approach handle differently sized code bases?<rq:2.2>
Similar to #rq(2.1), this research question aims to understand the impact of the size of the code base on the performance of the approach. Are there any distinguishable patterns?

=== *RQ3* How well does the approach generalize to other languages?<rq:3>
The third research question focuses on the generalizability of the approach. It is derived from the requirements #r(4).
The approach should be generalizable to all programming languages.
This research question investigates if the approach is extensible to other languages and if there any limitations.
How large is the effort to add support for a new language?
The form of the research question will be a discussion.
Furthermore, it will quickly analyze the state of the current implementation.

=== *RQ4* How much overhead does the approach introduce?<rq:4>
Lastly, this thesis will analyze the performance overhead introduced by the approach.
After discussing the theoretical overhead, the results section will display the runtime compared against the baseline.

