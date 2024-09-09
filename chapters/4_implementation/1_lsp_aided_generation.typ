#import "/utils.typ": *
== Language Server Protocol aided generation
// While the implementation directly focuses on the final approach, this section will focus on the implementation details needed to enable injecting contexts into the prompt
Next to detailing the implementation of the various components, this section will shortly introduce the general project setup, including the used dependencies, the structure and other hints. By transparently providing details on the whole setup, the reproducibility shall be promoted.

=== Project setup
// Versioning
The general implementation of the proposed approach is versioned through Git and can be found here: #link("https://github.com/data-niklas/llm-lsp").
The project contains the installable Python package `llm_lsp`, which enables the usage of the proposed approach in any Python project, such as an evaluation pipeline.

To further simplify the installation, this repository includes a Dockerfile, which can be used to build a Docker image containing all necessary dependencies, to run the approach on GPUs.

// Dependencies

=== Dependencies
This section will list the main package dependencies of the project and their respective uses.
The two main dependencies are `Transformers` (`transformers`) and `PyTorch` (`torch`), as introduced in @chapter:bg:transformers and found in the appendix.

//Transformers
`Transformers` enable neural code completion and provide high- and low-level control over the model's behavior. The implementation will integrate with this library to provide seamless #acr("LSP")-aided code completion with any supported code completion model.
// PyTorch
To manipulate tensors and perform computations, the implementation uses `PyTorch`.
// pygls
Communication to a language server is done through `pygls`, as it enables asynchronous communication between language servers and clients. The types of the #acr("LSP") specification are implemented by `lsprotocol`.
The different asynchronous packages rely on `asyncio` for asynchronous programming.

Lastly, the used language server for the Python language is `python-language-server`, an official language server for Python maintained by the community. It can be installed as a Python package and is developed in Python itself.

=== Structure
The structure of the `llm_lsp` package is as follows:
#figure(
  codefile("/assets/code/llm_lsp_structure.terminal"),
  caption: [The directory structure of the `llm_lsp` package.],
)<terminal:project:structure>

The main component `Generator` is implemented in `generator.py`. Different feature sets of the generator, such as logging, editing token sequences and padding the edited sequences are extracted into the directory `mixins`.
The different `Monitors` `LSP Processor`, `Boundary Processor` and `Comments Processor` are contained in the directory `lsp`, as well as further utilities needed to interact with a language server.
The component `Prompt State` is implemented in `prompt_state.py`, while the `Prompt Formatter` is implemented in the `prompt_formatters` submodule.
Lastly, the submodule `interrupts` contains the behavior for the different types of interrupts.

The other files and submodules contain various types of utilities, fixes, and configurations needed to enable the approach and make it configurable for evaluation. The next sections will focus on the components introduced in @chapter:design:lsp and then continue on with important details on the various other files and submodules.

#todo()[List all design components and classes in this section, to provide an overview]

=== Environment Separation
The approach separates the runtime environment of the approach from the project environment, to prevent conflicts in dependencies.
While e.g. the approach requires a specific version of the Transformers library, the project may also use Transformers, but a different version.
The runtime requires one version for code completion, while the other version is required for the language features, leading to a conflict.

The approach is started while in the runtime environment. The language server uses the project environment, and some functions are run in the project environment.
This will be detailed in later sections.

=== Configuration
All behavior of the approach can be toggled through fields of the data class `LspGenerationConfig`. This enables the analysis of certain behaviors on the performance of the approach, as well as introspection through logging.

The `LspGenerationConfig` is defined as in @code:lsp_generation_config:
#figure(
  codefile("/assets/code/llm_lsp_config.py"),
  caption: [The `LspGenerationConfig` data class, enabling customizable behavior.],
)<code:lsp_generation_config>
The first fields enable the toggling of the `Boundary Processor`, `Comments Processor` and `LSP Processor`, which were introduced in @chapter:design:lsp and are monitors.
To quickly disable the whole approach, the `enabled` field can be set to `False` to overwrite any previous value.

To enable logging, the `chat_history_log_file` field can be set to a file path. The logging behavior is introduced in the `Introspection` section.

During the initialization of the tokenizer and model, the `Generator` may add a custom padding token, if no padding token is present. Setting `force_custom_pad` to `True` can force the addition of the padding token.

The `predict_correct_completion_symbol` field toggles custom behavior for the completion item context injection. If enabled, the list of retrieved completions is presented to the model, to directly predict the correct completion item. Then the predicted completion item is directly inserted into the prompt, before resuming the generation.

The next toggle `masked_gen` controls if the logits of "other" token ids are masked during generation, when completion items or signature help is available.

The final three toggles `use_completion_context`, `use_deprecation_context` and `use_signature_context` control the behavior of the `LSP Processor`. If disabled, the respective context is not injected into the prompt, as the monitor will not cause the respective interrupts.

The implementation additionally extends the Huggingface generation config, adding support for the field `max_interrupts`. If specified, the generation will terminate after at most `max_interrupts` interruptions.

=== Enabling the beam search strategy
As discussed in @chapter:design:ibms, the approach must support generation strategies like the beam search. This requires the following:
#block(breakable: false)[
  1. Storing the final sequences before selecting the single returned sequences.
  2. Storing the sequence selections during generation to reproduce reorderings on objects tracking state for each sequence.
]

