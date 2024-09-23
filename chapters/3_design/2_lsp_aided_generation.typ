#import "/utils.typ": *

== Language Server Protocol aided generation<chapter:design:lsp>
The #acr("LSP") aided generation builds upon the #acr("IBMS").
It applies the strategy to neural code completion, injecting context information from the #acr("LSP") server into the prompt at runtime.
In addition to injecting context into the prompt, the logits in the next token prediction are controlled using the context, to improve the robustness of the work.

This section will first list the thoughts leading towards the design of the work.
Then, it will provide an overview of the components introduced in the work.
Finally, it will detail the design decisions made for the components.

=== Heritage
The key thought guiding the work is:
#thought()[
  Developers base their decisions on contextual information provided by the #acr("LSP") server.
  \ Why can the neural code completion not do the same?
]

// Developers base their decisions on contextual information provided by the #acr("LSP") server.
// Why can't the neural code completion do the same?
Developers use a wide variety of tools to guide their programming decisions. Code completion is the most frequently used tool inside #acrpl("IDE") @amannStudyVisualStudio2016.
It displays available symbols, their documentation and type information.
Next to code completion, signature help is another important tool, as it displays available parameters of selected functions and their types, thus providing information about the structure of the data.
Additionally, #acrpl("IDE") highlight the code with diagnostics information, such as important errors or warnings which may be ignored. The diagnostics information guide the developer to potential problems, such as wrong symbols, code smells, or dead code.

This approach aims to guide the #acr("CLM") using the same information sources developers have access to. The analysis in @chapter:design:analysis already highlights the benefits of using a language server in combination with a #acr("MGD")-like strategy.
@chapter:design:ibms provides insights into how these information sources can be integrated into a neural code completion model.

The next observation is that the developer is provided with a vast amount of information, of which only a few select items are relevant. The approach must perform heavy filtering to provide only the relevant few items.

The last observation is that #acr("CLM") may be heavily biased towards generating old deprecated code, even when guided away using prompt injection. As such, the approach must force the model away from deprecated code by directly manipulating logits.

=== Components
An overview over the work is given in @fig:lsp-aided-components. All components in blue are additions to the normal model generation.
#figure(
  image("/assets/lsp-aided-generation.drawio.svg"),
  caption: "Components of the LSP aided generation",
)<fig:lsp-aided-components>
//

As the work is based on the #acr("IBMS"), the components are similar to the ones in @fig:ibms-components.
The main difference is the added complexity in the previous `Monitor` component, which now features several distinct subcomponents. Other differences are the specific use of #acr("LSP") and a more complex prompt processing.

// Generator
// RQ3
// RQ6

==== Generator.
The `Generator` component depicted in @fig:lsp-aided-components is more specific in handling the prompt and injected context. The previous component `Prompt Editor` is now replaced with the two more specific components `Prompt State` and `Prompt Formatter`.

==== Prompt State.
The `Prompt State` component contains a structured representation of the initial prompt and all injected context information.
It is a general utility class, which is used in the `Monitors` and in the `Generator` to extract the completed code and to reconstruct the edited prompt.
Extraction of the completed code is possible by detokenizing the partial result and removing the initial prompt prefix.
As often the detokenization is not the inverse of the tokenization, the `Prompt State` class includes fixes for the detokenization.
To reconstruct the edited prompt, the `Prompt State` passes the initial prompt and injected contexts to the `Prompt Formatter`.

==== Prompt Formatter.
The `Prompt Formatter` abstracts different prompt formats used in different models. For models based on Llama, it would use the format defined in @code:clm:format.
Different models allow different prompt sections, such as a system and a user prompt. Depending on the availability of such sections, the component decides how to embed the context.

==== LSP Processor.
The difference in the `Monitors` is the threefold divide into subcomponents. The first subcomponent `LSP Processor` corresponds to the previous component `Monitor`. It receives context from a `Language Server` (previous `Static Analysis`) and enables the #acr("IBMS") applied to code completion.
The task of the `LSP Processor` is twofold. First, it enables the #acr("IBMS"). Secondly, it controls the logits to force the model towards certain behavior, when guiding is not enough.
// TODO: Writing to a temporary file
// TODO: how control logits

==== Boundary Processor.
The purpose of the `Boundary Processor` is to fix boundary issues when using tokenizers which allow multi-character tokens.
Usually, #acr("LSP") information, such as autocompletion and signature help, is requested after every keystroke in an #acr("IDE"), or for certain hotkeys.
The autocompletion information is especially useful after the dereference operator (`.` in Python, `->` in C++), as then available symbols are displayed.
The signature help information is useful after starting to write a function call, as then the available parameters are displayed.

As tokenizers allow tokens with several characters, the vocabulary could include tokens that start with a trigger character, followed by any tail.
For autocompletion, this could include tokens such as "`.model`". For signature help, this could be a token such as "`()`".
By predicting these tokens, the completed code would "jump" over the critical trigger characters, thus ignoring the autocompletion or signature help information.

The `Boundary Processor` fixes this issue by identifying all tokens prefixed with a trigger character and replacing these tokens with the trigger character only.
It ensures that the logits value of the trigger character is higher than any other token containing the trigger character as a prefix.

