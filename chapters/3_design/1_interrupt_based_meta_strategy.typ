#import "/utils.typ": *
== Interrupt-based meta-strategy<design_ibms>
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
// monitor
// - uses static analysis
// - runs each token
// - on interrupt, generates edit of type

// generation state
// - handles batching / beam search, as several generations happen batched and may be reordered (beam search)
// - decoding strategy aware edits

// Edit handler
// - applies edit to the prompt

// maybe next section
// === Use cases
// code completion