The classes providing support are the `BeamTracker` and `BeamIndexStoringSearchScores`, found in `generation_utils/beam_tracking.py`.
The `BeamTracker` class only tracks sequence selections. It contains a list of tuples, where each tuple contains an index for each sequence.
It forms a $|"sequences"| times s$ matrix $T$, where $s$ is the number of steps and is increasing during the generation loop.
$T_(j,i)$ denotes that during step $i$ the sequence $j$ was selected from the $T_(j,i)$ sequence at step $i-1$.

By receiving a list of objects storing state for each sequence, the `BeamTracker` can replay the selection process for all steps, reordering the objects. As several sequences may be selected from the same previous index, the objects may be duplicated.

#figure(
  codefile("/assets/code/beam_tracking.py"),
  caption: [The `rearrange_according_to_beams` method of the `BeamTracker` class, which reorders the items according to the sequence selections.],
)<code:rearrange_according_to_beams>

The second piece of the puzzle is the `BeamIndexStoringSearchScores` class. It is a subclass of the `Transformers` `BeamSearchScorer` class. The `BeamSearchScorer` classes are used internally for the sequence search strategy to process a single generation step to choose the next sequences and to finalize the selection at the end of the generation process.
By subclassing the `BeamSearchScorer` class, the `BeamIndexStoringSearchScores` class has access to the indices of selected sequences at each step.
The instance contains an instance of the `BeamTracker` class, tracking the indices at each step.
Additionally the `BeamIndexStoringSearchScores` class is called with the final sequences before the final selection of the singular best sequence directly before the generation loop ends. These `input_ids` are stored internally for external access by the `Generator` class.
Concretely, the class overwrites the two methods `process` and `finalize`, adding the additional behavior for each step and for the final step, then passing all arguments into the method on the superclass:
#figure(
  codefile("/assets/code/beam_scoring.py"),
  caption: [
    The `BeamIndexStoringSearchScores` class, which tracks the indices of selected sequences at each step and stores the final sequences before the final selection of the singular best sequence.
  ],
)

A later section will detail how the `BeamIndexStoringSearchScores` replaces another instance of the `BeamSearchScorer`.

=== InterruptStoppingCriteria
The `InterruptStoppingCriteria` class is a utility class, which is used to determine if an interrupt occurred inside a monitor and the generation loop should be stopped.
Colloquially, it propagates the interrupt signal to the interrupt loop.
It subclasses the `Transformers` `StoppingCriteria` class.
The class implements the method seen in @code:interrupt_stopping_criteria:
#figure(
  codefile("/assets/code/interrupt_stopping_criteria.py"),
  caption: [The `InterruptStoppingCriteria` class, which determines that the generation loop should be stopped when the interrupt token id occurs.],
)<code:interrupt_stopping_criteria>

=== Generator
The `Generator` component is implemented by the class `Generator` in `generator.py`. It is the main component of the approach and orchestrates the generation process.
The idea is to provide a high-level interface to the user, somewhere between the interface of the `generate` function of #acrpl("CLM") and the `pipeline` abstraction in the `Transformers` library.
The interface shall provide the same interface as the `generate` function, while reducing a few pitfalls through the features of the `pipeline` abstraction, and the added configuration options for the approach.

The following sections include notes on the different features provided by the `Generator`.

==== Initialization.
The `Generator` is the main entry point into the approach and is initialized using a #acr("CLM") (`Transformers` `GenerationMixin`), the fitting tokenizer and a generation config.
Next to the parameters essential for a default generation, it additionally receives the list of enabled interrupt types a `LspGenerationConfig` object.
By default, the three interrupt types `completion`, `deprecation` and `signature` are enabled.
Configuring the behavior of the approach through the `LspGenerationConfig` object is detailed in a later section.

Then the embeddings of the passed model and the vocabulary of tokenizer are initialized, by adding the special tokens needed for the #acr("IBMS").
Additional special tokens are added to the tokenizer through the `add_special_tokens` method. Then the model embeddings are resized to match the new vocabulary size through the `resize_token_embeddings` method.

Not every model has a padding token. As the approach relies on padding tokens to pad the token sequences, the initialization adds a custom padding token to the additional special tokens, if no padding token is present.
In addition to adding the new padding token, the custom padding must be specified as the used padding token through the `pad_token_id` attribute of the tokenizer. The padding token id can be obtained from the tokenizer through the `convert_tokens_to_ids` method after adding the new token.
#todo()[Reference codellama tokenizer -> llama2 tokenizer -> llama1 tokenizer -> sentencepiece implementation: https://arxiv.org/pdf/2307.09288, https://arxiv.org/pdf/1808.06226]

The `Generator` performs two distinct types of explicit initialization: the general initialization and generation specific initialization.
The general initialization creates objects upfront, which can be reused between neural code completions, as they do not depend on the input code.
In contrast, the generation specific initialization is performed for each neural code completion and is dependent on the input code.
The generation specific initialization will be detailed in the later section detailing the interrupt loop.

The general initialization creates both a beam tracker (`BeamTracker` class) and an instance of a `PromptFormatter` class.
The `BeamTracker` is the solution to enable support for the beam search generation strategy, as introduced in @chapter:design:ibms in `Generation Strategy Support`. It will be further detailed later in conjunction with the tweaked generation loop.
The `PromptFormatter` is a class directly implementing the `Prompt Formatter` component. The initialization picks one of two classes: An instance of `VanillaPromptFormatter` is chosen if no context is to be injected into the model, while an instance of `DefaultPromptFormatter` is chosen for the normal preceding of the approach.
The toggle allows for a seamless switch between a baseline and the approach itself, through the passed configuration.

// General initialization