==== Comments Processor.
Next to the `Boundary Processor`, the `Comments Processor` solves an issue regarding the generation of comments. A possible place to inject the context is in the completed code, as a code comment.
The problem is that a model could see the code comments after an interrupt and try to predict a code comment preceding the next code block. Thus, code comments could be tainted by the code prediction itself.
The `Comments Processor` disallows the generation of code comments, by stopping the prediction of the token starting a code comment by setting the logits value to $-oo$.

=== Design Decisions
This section provides details on different design decision for the introduced components. The first design decision will be for how the #acr("IBMS") is integrated. Then the different processing steps will be detailed. At last, the reranking details are presented.

// RQ1: code completion provides available symbols, documentation and type information
// RQ1: signature help provides parameters for chosen functions
==== IBMS Integration.
The first design decision is the selection of sources to suggest fitting code. The previous sections already highlight why the #acr("LSP") is fitting.
The protocol provides a vast amount of different information.
We argue that the core information to use are the completion items and the signature help information.
When generating code, the primary source is the completion items, as they dictate the available symbols. The completion items list the attributes of objects and which attributes are deprecated and should be replaced.
After using the completion items to write callable code, the secondary source is the signature help. Likewise, the signature help lists available parameters of a function call and includes documentation.
Both types of information sources allow code generation using up-to-date information. Other features provided through #acr("LSP") may improve code generation, but are not vital, such as diagnostics information. In addition, both sources can be used on partial code and provide suggestions on how to extend the code, aiding the natural #acr("CLM") generation flow.
Diagnostic information and other information reference code already written, increasing the difficulty to integrate into the natural generation flow.

The second design decision is about the position of the injected context in the prompt. We argue that this position is dependent on the instruction following capabilities of the model. The used #acr("CLM") must be able to react to the injected context.
For most instruction tuned models, the context should be injected into the user prompt, to fit the model's capabilities.
If the model is not instruction tuned, then the context should be injected into the generated code as a code comment, to mirror code "instructions" found in live code.
This leads to the need for a `Comments Processor` to suppress the generation of normal code comments.
// Future models trained on special tokens with injected context

==== Information Filtering.
// TODO:
// RQ1: No algorithmic information, except diagnostics data
// RQ1: Would require higher decision making

// RQ2: Problem: too much information fills token limit => information needs refinement
// RQ2: 1. Control generation based on deprecation information
// RQ2: 2. Filter completion symbols on next token prediction
// RQ2: 3. Filter built-in functionality, such as standard library functions, or other functions already present in the current context (=> file)
// RQ2: 4. Remove completions already completed
// RQ2: 5. Remove completions, such as snippets, units colors etc.
// RQ2: 6. Remove signatures without parameters
This section details the different processing steps for the retrieved completion items and signature help.
Both sources provide critical information, but also a lot of irrelevant information not needed to decide on the next code piece.
Such context pollutes the context window of a #acr("CLM") and worsens the prediction quality. As such, preprocessing is needed to filter such data.

// Allow only specific types (no snippets)
// Remove builtins
// Remove from current file
// Additional private or meta functions (__, __getitem__)
// Stop completion item already completed
// Only allow completion items extending the current partial word

Completion items are initially filtered by their `CompletionItemKind`#footnote()[The full list is visible in @code:completion_item_kind]. Only items of kind `Method`, `Field`, `Class`, `Function`, `Property` or `Variable` are allowed, to remove kinds such as `Snippet`, `Color` and `File`.

To reduce confusion further, completion items of builtins are removed, as the assumption is made that the model has the knowledge of builtins. If the model does not have knowledge about builtins, this filter can be disabled, to e.g. improve support of low resource languages.
Filtering is done by checking the `detail` field of the completion item, as it contains the origin of the code item, such as the code file.

Next, completion items from the current code piece are removed. Similarly, it is assumed that the current code is in the context of the #acr("CLM").
Again, this filter checks the `detail` field of the completion item.

Then private or meta functions are removed, such as the `__getitem__` function in Python. These functions are not meant to be called directly.

To avoid the completion of already completed code, the to-be-inserted text is checked against the ending of the currently generated code. This also removes items that do not properly extend the current code.
// TODO: explain more

// Deprecation vs non-deprecation
Then the completion items are split into two categories, the non-deprecated and the deprecated completion items. This differentiation allows later steps to guide the model towards non-deprecated items, while avoiding deprecated items.

The model may be biased towards generating old deprecated code. To only focus on the deprecated items, which the model _may_ predict, the deprecated items are finally filtered by the next predicted token id.
// Filter deprecation by next token

==== Logits Manipulation.
These design choices try to ramify the problem of overlapping tokens in deprecated and non-deprecated completion items. Instead of masking all token ids that are not a prefix of one of the completions items, this argues for the following:
- Token ids that are a prefix of a completion item should be scored higher.
- Token ids that are a prefix of a deprecated completion item and a non-deprecated completion item should be scored lower.
- Other token ids should be masked.

The exact delta score is not specified by the design and is left to the implementation.

The score of the interrupt token is fixed to the maximum possible logits value, if an interrupt should occur.
