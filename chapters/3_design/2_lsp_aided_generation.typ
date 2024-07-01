#import "/utils.typ": *

== Language Server Protocol aided generation<chapter:design:lsp>
The #acr("LSP") aided generation builds upon the interrupt-based meta-strategy.
It applies the strategy to neural code completion, injecting context information from the #acr("LSP") server.
In addition to injecting context into the prompt, the logits in the next token prediction are controlled using the context, to improve the robustness of the work.

This section will first talk about the heritage, introduce the components of the design and lastly discuss design decisions.

// === Evaluation criteria
// The requirements are directly derived from the goals of this thesis. The following evaluation criteria measure the different research questions.
//
// Similar to the evaluation criteria for the requirements of the interrupt-based meta-strategy #rq(6), the performance aspect can be measured directly.
// Other aspects, such as #rq(1), #rq(2), #rq(3), #rq(4) will be measured by comparing the scores of the neural code completion model with and without the #acr("LSP") aided generation. The neural code completion without the #acr("LSP") aided generation will serve as a baseline.
// In addition, differences in the results will be discussed.
// #rq(5), the generalization aspect, will measure how easy it is to extend this thesis to different programming languages.

=== Heritage
// The why?
The key thought guiding the work is:
#thought()[
  Developers base their decisions on contextual information provided by the #acr("LSP") server.
  \ Why can't the neural code completion do the same?
]

// Developers base their decisions on contextual information provided by the #acr("LSP") server.
// Why can't the neural code completion do the same?
Developers use a wide variety of tools to guide their programming decisions. Code completion is the most frequently used tool inside #acrpl("IDE")@amannStudyVisualStudio2016.
It displays available symbols, their documentation and type information.
Next to code completion, signature help is another important tool, as it displays available parameters of selected functions and their types, thus providing information about the structure of the data.
Additionally, #acrpl("IDE") highlight the code with diagnostics information, such as important errors or warnings which may be ignored. The diagnostics information guide the developer to potential problems, such wrong symbols, or code smells, such as dead code.

=== Components
An overview over the work is given in @fig:lsp-aided-components. All components in blue are additions to the normal model generation.
#figure(
  image("/assets/lsp-aided-generation.drawio.svg"),
  caption: "Components of the LSP aided generation",
)<fig:lsp-aided-components>
//

As the work is based on the interrupt-based meta-strategy, the components are similar to the ones in @fig:ibms-components.
The main difference is the added complexity in the previous `Monitor` component, which now features several distinct subcomponents. Other differences are the specific use of #acr("LSP") and a more complex prompt processing.

// Generator
// RQ3
// RQ6

The `Generator` component depicted in @fig:lsp-aided-components is more specific in handling the prompt and injected context. The previous component `Prompt Editor` is now replaced with the two more specific components `Prompt State` and `Prompt Formatter`.

The `Prompt State` component contains a structured representation of the initial prompt and all injected context information.
It is a general utility class, which is used in the `Monitors` and in the `Generator` to extract the completed code and to reconstruct the edited prompt.
Extraction of the completed code is possible by detokenizing the partial result and removing the initial prompt prefix.
As often the detokenization is not the inverse of the tokenization, the `Prompt State` class includes fixes for the detokenization.
To reconstruct the edited prompt, the `Prompt State` passes the initial prompt and injected contexts to the `Prompt Formatter`.

The `Prompt Formatter` abstracts different prompt formats used in different models. For Llama based models, it would use the format defined in @code:clm:format.
Different models allow different prompt sections, such as a system and a user prompt. Depending on the availability of such sections, the component decides how to embed the context.

The difference in the `Monitors` is the threefold divide into subcomponents. The first subcomponent `LSP Processor` corresponds to the previous component `Monitor`. It receives context from a `Language Server` (previous `Static Analysis`) and enables the interrupt-based meta-strategy applied to code completion.
The task of the `LSP Processor` is twofold. First, it enables the interrupt-based meta-strategy. Secondly, it controls the logits to force the model towards certain behavior, when guiding is not enough.

The purpose of the `Boundary Processor` is to fix boundary issues when using tokenizers which allow multi-character tokens.
Usually, #acr("LSP") information, such as autocompletion and signature help, is requested after every keystroke in an #acr("IDE"), or for certain hotkeys.
The autocompletion information is especially useful after the dereference operator (`.` in Python, `->` in C++), as then available symbols are displayed.
The signature help information is useful after starting to write a function call, as then the available parameters are displayed.

As tokenizers allow tokens with several characters, the vocabulary could include tokens that start with a trigger character, followed by any tail.
For autocompletion, this could include tokens such as `.model`. For signature help, this could be a token such as `()`.
By predicting these tokens, the completed code would "jump" over the critical trigger characters, thus ignoring the autocompletion or signature help information.

The `Boundary Processor` fixes this issue by identifying all tokens prefixed with a trigger character and replacing these tokens with the trigger character only.
It ensures that the logits value of the trigger character is higher than any other token containing the trigger character as a prefix.

Next to the `Boundary Processor`, the `Comments Processor` solves an issue regarding the generation of comments. A possible place to inject the context is in the completed code, as a code comment.
The problem is that a model could see the code comments after an interrupt and try to predict a code comment preceding the next code block. Thus, code comments could be tainted by the code prediction itself
The `Comments Processor` disallows the generation of code comments, by stopping the prediction of the token starting a code comment by setting the logits value to $-oo$.

=== Design Decisions
This section provides details on different design decision for the introduced components.

The first design decision is the selection of sources to suggest fitting code, as introduced in #rq(1).

// initialize different components
// embeddings for new special token
// check final token to stop

// Prompt State
// RQ4
// RQ3

// Prompt Formatter
// RQ3

// Monitors
// RQ2
// RQ4
// RQ6

// Language server
// RQ5

// LSP:
// @Specification

// TODO: references for software development

// RQ1: code completion provides available symbols, documentation and type information
// RQ1: signature help provides parameters for chosen functions

// RQ1: No algorithmic information, except diagnostics data
// RQ1: Would require higher decision making

// RQ2: Problem: too much information fills token limit => information needs refinement
// RQ2: 1. Control generation based on deprecation information
// RQ2: 2. Filter completion symbols on next token prediction
// RQ2: 3. Filter built-in functionality, such as standard library functions, or other functions already present in the current context (=> file)
// RQ2: 4. Remove completions already completed
// RQ2: 5. Remove completions, such as snippets, units colors etc.
// RQ2: 6. Remove signatures without parameters

// RQ3: Combine instruction tuned model with information in the user prompt
// RQ3: No system prompt for generality, as not every model has system and user prompt
// RQ3: Alternative: Insert as code comment into the output in the line before

// RQ4: Combine context injection with logits manipulation for deprecation information

// RQ5: The #acr("LSP") abstracts away programming language specifics

// RQ6: Filtering and only injecting context if not available, interrupt count is reduced