==== Tensor initialization.
Another form of implicit initialization is the control of the default device placement. The device placement regulates on which physical device `PyTorch` tensors are placed on initialization.
It is important that all tensors used during the approach are placed on the same device, else the generation fails.

To control the device placement, the `Generator` class implements a context manager@ContextlibUtilitiesWithstatement, which changes the default device to the device the model was initialized on. The context manager is implemented through the method `device_placement` in the mixin `PipelineMixin`. It sets default device through the `torch.device` function and is inspired by the same behavior occurring in the high level abstraction `pipeline` in the `Transformers` library.

Before starting the neural code completion, the context manager is entered to ensure that all tensors are placed on the correct device. The context manager is exited after the neural code completion is finished:
#figure(
  codefile("/assets/code/device_placement.py"),
  caption: "Entering the PyTorch device context manager before passing all arguments to the wrapped internal completion method.",
)

// Tensor initialization

// Config: TODO Later

// implemented using a class, wrap

// connection to LSP, but will be detailed in the next section

// add special tokens and resize embeddings
// add pad token, as not every model has padding

// contextmanager for device placement
// from huggingface pipeline, but needed

==== Completion.
This section details the interruption loop, which is the core of the enhanced neural code completion.
As noted in the previous section, the actual completion is implemented in the internal method `_complete`, as the method `complete` wraps the method, placing all initialized tensors on the same device as the models tensors.

A shortened version of the completion loop is displayed in @code:completion_loop:
#figure(
  codefile("/assets/code/completion_loop.py"),
  caption: [The interrupt loop, which is the core of the `Generator` class and which enables the #acr("IBMS"). Long argument lists are abbreviated by "`...`"],
)<code:completion_loop>

The core of the loop consists of @code_completion_loop_while_start - @code_completion_loop_while_end and @code_completion_loop_edit_input_ids_start - @code_completion_loop_edit_input_ids_end.
The first lines call the `resume_generation` method, which wraps around the modified `Transformers` generation loop. Lines 12 to 15 check if an interrupt occurred and return the result if the generation ended with an #acr("EOS").
Else line 26 edits the changed prompt into the current input token ids for the next call to `resume_generation`.

To further enable introspection, the initial code is logged and the input token ids are logged between interrupts. The logging behavior is detailed further in the introspection section.

At the start of the method, the generation specific objects are initialized, such as the different monitors, the prompt state, code utilities and other objects. While the monitors work on the input token ids as a whole, other objects work on singular sequences and are initialized for every sequences separately.
Thus, the `PromptState`, `PromptFormatter` and `CodeUtil` instances are created as a list for every single sequence.

Additionally, the initial input token ids are obtained by creating the initial prompt from the provided code and then tokenizing the result.
Usually the prompt is tied to a sequence and formatted using the `PromptFormatter` instance associated with a sequence. At the start of the neural code completion all sequences are the same, which is why the first `PromptState` instance is used.

Other parts of the method handle the augmented generation config. Initially, fields supported by the approach, but unsupported by `Transformers` are removed from the `config` dictionary. Then during each iteration, values such as the maximum allowed time (`max_time`) are updated to reflect the then correct values.
The supported maximum interruptions' configuration value is tracked by the `maximum_interrupts` variable.

@code_completion_expansion is further explained in a later section. The same is true for details on editing and resumption.

==== Resumption.
// 1. Wraps around a generate method, generation loop
// 1. Properly passes arguments into the wrapped method
// 1. Handles result
Although resumption refers to the continuation of the generation process after an interrupt, there is no functional difference between the first generation and generations following an interrupt.
In each case, the interrupt loop calls the `resume_generation` method.
It is a wrapper over the tweaked generation loop, which is detailed in the next section.

Firstly, it resets objects used in the previous generation. Secondly, configuration values are set for the internal generation loop.
At last, it processes the result of the generation loop, to enable support for different strategies and to handle the special interrupt case.

In particular, the wrapper resets both the `LspProcessor` and the `BeamTracker` instances, both clearing any previous interrupts and resetting the tracked selected sequences.

Depending on the passed `LspGenerationConfig`, the different monitors are appended to a list of used `LogitsProcessor` passed to the generation loop.
Additionally, an `InterruptStoppingCriteria` instance is created and added to the parameters of the internal wrapped `generate` method.

The `resume_generation` method passes the parameters `return_dict_in_generate=True` and `output_scores=True`, influencing the structure of the returned result of the wrapped generation loop.
The result is a dictionary-like object containing the returned final sequences over all batches, of which there will be a single one in most cases.
This returned sequence is then processed and returned by the `resume_generation` method. First, any type of custom padding is removed, then any interrupt token is removed if found. At last the sequence is decoded into a text containing only the prompt without other special tokens.

Further steps are necessary to support the beam search strategy. As will be discussed in the `LspProcessor` section, it stores the final `input_ids` of the generation at the time an interrupt is set. These `input_ids` can be used to inject the context and then to resume the generation.
If the beam search strategy is used, these `input_ids` could have been reordered after the interrupt token has been set. Thus the `input_ids` need to be overwritten with the correct `input_ids` after the beam search strategy has applied its own logic.
In that case the correct `input_ids` are obtained from the generation result, which contains the value in the field `beam_input_ids`. This is not the default behavior and was added in the patched generation loop and will be discussed in the next section.

Furthermore, the list of `PromptState` and `CodeUtil` are reordered to match the new sequence selection, using the `BeamTracker`.

