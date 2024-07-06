#import "/utils.typ": *
== Interrupt-based meta-strategy<chapter:design:ibms>
As sketched in @chapter:introduction:contributions, the #acrf("IBMS") is a novel approach to integrate context into model generation.
It is heavily focused on integration multiple information sources independently. The context shall be integrated seamlessly, without affecting the generation flow of the initial generation, except providing the additional information.
The strategy shall serve as a basis for globally guiding the model generation, by dynamically injecting relevant context into the prompt.

=== Requirements
The interrupt-based meta-strategy is just a single part in the overall approach. Thus, the requirements are separate from the general requirements.

The exact requirements are listed in @table:ibms:requirements.
#figure(
  table(
    columns: 2,
    table.header([Identifier], [Keyword]),
    [*R#sub[IBMS]1*],
    [Multiple source support],
    [*R#sub[IBMS]2*],
    [Flexible context location],
    [*R#sub[IBMS]3*],
    [Minimal overhead],
  ),
  caption: [Special requirements of the #acr("IBMS")],
)<table:ibms:requirements>

==== Multiple source support.
The goal of the strategy is to integrate context of multiple sources. As such, the strategy must be able to differentiate between different sources and process these independently.

==== Flexible context location.
In addition to integrating multiple sources, the integrated context should be able to be placed anywhere in the prompt. It could be integrated into the system prompt, the user prompt or even the model output at "runtime".

==== Minimal overhead.
The last requirement is for the strategy to have minimal overhead over the default model generation. Integrating context should not affect the generation flow of the model in any way, not even performance wise.

=== Heritage
While previous sections introduced the need for this strategy, this section will discuss the observations leading to the design of the strategy.

// derived from meta-strategies that generate a result in multiple steps
While the strategy was developed independently of Agrawal et al.@agrawalMonitorGuidedDecodingCode, the design uses the same observation made for the `Monitor` component in their work.
The `Monitor` not only allows controlling model logits at runtime, but it allows *observing the generation in realtime*.
This allows a fine-grained control over the model generation, which is not possible with general prompt engineering or meta-strategies.
Coupled with any form of static analysis, the monitor can find additional relevant context.
This is similar to the iterative approach of `RepoCoder`. `RepoCoder` uses each iteration to retrieve relevant code based on the current whole generation, while this observation leads to an approach which finds context during a single generation.

The second observation is that the `Monitor` is only able to influence the generation on a token by token basis, but cannot guide the whole flow of the generation. Meta-strategies and prompt engineering can guide the whole flow of the generation, but cannot retrieve relevant information efficiently.

The third key observation bridges the gap between meta-strategies and fine-grained control from the `Monitor`.
Additional tokens can be added to the vocabulary of a tokenizer for inference and the model embeddings can be resized to fit the new token. The model will not be able to meaningfully predict the added token, as it was not trained on the ad-hoc token, but strategies can use the added token to elicit behavior.
For example, the token can be used as an additional #acr("EOS") token, stopping the generation process, but with the added semantic information of the special token.

Combining the aforementioned observations, the #acr("IBMS") combines the fine granularity needed to monitor the generation in realtime, with the prompt editing capabilities of multi-step meta-strategies, through the use of an added special token.

=== Components
An overview over the strategy is given in @fig:ibms-components. All components in blue are additions to the normal model generation.
#figure(
  image("/assets/interrupt-based-meta-strategy.drawio.svg"),
  caption: [Components of the #acr("IBMS")],
)<fig:ibms-components>

In summary, the components `Generator`, `PromptEditor`, `Monitor` and `Static Analysis` allow context interruption through a custom interrupt special token, prompt edits and resumption through a controlled model generation loop.

The first main component is the `Generator`. It is the main component initializing and orchestrating the different components. To generate a response using the #acr("IBMS"), first a `Generator` must be initialized.
It in turn will initialize the `Monitor`, the `Prompt Editor` and a connection to external `Static Analysis` tooling.

In addition, it will initialize the tokenizer and model, adding a custom special token to the vocabulary of the tokenizer and resize the model embeddings to fit the new special token.
The new special token is called the interrupt token and only be used during the approach. No further training with the token is necessary, as the model will not need to predict the tokens, as the `Monitor` component will force the prediction of the interrupt token.

The `Generator` will start the model generation process, providing the initial prompt to the model. After the model finishes the whole generation, it will check the final token.
If the final token is *not* an interrupt token, the generation process finished normally and the final generation result can be obtained by removing any remaining injected context through the `PromptEditor`.
Else the generation was interrupted with additional context and the `PromptEditor` can edit the prompt with the context. To allow the continuation of the generation, the final interrupt token is removed from the generated token sequence.

Then the next component, the `PromptEditor` is called. It will read the retrieved context and edit the prompt in any way.
To edit the prompt, the `PromptEditor` must work on the textual prompt, by detokenizing the prompt, applying any edits and tokenizing the prompt again.
To perform edits such as deletions, the `PromptEditor` must be aware of the location and type of inserted context.
Thus, it stores a list of injected context, each with their location and type.

To inject context, the editor inserts the textual representation of the context at a location, then saving the location and type of the context. If the location is before any other injected context, the locations of the following contexts shift forward by the length of the textual representation of the injected context and must be changed accordingly.

Removing context is done similarly, by finding context in the list of all injected contexts, removing it from the stored location and shifting the location of all following contexts back by the length of the removed context.

// ‎ whitespace needed to prevent it from being parsed as a label
#figure(
  prompt()[
    [INST]\<SYS>\
    system prompt\
    </SYS>\
    user prompt\
    [/INST]\
    model output
  ],
  caption: "Format of a typical model generation result",
)<code:clm:format>
@code:clm:format shows the format of a (partial) model generation output. The editor is flexible and can edit the prompt in any way, even inserting context into the partial model output.

// Resume
The edited prompt is then passed into the model generation again, repeating the generation process.

Inside the model generation, the component `Monitor` watches the generation process, deciding if an interrupt is necessary. It was injected into the default model generation process by the `Generator`.
The `Monitor` is called for each token prediction, receiving the previous token sequence and the next token prediction and optionally modifying the prediction logits.
In its functionality it is similar to the monitor in Agrawal et al.@agrawalMonitorGuidedDecodingCode, but with the difference that it only controls the prediction of the special interrupt token.
If an interrupt is necessary, the `Monitor` will force the prediction of the interrupt token.
In addition, it will store the retrieved context for access by the `Generator` and `PromptEditor` after interruption.

To decide if an interrupt is necessary, the `Monitor` will call an external `Static Analysis` tool. The `Static Analysis` component represents any form of external tooling that can analyze the current generation and provide additional context. This could include a web search of named entities, a keyword search in local documents or #acr("LSP") tooling. If no additional context was found, the model generation proceeds normally.
Next to deciding if an interrupt is necessary to add context, the `Monitor` may also decide to remove old context. The interruption process is similar, with the difference in the stored context information.

To reduce the number of interruptions, the `Monitor` will only interrupt the generation if the additional context is not yet present in the prompt.
To allow interruption of the model generation, the `Generator` adds a stop condition to the model generation loop. The stop condition checks for the existence of the interrupt token in the generated token sequence. As soon as the `Monitor` forces an interruption, the stop condition stops the model generation.

=== Generation Strategy Support
// Meta-strategy with differences
The design mentioned in the previous section uses multiple model generation steps to arrive at a final result.
This is similar to a typical multi-step meta-strategy, but with the difference that no major changes are made to the prompt.
Each prompt to the model is an edited version of the previous prompt, with the only difference being the injected context.

Moreover, the strategy has a tighter control over the model generation, through the use of the interrupt token *and* support for model generation strategies.
The previous section simplified the resumption of the model generation behavior, suggesting that the model generation can be resumed directly after interruption and context injection.
This is the case for simple decoding strategies like greedy decoding, which generate on a single `beam`.

Complex decoding strategies like beam search require complex handling, as they operate on multiple beams.
At the start of a typical generation process using beam search, firstly $k$ hypothesis of the input prompt are initialized.
Then the generation process is started, with each hypothesis predicting the next token to form $k*V$ combinations, of which the top-k combinations are kept.

When the stop condition is met, the *singular* top hypothesis is selected as the generation result.
The `Generator` must ensure that the interrupted generation returns the current top-k hypothesis and is resumed with the edited top-k hypothesis.

To support complex decoding strategies, the `Generator` must use an edited model generation loop, that can store all beams currently in the generation process and which can resume the generation process with existing beams.
Additionally, interrupts occur on a single beam, not affecting other beams. Each component storing state must store the state for each beam separately. E.g. the `PromptEditor` will store the injected context for each beam separately.

Furthermore, the `Generator` must ensure the correct order of beams, as the order of beams can change during the generation process, e.g. in the top-k selection process in the beam search, as it may keep the top-k beams sorted descending.
After interruption, the then current top-k beams originate from $l lt.eq k$ original beams, where $l$ depends on the spread of selected beams. If each of the $k$ beams is continued at each step, then $l = k$.
If the top-k beams all originate from a single beam, then $l = 1$.

