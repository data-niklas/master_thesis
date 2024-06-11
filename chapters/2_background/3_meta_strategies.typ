#import "/utils.typ": *

== Meta-Strategies <bg_meta_strategies>
#acrpl("CLM") provide many different ways to tune the generated text. From switching the model itself, to choosing a different text generation strategy, many different combinations are possible. Sometimes these knobs are not enough and an integration to external tooling is needed. Integrating external tooling into the model generation is harder, the deeper the integration should be rooted. The simplest form of integration is to reverse orders and integrated the model into a wider `meta-strategy`. This chapter will introduce common meta-strategies and discuss drawbacks and benefits.

A meta-strategy is a strategy that incorporates the model text generation into a wider strategy. The meta-strategies treat the models as a black box that produces a generated text, given an input. The meta-strategies may use this black box indefinitely. In addition, several black boxes could be combined.

Generally, the main benefits are ease of use and flexibility. Any model can easily be integrated into the meta-strategy and stay interchangable. By combining several models into a multi-turn process, including external tooling, powerful behavior is possible.

Models do not have up-to-date information and are sometimes unable to solve problems on their own. Meta-strategies can remedy these issues, by providing the model with up-to-date information and focusing it towards a goal.

Common drawbacks of meta-strategies are the added complexity towards the already complex text generation. Also calling models several times makes the process slower.
// TODO rewrite

=== Chain of Thought
// Only introduce it, do not mention code related stuff here yet.
@weiChainofThoughtPromptingElicits2023
=== Tree of Thought