==== Tweaked Model Generation.
The internal generation loop is implemented in the `resume` method located in the `InterruptMixin` class. The `resume` method is a patched copy `generate` function of the `Transformers` `GenerationMixin`.
The following patches were applied:
#block(breakable: false)[
  1. No `input_id` expansion is applied.
  2. Beam search strategy generation loop calls are tweaked to use the `BeamIndexStoringSearchScores` class and return the final beam search `input_ids`.
]

Usually the `generate` function receives `input_ids`, which are expanded to fit the number of sequences required by the decoding strategy. At the end of the strategy these sequences are then reduced to a single result. For an #acr("IBMS") to work, the method must receive all sequences upfront and return all sequences at the end.
Thus, the expansion of the `input_ids` is extracted into the additional method `expand_input_ids`. It will be called at the start of the *interrupt loop*, instead of the start of the generation loop.

Secondly, every beam search strategy must use an instance of `BeamIndexStoringSearchScores` as discussed before. Instances of `BeamSearchScorer` are replaced with `BeamIndexStoringSearchScores`, additionally forwarding the instance of the `BeamTracker` into the instance, enabling the tracking of the sequence selection process.
After the generation loop has finished for a beam search strategy, the stored `input_ids` are extracted from the instance and set in the generation result in the `beam_input_ids` field.

==== Editing.
This section details how the prompt and then `input_ids` are edited to inject the new context. The behavior is located in the `TokenSequenceEditMixin` class and is called in @code_completion_prompt_edit_start and @code_completion_loop_edit_input_ids_start.

The first method `edit_generation_text_for_completion` is called with the decoded text and the context to inject.
The decoded text is the prompt of the interrupted sequence, as that interrupt token led to the selection of the sequence as the result.
The context to inject was retrieved from the instance of the `LspProcessor`.
The method performs one of the following two steps:
#block(breakable: false)[
  1. Inject the context into the `PromptState`.
  2. If the option `predict_correct_completion_symbol` is enabled and a completion is present: Determine the next symbol from the given completions and insert it directly into the prompt.
]

In any case, the methods starts by retrieving the generated code from the prompt, using the `PromptState` instance. And finally, the generated code is formatted into the edited prompt using a maybe changed `PromptState`.

// Case 1
In the first case, the interrupt is used to format the retrieved context into a textual representation, insertable into the prompt, called "comment". The exact steps are discussed in the later section `Interrupt Types`.
The comment is then added into the `PromptState` with the interrupt type.

// Case 2
The second case is an experimental method to try and find the correct completion from the list of completion items directly, without inserting the list of completions and implicitly letting the model complete the item.
The method `determine_next_symbol_from_completions` is called, which starts a separate normal model generation. The model is provided the following:
#block(breakable: false)[
  1. The current completed code.
  2. The list of non deprecated completions.
  3. A comment created from the deprecated completions.
]

