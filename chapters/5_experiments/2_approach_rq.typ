#import "/utils.typ": *

== Approach Research Questions <chapter:experiments:approach>
The research questions for the approach are directly derived from the requirements of the thesis listed in @requirements.

=== RQ1: Dependency Accuracy <rq:1>
// 1. In which scenarios does normal code completion fail to use dependencies correctly?
// 2. Which scenarios does the approach improve best and under which conditions?
// 3. Why does the approach not improve the results in other cases?

=== RQ2: General Correctness <rq:2>
// 1. How easily does the approach confuse the model?
// 2. Which errors are most common?

=== RQ3: Robustness <rq:3>
// 1: How does the approach handle exceptions and edge cases?
// 2: How does the length of available documentation affect the results?
// 3: Does the approach scale from single code files to large code bases?

=== RQ4: Generalizability <rq:4>
// 1: How well can the approach be extended to other languages?
// 2: For which languages does the approach not work?

=== RQ5: Performance <rq:5>
// 1: How much overhead does the approach introduce?
// Is this even measurable?
