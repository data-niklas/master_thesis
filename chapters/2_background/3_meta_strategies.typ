#import "/utils.typ": *

== Controllable Generation <bg_controllable_generation>
#acrpl("CLM") suffer from many problems, such as outdated knowledge, insufficient knowledge and insufficient capabilities. Most of these problems can be adressed by fine-tuning the model on further data, such as up-to-date information.
The problem with fine-tuning is the need for a large amount of up-to-date data, which might not exist yet. In addition. fine-tuning is resource intensive and must be performed continously, to stay up-to-date.

This section will showcase different ways to control the generation of the model, without the need to perform fine-tuning. The text generation is complex and there are many different strategies and components, which may be controlled. Guided generation will focus in strategies to control the prediction of a single next token, while the chapter meta-strategies will focus on prompting techniques.

=== Guided Generation <bg_guided_generation>
The #acr("CLM") generates a text, by iteratively choosing the next token ids. The decision on which token ids is the next token id, depends on two factors, as discussed in @bg_llms. It depends on the logits produced through the raw next token prediction function $f_"rntpf"$ and a decoding strategy.
Guided generation is a technique to modify the logits before the decoding strategy is applied. The logits are modified according to a set of domain specific rules. The rules not only have access to the current logits, but also to the previously generated text. Thes allows for complex rules.

Consider the following example:
#example(caption: "Enforcing \"yes\" or \"no\" answers")[
  A model is tasked with answering a "yes" or "no" question. The model should only respond with either of both words, without discussing any details or making small talk.

  The rules for the guided generation are to set the logits of all tokens to $-oo$, except when the tokens contribute to a "yes" or "no" answer.

  Given the prompt "Is the sun shining?" and the previous tokens "Ye", the guided generation will set all logits to $-oo$, except for the token "s". In the next step only the #acr("EOS") token will be permitted.
  Thus, the model will respond with "Yes".
]

Guided generation has the benefit of allowing complex rules to be applied to the generation process, to allow a very tightly controlled generation.

The downside of guided generation is, that for complex scenarios, the rules may become very complex and hard to define. In these cases prompting strategies might be more appropriate.
// Downside is that model does not know why it was guided, so follow up token prediction bad?

@wengControllableNeuralText2021

=== Meta-Strategies <bg_meta_strategies>
// TODO: merge with guided generation, under section "controllable generation"
// TODO: mention that it is possible without fine-tuning

// Intro
#acrpl("CLM") provide many different ways to tune the generated text. From switching the model itself, to choosing a different text generation strategy, many different combinations are possible. Sometimes these knobs are not enough and an integration to external tooling is needed. Integrating external tooling into the model generation is harder, the deeper the integration should be rooted. The simplest form of integration is to reverse orders and integrated the model into a wider `meta-strategy`. This chapter will introduce common meta-strategies and discuss drawbacks and benefits.

// Definition
A meta-strategy is a strategy that incorporates the model text generation into a wider strategy. The meta-strategies treat the models as a black box that produces a generated text, given an input. The meta-strategies may use this black box indefinitely. In addition, several black boxes could be combined.

// Benefits
Generally, the main benefits are ease of use and flexibility. Any model can easily be integrated into the meta-strategy and stay interchangable. By combining several models into a multi-turn process, including external tooling, powerful behavior is possible.

In contrast, common drawbacks of meta-strategies are the added complexity towards the already complex text generation. In addition, calling models several times increases the runtime of the program, if used without care.

// Example
Meta-strategies are applied to e.g. remedy the model lack of up-to-date knowledge. A model may not have the necessary knowledge for a task, or the knowledge it has is outdated. In such cases the meta-strategy can supply up-to-date information and focus the model towards the problem.

// TODO rewrite
=== Chain of Thought
Chain of Thought is one very central meta-strategy, as it significantly improves the reasoning capabilities of a model@weiChainofThoughtPromptingElicits2023.

The key idea of chain of thought is to apply the divide and conquer strategy to the text generation process. Instead of the model trying to solve a complex reasoning problem in a single step, the meta-strategy divides the problem into several intermediate step. The model is then able to solve the simpler intermediate steps. Each intermediate step is a thought the model contributes to the final solution. The sequence of intermediate steps forms the "chain" of thoughts@weiChainofThoughtPromptingElicits2023.

Additionally, the model will use thoughts of previous steps to reason about the next step.

// Benefits

// Only introduce it, do not mention code related stuff here yet.

// TODO: self consistency with CoT?

=== Tree of Thought
Tree of thoughts is a generalization of chain of thought. Chain of thought is only capable of performing linear decision-making@weiChainofThoughtPromptingElicits2023. Ultimately, performing complex reasoning is a search problem and thus, linear reasoning is insufficient.
The tree of thoughts meta-strategy generalizes the thoughts into a tree structure. Each intermediate problem is then a node in this search tree. The root of the tree is the initial problem. The goal of this search problem then is to find an accepted end node - a finishing thought@yaoTreeThoughtsDeliberate2023a.

By structuring the thoughts into a tree, common tree search algorithms can be applied to the problem. Various algorithms such as a breadth-first search or depth-first search can be applied@yaoTreeThoughtsDeliberate2023a.

// Benefits
In general, the tree of thoughts meta-strategy is more powerful than the chain of thoughts. It is a very powerful and flexible strategy, which even allows following thoughts and then backtracking@yaoTreeThoughtsDeliberate2023a.

@yaoTreeThoughtsDeliberate2023a

// TODO: details? math, drawbacks, images, examples