While the first two points are expected, the third point is added to counteract biased completions by the model towards deprecated items.
The format of the prompt can be seen in @figure:prompt_formatting:completion:
#figure(
  prompt()[
    The following symbols are code completion entries. Determine the appropriate symbol to complete the code in the code block: \`completion_1\`, \`completion_2\`, ..., \`completion_n\`\
    \
    #code(
      ```py
      def input_task(obj):
          """Docstring"""
          return obj.
      ```,
      lang: "Python",
    )
    \
    Return only the single chosen symbol. Do not provide commentary. Output format:\
    \`CHOSEN SYMBOL\`\
    \
    Hint: method `a` is deprecated. Use method `b` instead.
  ],
  caption: [The format of the prompt used to predict the next symbol from the list of non deprecated completions directly.],
)<figure:prompt_formatting:completion>

// raw markdown
The output is expected to be the completion item wrapped in backticks, as usual for raw Markdown text. If the model did not return a result in the expected format, the empty string is returned. Else the predicted completion is returned. The predicted completion is then directly appended to the generated code.

==== Introspection
For any type of neural model generation, introspection into the generation flow is crucial. The result determined by the model can be often times unexpected and confusing.
For complex approaches further manipulating the generation flow, introspection is even more so important, as the complexity hinders the understanding of the generation flow.

To enable understanding on how additional context affects the generation flow, the `Generator` class implements a logging mechanism in the `LogMixin` class. The core idea is to log the generated token sequences to an append-only log between interrupts.
This enables the user to understand how previous interrupts led the model to the token sequences logged in following interrupts.
Additionally, reordering of sequences can be observed.

At its core, the `LogMixin` provides two methods: `log_interruption` and `log_code`.
The method `log_code` is used to log initial and final code states of singular provided and returned code.
Between interrupts the second method `log_interruption` is used to list the contents of each sequence. For readability, the token id sequences are converted back to tokens through the `tokenizer.batch_decode` method.

Generally, the methods have their structure displayed in @code:log_mixin:
#figure(
  codefile("/assets/code/log_mixin.py"),
  caption: [The general structure employed for logging by the `LogMixin`.],
)<code:log_mixin>
The logging mechanism is optional and can be enabled as discussed in the configuration section.
If disabled, the methods are no-ops.

=== Monitors
After discussing the complicated details of the interruption loop and prompt editing, this section provides details on the different monitors `LSP Processor`, `Boundary Processor` and `Comments Processor`.
These classes receive and use state objects created in the `Generator` class. The following sections will only list further created objects and the state objects will not be listed explicitly.

==== LSP Processor Overview.
All processors implement the `LogitsProcessor` interface of the `Transformers` library through the `__call__` method. They receive the `input_ids` for each sequence and the current scores of the next predicted token id.
The implementation of the `__call__` method is found in @code:lsp_processor:
#figure(
  codefile("/assets/code/lsp_processor.py"),
  caption: [The `__call__` method of the `LSPProcessor` class.],
)<code:lsp_processor>

The general flow is as follows:
// Using Python for pseudo code and mentioning the same using bullet points
// TODO: ask for opinion on this, maybe move code to appendix and list bullet points here
#block(breakable: false)[
  1. If the `LSP Processor` is disabled through the configuration, the unchanged scores are returned.
  2. Each sequence is processed individually, after which the updated scores are returned.
  3. For the current completed code in each sequence, the following occurs:
    1. Static analysis is performed on the code.
    2. Heavy filtering is applied to the retrieved completions and signature help.
    3. An interrupt may be triggered, if context is available, throwing an `InterruptGeneration` exception.
    4. The scores are reranked using the available context, if no interrupt is triggered.
  4. If an interrupt is triggered, the interrupt token id will be forced and the context saved in an interrupt object.
]
To perform these actions, in special the static analysis, filtering and reranking, the monitor requires a few additional attributes.

// Signature cache, current interrupt and objects for each sequence, filename, expand size
The first additional attribute is the `signature_cache`, which overlays the plentiful information from the completion items with the signature help to enable complex filtering on the signature help items. By default this is initialized to an empty dictionary, which grows during the generation.

The second attribute is the `interrupt`, which is set to `None` at the start of the generation. If an interrupt is triggered, the interrupt object is set in the interrupt attribute. The method `resume` sets this object to `None`, effectively clearing the interrupt information.

The third attribute `file_names` contains a file name per code to complete. This name serves is used to create a temporary file containing the partial code for static analysis. It is a direct result of the `file_name` argument of the `_complete` method in the `Generator` and is relevant if code in a project file is to be completed.

Lastly, the `expand_size` attribute is used to determine the link between the number of total sequences, sequences per batch and batch count. Usually the different functions use flat lists which contain entries for all batch entries. To determine the batch index from an index of such a flat list, the `expand_size` contains the number of sequences per batch.

==== LSP Processor Context Retrieval.
This section and the following section on the `LSP Processor` will provide details on the behavior of the `scores_for_batch` method, which contains the retrieval, filtering, interrupt triggering and reranking of scores.

The method starts with the following logic seen in @code:scores_for_batch_start:
#figure(
  codefile("/assets/code/lsp_processor_retrieval.py"),
  caption: [Start of the `scores_for_batch` method, listing how the context retrieved from a language server.],
)<code:scores_for_batch_start>

The method starts by determining the partially completed code of the current sequence using the `current_code` method. The `current_code` method reuses the `PromptState` abstraction to do so. The only new difficulty lies in finding the correct `PromptState` instance, as the `LSPProcessor` stores an instance per sequence and the ordering of the stored instances and the passed `input_ids` could be different due to beam search reordering. Generally, the class uses the `BeamTracker` to determine the reordered indices, then retrieve the correct object of the current sequence and then use the object to perform the action.

Similarly, the file name of the current batch is retrieved using the `get_file_name_for_batch` method.

Lastly, the abstraction `LspCodeFile` is used to interact with the language server. The `LspCodeFile` abstraction is detailed in the `Language Server` section.
The returned `lsp_code_file` object is used to firstly retrieve the completion items and then the signature help items.
As detailed in @chapter:bg:lsp, retrieving the completions is a two-step process, as the completions must be resolved to include detailed information needed for filtering.

To prevent the use of completion items, if the completion is not needed, the method `should_complete` is called. If the current code ends in one of the following symbols, the completions are not needed: ")", "\\n", " ", "\\t", "]", "}". This effectively limits the use of completion items to the following scenarios:
- Completion of a symbol.
- Start of the dereference operator.
, and reduces model confusion after completing a single function call and reduces completion of unneeded symbols everywhere.
// TODO: reformulate?

To prepare for the filtering, a `trigger_phrase` is determined. The trigger phrase is used to determine if a completion item is already partially completed, the current code ends in a prefix of a completion item. This trigger phrase is obtained by finding any symbol the code ends with through the regular expression `[A-Za-z_]*$`.

Lastly, the signature cache is increased using the retrieved completion items. The method `increase_signature_cache` extracts the keyword from builtin completion items. If no item is stored in the cache under that keyword, the completion item is assigned to the keyword in the `builtin_cache` attribute.

==== LSP Processor Filtering.
First the signature help items are filtered, after which the completion items are filtered.
Each filtering is performed through a chain of methods, each taking at least a list of items and returning the filtered list.

From the signature help items, the following filters are applied:
#block(breakable: false)[
  1. Remove signature help items of builtin functions.
  2. Remove items without parameters.
]

The method should improve completion of functions with changed parameters and complex signatures. As such the second filter ignores the case in which a function does not have parameters. The first filter reduces the model confusion by completing probably known functions unchanged.
To obtain the information if a signature help item is a builtin function, the signature cache is used, as the information is stored in the completion items. If a matching completion items is a builtin item, the signature help item is skipped.

From the completion items, the following filters are applied:
#block(breakable: false)[
  1. Remove builtin completion items.
  2. Constrain completion items to relevant #link(label("code:completion_item_kind"), "Kinds").
  3. Remove items from the current partial completion.
  4. Constrain to public items.
  5. Remove items which are already fully completed.
]

The steps are as described in @chapter:design:lsp. Most filtering steps are straightforward, as they only require fields directly present in the completion items, or simple string matching.
The following minor details are required:
- Builtins are recognized by matching the value `"builtins"` in the `detail` field..
- Private methods are recognized through the name starting with an underscore.

==== LSP Processor Interrupt Triggering.
As described in the design section, the filtered completion items are split into deprecated and non-deprecated items. After splitting, the code checks if completion items, deprecation items and signature help items are to be inserted (in that specific order).

The #acr("LSP") defines that completion items include a list of associated tags, which include the information if the item is deprecated. In theory this enables easy splitting of completion items into deprecated and non-deprecated items. In practice not every language server correctly detects deprecated items.
The widely used language server for Python, `python-lsp-server`, does not correctly detect deprecated items.

Thus, this work implements the custom function `is_deprecated`, to properly detect deprecated items. The function relies on the behavior described in #acr("PEP") 702@PEP702Marking and reads the meta-attribute `__deprecated__` of the item, which is present in deprecated items.
The function is implemented in @code:is_deprecated:

#figure(
  codefile("/assets/code/is_deprecated.py"),
  caption: [The `is_deprecated` function, which determines if a completion item is deprecated. This function is called from a subprocess using the project environment.],
)<code:is_deprecated>

@code:is_deprecated loads the module a value is stored in, retrieves the value from the module and then checks for the meta-attribute `__deprecated__`. If the field is present, the value is deprecated, in any other case it is not.

To use the function in the `LSP Processor`, the import path of the value is constructed, by concatenating the module path from the `detail` field with the name of the symbol in the following format: `is_deprecated(completion.detail + "." + completion.insert_text)`.

As this function needs to be run in the project environment, the function is extracted into a separate file `venv_language_features.py`, which is then executed using the Python interpreter of the project environment. All variables are communicated via standard streams.
As importing, starting many processes is slow, and the function is called repeatedly, the results are memoized using the `lru_cache` decorator.

#todo[Talk about scope, so when can items be removed? in design]
After splitting the items, each of the three interrupt types completion, deprecation and signature help checks if context needs to be inserted. Each of the three checks works similarly:
#block(breakable: false)[
  1. If the interrupt type is disabled in the configuration, the check is skipped.
  2. If no items were found, no interrupt is triggered.
  3. If items were found, they are compared to the already inserted context.
    1. If no context of the interrupt type is present, the interrupt is triggered.
    2. If context of the interrupt type is present, but different from the items, the interrupt is triggered.
    3. Else, no interrupt is triggered.
]

To check for inserted context, the `LSP Processor` uses the `PromptState` instance of the current sequence. To account for reordering of sequences, the `BeamTracker` instance is used to retrieve the correct instance of the `PromptState` instance.

The interrupt is thrown through the `trigger_interrupt` method, which raises the custom `InterruptGeneration` exception. It includes the interrupt type and associated context.
The outer loop of the `LSP Processor` then catches the exception, sets the interrupt token id in the scores and sets the interrupt object in the `interrupt` attribute.
The interrupt object has the structure seen in @code:interrupt_object:
#figure(
  codefile("/assets/code/interrupt_object.py"),
  caption: [The `Interrupt` dataclass, which is used to store the interrupt context and the interrupt token id.],
)<code:interrupt_object>

The object additionally contains the current `input_ids` at time of interrupt, which will be used to inject the context and for resumption.
The thrown exception is strictly not needed, as the method `scores_for_batch` could have returned a tuple of the scores and maybe set interrupt.
As the interrupt itself is passed through the generation through the custom interrupt token, this approach is compatible with other runtimes which do not support these types of exceptions.

==== LSP Processor Reranking.
As described in the design section, token ids which are prefixes of a non-deprecated completion item should be ranked higher than token ids that are prefixes of deprecated completion items. Other token ids should be masked.
Token ids which are prefixes of tokenized non-deprecated completions will henceforth be called `non-deprecated token ids`, and similarly `deprecated token ids` for deprecated completions.

For the reranking, the `LSP Processor` first applies a constant adjustment to the scores using the method `apply_constant_adjustments`. Then deprecated tokens ids are ensured to stay below non-deprecated token ids in the method `ensure_deprecated_below_non_deprecated`. Finally, masking occurs in the method `mask_other_tokens`.

`apply_constant_adjustments` applies a delta to the score of the token ids. A positive delta is applied to non-deprecated token ids, a negative delta to deprecated token ids. The delta is empirically fixed to $7.0$.

In contrast, `ensure_deprecated_below_non_deprecated` determines the minimum non-deprecated token score. Then any scores of deprecated token ids above the minimum are fixed to the delta value below the minimum, to ensure a gap of at least the delta.

The masking is skipped if masking is disabled in the `LspGenerationConfig`. The implementation was adapted from the masked generation in Agrawal et al. @agrawalMonitorGuidedDecodingCode. For details see #link("https://github.com/microsoft/monitors4codegen/blob/022c65efb19cf6046d0b67960ca232ae7a351af4/src/monitors4codegen/monitor_guided_decoding/hf_gen.py#L30C15-L30C49", "their logits processor").
#footnote[While the design of the strategy was developed independently of Agrawal et al, the implementation was retrofitted to support masked generation.]

When an interrupt should occur, the score of the interrupt token is fixed to $1000.0$.
This score was picked empirically, as all other observed scores were below $1000.0$ and it is unlikely for scores to be higher.
While the design section stated to use the highest possible value, the highest value $oo$ did not work in practice, as the model would produce the following error:
#figure(
  terminal(```terminal
  RuntimeError: probability tensor contains either `inf`, `nan` or element < 0
  ```),
  caption: [The error message produced by PyTorch when the score of the interrupt token is set to the highest possible value.],
)<code:cuda_error>

=== PromptState
The `PromptState` class is contained in `prompt_state.py` and is a direct implementation of the `PromptState` component.
At its core, it contains a list of inserted comments of the sequence index it is assigned to.
Next to the comments, the `PromptState` uses the tokenizer to convert between the prompt and token ids. Additionally it requires a `PromptFormatter` instance to format the prompt into the appropiate format.

The `PromptState` is initialized with the initial given code and no comments. Then the private method `_create_completion_prompt` creates the initial prompt to the model through the following steps:

#block(breakable: false)[
  1. All comments are joined into a single string using newlines.
  2. The `PromptFormatter` instance is used to create a list of messages, given the initial text and instruction text.
  3. The messages are formatted into a prompt, using the tokenizer method `apply_chat_template`, into the model specific prompt format.
]
The method is called whenever the list of comments is changed to update the initial prompt. The initial prompt is only used for generation initially.
It is used to track the prefix of the prompt, including the comments, which is then used to determine the completed code without comments, or to create a new prompt with edited comments.
The comments are changed through the `add_comment` method, which takes a comment of an interrupt type and adds it to the list of comments.
In a previous step all comments of the same interrupt type are removed, ensuring that only the most recent instruction of an interrupt type is present.
This limits the scope of the context to the next context instance. For function signature context, the context would stay included until the next function call is completed.
If the comment is empty, no instruction is added, effectively removing the previous instruction of the interrupt type.

After adding comments, the method `format` takes the current completed code, wraps it into Markdown code block and appends it to the initial prompt, which contains the comments.
This results in the following prompt format seen in @figure:prompt_formatting:full:
#figure(
  prompt()[
    #bos#inst #sys\
    Return only the completion of the given function. Follow the instructions in the code comments for additional instructions on how to complete the code. Generate readable and simple code.
    #sys-\
    Complete the following Python function. Return only code.\
    Hint: The method `dict` is deprecated. Use `model_dump` instead.
    #inst-\
    #code(
      lang: "Python",
      ```py
      def convert_user_to_dict(user):
          return user.
      ```,
    )
  ],
  caption: [A full sample prompt, including system and user prompt, comments and initial code.],
)<figure:prompt_formatting:full>

To read only the generated code or the full code sample, the methods `get_generated_code` and `get_full_code` are used.
`get_whole_code` receives a decoded text, removes the initial prompt using simple string processing, then extracts the code from the Markdown code block.
`get_generated_code` builds on top of `get_whole_code` and removes the initially provided code from the full code.

==== Tokenization Issues.
This class heavily relies on simple string processing of the prompt, i.e. removing a known prefix from the completed prompt.
This works under the assumption that tokenization is reversible, that $x = "detokenize"("tokenize"(x))$ for all prompts $x$.
In practice this is not true. As investigated by Imgrund@imgrundLocatingEditingKnowledge2024, 31% of tokenized then detokenized tokens yield a different token.
This especially affects this work when using CodeLlama in the following example:
"#bos#inst" will be tokenized then detokenized to "#bos #inst".
This affects every single generation and is a critical problem. Other issues were observed infrequently.
To address this issues, the method `get_generated_code` first fixes the received prompt by applying several string replacements to fix the issues. It for example replaces "#bos " with "#bos".

=== Interrupt Types
The approach uses the two context sources completion items and signature help items to provide the three types of interrupts "completion", "deprecation" and "signature".
Each of the interrupt types is used to inform the model about available completions, deprecated completions which it should not use and signatures of functions.

Each interrupt type is implemented through a subclass from the #acr("ABC") `InterruptType`, which is located in `interrupts/__init__.py`.
The implementation of the base class is shown in @code:interrupt_type:
#figure(
  codefile("/assets/code/interrupt_type.py"),
  caption: [The `InterruptType` abstract base class, which is used to implement the different interrupt types.],
)<code:interrupt_type>

As can be seen in @code:interrupt_type, each subclass must provide a (unique) type name through the method `type_name`, and must be able to create a comment, given a context and a `CodeUtil` instance.
#todo[Define process from retrieval, context, comment, prompt clearly]
The created comment is optional. In the case that no comment is returned, the `PromptState` will remove previous comments as described in the previous section.

In the case of the "completion", the created comment will have the following structure:
#figure(
  prompt()[
    Hint: The following symbols are code completion entries. Use the appropriate symbol to complete the current code: #bar(300deg, 3em), #bar(340deg, 3em), ..., #bar(370deg, 3em)
  ],
  caption: [The structure of the comment created by the "completion" interrupt type. The insert texts of all items are joined with ",", similar to the colored bars.],
)

For deprecation items, the comment will have the following structure:
#figure(
  prompt()[
    Hint: #bar(300deg, 5em)\
    Hint: #bar(340deg, 5em)\
    Hint: #bar(370deg, 5em)
  ],
  caption: [The structure of the comment created by the "deprecation" interrupt type. For each item, a line with a hint is created, where the deprecation message is inserted at the position of the colored bar.],
)

For signature help items, the comment will have the following structure:
#figure(
  prompt()[
    Hint: The code item has the following signature: #bar(120deg, 5em)\
    The code item has the following documentation:\
    #h(2em)#bar(300deg, 5em)\
    Provide as few arguments as possible and as many as needed. Provide arguments as positional arguments instead of as named arguments if possible. Often times optional arguments can be omitted
  ],
  caption: [The structure of the comment created by the "signature" interrupt type. The green bar is replaced by the signature text of the item, while the pink text is replaced by the shortened documentation string.],
)

=== Language Server
The final section of the implementation of the approach describes any details on interacting with a language server.
The following paragraphs start with the initialization of a language server, how the static analysis is triggered and how issues between synchronous and asynchronous code have been resolved.

==== Initialization.
As described above, generation specific state is initialized in the `initialize_generation_state` method. There a language server is initialized for the programming language of the code provided.
The programming language is detected by the file type.
The function `create_lsp_for_language` in `lsp/__init__.py` calls the correct function for the specific language.
In the case of Python, `create_python_lsp` is called.

The dependency `pygls` provides the class `BaseLanguageClient`, which abstracts the creation and protocol communication. By calling the method `start_io("pylsp")` with the binary of the language server, the binary is executed in a separate process and communication occurs via standard streams.
Now different method can be called, which each provide a different feature of the #acr("LSP").
As described in the protocol, the initialization flow is the following:
#block(breakable: false)[
  1. Client sends a `initialize` request, the server responds with its capabilities.
  2. Client sends a `initialized` notification.
  3. Client can now send further requests to configure the server or retrieve information.
]
Respectively, the methods `initialize_async` and `initialized` are called to fulfill the first two steps. The first method has the `_async` postfix, as it awaits a responds using asynchronous Python code, while the second is only a notification and does not require a response.
The code passes several important initialization parameters to the language server:
/ `root_path`: The path to the root directory of the project. This is important to correctly determine project specific settings, such as virtual environments with dependencies.
/ `capabilities`: All used capabilities are registered, such as completion and signature help requests:
  / `tag_support`: Enable support for the deprecation tag on completion items.
  / `resolve_support`: Enable support to receive detailed information on completion items, enabling complex filtering.

Additionally, to the #acr("LSP") messages, the environment variable `VIRTUAL_ENV` is ensured to be set. If it is not set yet, the virtual environment is determined by the project root path and set.
The environment variable is used by the language server to determine the installed packages and to provide completion items and signature help.
This allows separating the runtime environment for the approach and the project environment, ensuring that the approach does not interfere with the project environment.

==== Temporary Code File.
The completion and signature help on partially completed code is abstracted through the `LspCodeFile` class in `lsp/file.py`.
The language server operates on files stored on disk, while the generated code is stored in memory. To bridge this gap, the `LspCodeFile` creates a temporary unique file for each partially completed code.
It then notifies the language server about the new file, and then provides the completion and signature help on the file.

To determine a unique file path, the `LspCodeFile` uses a given path to a file as a base, which could be the origin file of the code in completion. It then appends a unique identifier to the path, by generating a UUID1. The temporary file is then stored next to the original file, thus allowing imports to behave normally.
If the code completion occurs on a singular file, the exact directory the temporary is stored in is not important.

Then a `TextDocumentItem` instance is created, representing the code file for the #acr("LSP").
The two methods `__enter__` and `__close__` are used to create and delete the file. In addition, the server is notified that the file is opened or closed through the `text_document_did_open` and `text_document_did_close` methods.
By defining `__enter__` and `__close__`, the class can be used as a context manager (i.e. `with` statement), ensuring correct cleanup of the temporary file.

The language features, such as completion and signature help, occur at a certain `Position` in the document. In the case of the approach, the position is always at the end of the document.
The method `char_line_of_code` takes the current code and returns the line and character position of the last character in the code. It first splits the code into lines, counts the last line, then counts the characters in the last line.

The three methods `ask_completions`, `resolve_completions` and `ask_signature` first determine the last position, then call the language server with the respective language feature request.
One peculiarity is `ask_completions`, as the completion response may be in one of two formats. The server either returns a list of completion items or a `CompletionList` object, which contains the completion list in the `items` field.
In the latter case, the completion list is extracted from the field and returned.
The method `resolve_completions` iterates over the completion items and calls `completionItem/resolve` for each item separately.

==== Sync vs Async.
The initialization and communication with the language server is highly asynchronous, as two different processes communicate through standard streams.
After sending a request, the server may respond at any time, which yields an awaitable to the client.
Thus, the `pygls` library depends on `asyncio` to handle the asynchronous communication.
This requires the whole code to be asynchronous, such that the outer program initializes an event loop and runs the asynchronous code.
Therefore, the `complete` method of the `Generator` is asynchronous, propagating the asynchronous nature into inner methods, such as the language server initialization.

The Transformers library, however, is synchronous. All implemented subclasses of Transformers classes contain synchronous methods, such as the `__call__` method of the `LSPProcessor`.
Thus, the asynchronous nature is not progragated through the generation loop to the `LSPProcessor`.
To use the completion and signature help features, the `LSPProcessor` now requires access to the outer event loop, to run the asynchronous functions.
To solve this problem, the asynchronous code, nested in synchronous code, nested in asynchronous code, retrieves the current event loop and calls `run_until_complete` on every called asynchronous function:
#figure(
  codefile("/assets/code/lsp_file.py"),
  caption: [Waiting on to be returned completions from the language server. The asynchronous code is run in the synchronous code by retrieving the current outer event loop.],
)

By default, `asyncio` does not allow the use of such nested asynchronous code. The implementation uses the dependency `nest_asyncio` to patch the `asyncio` library to allow nested asynchronous code.
