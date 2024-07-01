#import "/utils.typ": *
== Interrupt-based meta-strategy<chapter:design:ibms>
As sketched in @chapter:introduction:contributions, the interrupt-based meta-strategy is a novel approach to integrate context into model generation.
It is heavily focused on integration multiple information sources independently. The context shall be integrated seamlessly, without affecting the generation flow of the initial generation, except providing the additional information.

=== Requirements
// context integration into model generation => RQ3
The strategy shall be heavily focused on providing a seamless context integration, answering #rq(3).

// work for neural code completion
// support for multiple sources => RQ1
Moreover, the strategy shall support multiple independent sources of information. This will go hand in hand with #rq(1).

// supports any type of use-case => RQ5
The next requirement is for the strategy to be applicable to any type of use-case, such as neural code completion, following #rq(5).

// incur minimal overhead => RQ6
Lastly, the strategy shall incur minimal overhead, as stated in #rq(6).

// TODO: rename to evaluation methodology?
=== Evaluation criteria
To evaluate to what extent the strategy meets the aforementioned requirements, the following evaluation criteria will be used.

// context integration => no criterium, as design itself solves this
Under the condition that the strategy integrates any type of context and is able to remove it, the criterium will be fulfilled.

// support for multiple sources => How are sources differentiated; and between different interrupts?

The requirement of multiple sources will be evaluated by looking at how different sources are differentiated and how extensible the system is. How easy is it to add new sources?

// supports any type of use-case => yes, as edits may be applied anywhere
To evaluate to which use-cases the strategy is applicable, limitations will be identified and discussed.

// minimal overhead => additional generated tokens; interrupt count
Lastly, the overhead will be measured by the amount of additional tokens generated and the number of generation steps.

=== Heritage
This section will discuss the origin of the strategy and insights which led to its evolution.

// derived from meta-strategies that generate a result in multiple steps
In general, the strategy is derived from planning meta-strategies and from Agrawal et al.@agrawalMonitorGuidedDecodingCode.

// sharing context between steps

// typically each step contributes context to the next step, solving the problem incrementally
These meta-strategies decompose a complex problem into multiple steps, where each step contributes to a previous step, solving the problem incrementally. A #acr("CLM") will be prompted for each step, producing a partial or finished result.

Such meta-strategies include Chain-of-Thought@weiChainofThoughtPromptingElicits2023, Tree of Thoughts@yaoTreeThoughtsDeliberate2023a, Graph of Thoughts@bestaGraphThoughtsSolving2023 and others.

Typically, each prompt to the model contains the shared partial solution and instructions for the current step.
The first observation is that the caveat of these strategies is the *granularity of control*. The external monitor processes and may edit partial results in any way, before continuing with the next step, passing a new prompt to the model, containing the partial result and instructions.
Observing and editing the partial result only works on the granularity of a full generation cycle.
The second observation is that the benefit of such a coarse granularity is the ease with which the prompt can be edited. As the edit happens outside of the model generation, large edits, affecting the whole prompt are possible.

The approach in Agrawal et al.@agrawalMonitorGuidedDecodingCode work controls the model generation on a token by token basic, through the use of a monitor. The monitor observes the generation and decides for each token, if control is necessary. If so, then the monitor will control the generation of the next few tokens, until it is not necessary anymore.
The third observation is that the monitor has control only over sequences of tokens, but does not edit the prompt itself, to nudge the model towards a different response.
The final observation is that the benefit of the strategy is the fine granularity on which the strategy operates. The monitor has access to the generation in realtime.

Combining the aforementioned observations, the interrupt-based meta-strategy combines the fine granularity needed to monitor the generation in realtime, with the prompt editing capabilities of multi-step meta-strategies.

=== Components
An overview over the strategy is given in @fig:ibms-components. All components in blue are additions to the normal model generation.
#figure(
  image("/assets/interrupt-based-meta-strategy.drawio.svg"),
  caption: "Components of the interrupt-based meta-strategy",
)<fig:ibms-components>

In summary, the components `Generator`, `PromptEditor`, `Monitor` and `Static Analysis` allow context interruption through a custom interrupt special token, prompt edits and resumption through a controlled model generation loop.

The first main component is the `Generator`. It is the main component orchestrating or initializing the different components. To generate a response using the interrupt-based meta-strategy, first a `Generator` must be initialized.
It in turn will initialize the `Monitor`, the `Prompt Editor` and a connection to external `Static Analysis` tooling.

In addition, it will initialize the tokenizer and model, adding a custom special token to the vocabulary of the tokenizer and resizing the model embeddings to fit the new special token.
The new special token is called the interrupt token and enables interrupting the generation process, as the interrupt token will be added as a stopping criterium.

The `Generator` will start the model generation process, providing the initial prompt to the model. After the model finishes the whole generation, it will check the final token.
If the final token is *not* an interrupt token, the generation process finished normally and the final result is available.
Else the generation was interrupted with additional context.

Then the next component, the `PromptEditor` is called. It will read the retrieved context and edit the prompt in any way.
// ‎ whitespace needed to prevent it from being parsed as a label
#figure(
  code(```plaintext
  [INST]<‎SYS>
  system prompt
  </SYS>
  user prompt
  [/INST]
  model output
  ```),
  caption: "Format of a typical model generation result",
)<code:clm:format>
The `PromptEditor` is completely flexible in where it applies the edits. It may apply the edits to the system prompt or user prompt. It can even dynamically change the model output.
// Resume
The edited prompt is then passed into the model generation again, repeating the generation process.

Inside the model generation, the component `Monitor` watches the generation process, deciding if an interrupt is necessary. It was injected into the default model generation process, by the `Generator`.
The `Monitor` is called for each token prediction, receiving the previous token sequence and the next token prediction and optionally modifying the prediction logits.
In its functionality it is similar to the monitor in Agrawal et al.@agrawalMonitorGuidedDecodingCode, but with the difference that it only controls the prediction of the special interrupt token.
If an interrupt is necessary, the `Monitor` will force the prediction of the interrupt token, thus stopping the generation process.
In addition, it will provide context for retrieval inside the `Generator`.

To decide if an interrupt is necessary, the `Monitor` will call an external `Static Analysis` tool. The `Static Analysis` component represents any form of external tooling that can analyze the current generation and provide additional context. This could include a web search of named entities, a keyword search in local documents or #acr("LSP") tooling. If no additional context was found, the model generation proceeds normally.

To reduce the number of interruptions, the `Monitor` will only interrupt the generation if the additional context is not yet present in the prompt.

// maybe next section
// === Use cases
// code completion

