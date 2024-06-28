#import "/utils.typ": *

== Controllable Generation <chapter:bg:controllable_generation>
#acrpl("CLM") suffer from many problems, such as outdated knowledge, insufficient knowledge and insufficient capabilities. Most of these problems can be adressed by fine-tuning the model on further data, such as up-to-date information.
The problem with fine-tuning is the need for a large amount of up-to-date data, which might not exist yet. In addition. fine-tuning is resource intensive and must be performed continously, to stay up-to-date.

This section will showcase different ways to control the generation of the model, without the need to perform fine-tuning. The text generation is complex and there are many different strategies and components, which may be controlled. Guided generation will focus in strategies to control the prediction of a single next token, while the chapter prompting strategies will focus on prompting techniques.

=== Guided Generation <chapter:bg:guided_generation>
The #acr("CLM") generates a text, by iteratively choosing the next token ids. The decision on which token ids is the next token id, depends on two factors, as discussed in @chapter:bg:llms. It depends on the logits produced through the raw next token prediction function $f_"rntpf"$ and a decoding strategy.
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

=== Prompting strategies
Prompting strategies are a set of techniques to control the generation of the model externally. The model itself, or the model runtime itself is not modified. As such this technique is model agnostic. The general goal is to control the output through structured prompts. In addition, the model may be incorporated into external tooling to enable complex workflows.

The simplest form of control through prompting is to add instructions to the prompt. Models will follow the instructions, if the model was trained on instructions in a similar format. So called "instruction fine-tuned models" were fine-tuned especially on instructions, to improve instruction following capabilities. Non instruction fine-tuned models can still follow instructions, but then the instructions must be chosen carefully.

A useful instruction is to define the desired output format. For example, by specifying that the model should output the response in #acr("JSON") format or Markdown format, the model will use the specified format. Especially formats such as Markdown and #acr("JSON") are preferred, as they are common formats and thus the model performs especially well in these formats.
Specifying the desired format increases the predictability of the response, which allows automated processing of the response.
Specifying to respond in an unknown format does not work. Steering the model does not raise the capabilities of the model, but raises the efficiency with which its capabilities are used.

If the model does not have enough knowledge to respond to a prompt, the prompt itself can be structured to supply the needed information. Given the model has the ability to understand the provided information, it can then act on the information. A popular technique is *few-shot prompting*@brownLanguageModelsAre2020.

Few-shot prompting involves providing the model with several examples in the prompt. The goal is that the model understands the provided examples to learn the pattern and apply it to its response. The learning is undertaken "in context" and not persisted outside of the prompt itself@brownLanguageModelsAre2020. The knowledge provided to the model is the format of the task and matching response.

#example(
  caption: "Few-shot prompting",
  ```md
    *Prompt:*
    Q: What is the capital of Germany?
    A: Berlin
    Q: What is the capital of France?
    A: Paris
    Q: What is the capital of Italy?

    *Response:*
    A: Rome
  ```,
)<example:few_shot>

As can be seen in @example:few_shot, the model prefixes the response with `A: ` and does not provide additional information. The output format was not specified explicitly, but matches the format of the examples perfectly.

In contrast to providing knowledge about a desired response format, *context injection* adds important context into the prompt, which the model then uses to respond.

#example(
  caption: "Context injection",
  ```
  *Prompt:*
  The capital of Germany was changed to Heidelberg.
  What is the capital of Germany?

  *Response:*
  Heidelberg
  ```,
)<example:context_injection>

@example:context_injection demonstrates how adding information controls the response of the model. This technique is very powerful, but comes with two strong restrictions:
1. Finding relevant context.
2. Limited prompt size.

The first restriction is that the injected context must first be found. This is a hard search problem, as the information must be retrieved *before* prompting, before the intent of the prompt is known yet. In @example:context_injection the task of the #acr("CLM") is question answering. Even though the general task is known, the software has no way to known the specific domain, such as "country capitals" beforehand.

The second restriction is the limited prompt size. Models are only capable of focusing on a prompt of limited size. Thus, token space is precious and may not be wasted. Providing the model with an up-to-date version of Wikipedia for every prompt oversaturates the prompt size limit instantly. The injected context must be *targeted* and *relevant*. The more *targeted* the context is, the less tokens are used.

As finding relevant context is a hard problem, several steps are needed to search for the context. Searching for relevant context may even involve the output of another #acr("CLM"). Strategies that involve the model in a multi-step process are called meta-strategies. These strategies will be further discussed in the next section.

=== Meta-Strategies <chapter:bg:meta_strategies>
// TODO: merge with guided generation, under section "controllable generation"
// TODO: mention that it is possible without fine-tuning
Meta-strategies incorporate a model into an algorithm according to a wider strategy. These strategies shift the focus to viewing the #acrpl("CLM") as a building block to be used as needed. Several models with different strenghts could be combined into a meta-strategy.

// Benefits
Generally, the main benefits are ease of use and flexibility. Any model can easily be integrated into the meta-strategy and stay interchangable. By combining several models into a multi-turn process, including external tooling, powerful behavior is possible.

In contrast, common drawbacks of meta-strategies are the added complexity towards the already complex text generation. In addition, calling models several times increases the runtime of the program, if used without care.

// Example
Meta-strategies are applied to e.g. remedy the model lack of up-to-date knowledge. A model may not have the necessary knowledge for a task, or the knowledge it has is outdated. In such cases the meta-strategy can supply up-to-date information and focus the model towards the problem.

// TODO rewrite
==== Chain of Thought
Chain of Thought is one very central meta-strategy, as it significantly improves the reasoning capabilities of a model@weiChainofThoughtPromptingElicits2023.

The key idea of chain of thought is to apply the divide and conquer strategy to the text generation process. Instead of the model trying to solve a complex reasoning problem in a single step, the meta-strategy divides the problem into several intermediate step. The model is then able to solve the simpler intermediate steps. Each intermediate step is a thought the model contributes to the final solution. The sequence of intermediate steps forms the "chain" of thoughts@weiChainofThoughtPromptingElicits2023.

Additionally, the model will use thoughts of previous steps to reason about the next step.

// Benefits

// Only introduce it, do not mention code related stuff here yet.

// TODO: self consistency with CoT?

#note("Can be removed with Chain of thought")[==== Tree of Thought]
Tree of thoughts is a generalization of chain of thought. Chain of thought is only capable of performing linear decision-making@weiChainofThoughtPromptingElicits2023. Ultimately, performing complex reasoning is a search problem and thus, linear reasoning is insufficient.
The tree of thoughts meta-strategy generalizes the thoughts into a tree structure. Each intermediate problem is then a node in this search tree. The root of the tree is the initial problem. The goal of this search problem then is to find an accepted end node - a finishing thought@yaoTreeThoughtsDeliberate2023a.

By structuring the thoughts into a tree, common tree search algorithms can be applied to the problem. Various algorithms such as a breadth-first search or depth-first search can be applied@yaoTreeThoughtsDeliberate2023a.

// Benefits
In general, the tree of thoughts meta-strategy is more powerful than the chain of thoughts. It is a very powerful and flexible strategy, which even allows following thoughts and then backtracking@yaoTreeThoughtsDeliberate2023a.

@yaoTreeThoughtsDeliberate2023a

// TODO: details? math, drawbacks, images, examples
