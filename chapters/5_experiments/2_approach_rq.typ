#import "/utils.typ": *

== Approach Research Questions <chapter:experiments:approach>
The research questions for the approach are directly derived from the requirements of the thesis listed in @requirements.
To evaluate the research questions, the following general experiment is conducted.

The DependencyEval dataset is used in conjunction with the listed models, to evaluate neural code completion both with and without the approach.
The evaluation using normal code completion is used as a baseline to compare the results with the approach.
For each model, different configurations are evaluated, depending on the research question.
At last, the results provided by the DependencyEval pipeline are analyzed to answer each research question.

=== Dependency Accuracy
To measure and evaluate the accuracy on how the model uses dependencies, the following research questions are posed.
For each of the research questions, the evaluation will focus on the deprecation scenarios introduced in the design section.
E.g. the section will allow functionally incorrect code, as long as the dependencies are used correctly, no deprecated code is used and the correct function parameters are used.
// TODO: say denpendency test is used

==== RQ1: In which scenarios does regular code completion fail to use dependencies correctly?<rq:1>
// 1. In which scenarios does normal code completion fail to use dependencies correctly?
While further research questions focus on possible improvements using the approach, this question starts with the current state of code completion.
It goes beyond simply evaluating the accuracy of the baseline, but aims to identify concrete scenarios where the baseline fails to use dependencies correctly.
Further research questions shall analyze how the approach impacts these scenarios.

In the evaluation, only the results of the baseline are considered. The results are mainly grouped by the scenario of the task.
To further distinguish trends between model configurations and models, the results are also grouped by each model and different configurations.
For each scenario, failing tasks are analyzed, concretely identifying the issues.

Additionally, Copilot is used to evaluate DependencyEval, obtaining further baseline results.

==== RQ2: Which scenarios does the approach improve best and under which conditions?<rq:2>
// 2. Which scenarios does the approach improve best and under which conditions?
After identifying issues with the baseline, the approach is applied to improve the results. This research question focuses on the cases where the approach improves the results the most.
It aims to understand why the improvement occurs and under which conditions the approach is most effective.
Next to analyzing differences in the prompt and logits manipulation, also differences between model configurations and capabilities are considered.

Both the results of the baseline and the approach are considered.
Similar to #rq(1), the results are mainly grouped by the scenario of the task, and secondly by each model and different configurations.
The difference is that now only the successful tasks are analyzed.

==== RQ3: Why does the approach not improve the results in other cases?<rq:3>
// 3. Why does the approach not improve the results in other cases?
In contrast to the previous research question, this questions focuses on the remaining cases where the approach does *not* improve the results, or even worsens them.
It aims to understand why the approach fails, to identify shortcomings and limitations of current models, model configurations, and the approach itself.

The remaining tasks in the experiments are analyzed, focusing on the differences between the baseline and the approach.

=== General Correctness
After evaluating the accuracy of the models when using dependencies, the general correctness of the models is evaluated.
// TODO: say functional test is used

==== RQ4: How easily does the approach confuse the model?<rq:4>
The research question focuses on the general robustness of the approach and checks if the approach can improve scenarios without affecting the functional result.
How easily is the model confused by the approach?

Especially the experiment results of the approach are analyzed against the baseline, which fail the functional test, but pass the approach test.
// 1. How easily does the approach confuse the model?

==== RQ5: Which errors are most common when applying the approach?<rq:5>
// 2. Which errors are most common?
This question goes a step further and analyzes the exact errors that occur when applying the approach.
It aims to understand the perturbations that are most likely to confuse the model.
It differs from #rq(3), as #rq(3) focuses on the failings on improving dependency handling.

=== Robustness
The following two research questions focus on different aspects of robustness.

// ==== RQ6: How does the approach handle exceptions and edge cases?<rq:6>
// 1: How does the approach handle exceptions and edge cases?

==== RQ6: How does the availability of documentation affect the results?<rq:6>
// 2: How does the length of available documentation affect the results?
The first aspect analyzes the use of information sources, namely code documentation.
Can the approach improve the results when almost no documentation is available?
Does the approach have issues with too much documentation?

The analysis will split the results into groups, based on the amount of documentation available in the dependency.
It will then proceed to separately compare results and trace how the approach uses the documentation.

==== RQ7: How does the approach handle differently sized code bases?<rq:7>
// 3: Does the approach scale from single code files to large code bases?

Similarly to #rq(6), the results are split into groups based on the size of the code base of the dependencies.
Does the approach scale from single code files to large code bases?

=== Generalizability
Next to the robustness, the generalizability to new programming languages is evaluated.
While the approach was implemented in Python and the implementation has support for Python, the approach should be generalizable to other languages.

==== RQ8: How well can the approach (implementation) be extended to other languages?<rq:8>
// 1: How well can the approach be extended to other languages?
#rq(8) focuses on how well the approach works with different programming languages.
It aims to understand the requirements needed to add support for a new language.
As the implementation is limited to Python, the research question also evaluates how well the implementation can be extended to other languages.
Thus, it also evaluates how high the effort of scaling the approach to other languages is.

==== RQ9: For which languages does the approach not work?<rq:9>
// 2: For which languages does the approach not work?
As an addition, #rq(9) focuses on the limitations of the approach. It goes a step further and analyzes the requirements for adding support for a new language in-depth.
It differs from #rq(8), as #rq(8) focuses on the implementation and effort, while #rq(9) focuses on the limitations of the approach itself.

=== Performance
The final research question focuses on the performance of the approach. As described in the requirements, the approach should not introduce significant overhead.

==== RQ10: How much overhead does the approach introduce?<rq:10>
// 1: How much overhead does the approach introduce?
Thus, the first research question focuses on the overhead incurred by the approach.
After analyzing the theoretical overhead, the actual overhead is measured and compared to the baseline.

For each experiment, the time to completion is measured and compared to the baseline.

// Is this even measurable?
