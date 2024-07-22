#import "/utils.typ": *
== Language Server Protocol aided generation
// While the implementation directly focuses on the final approach, this section will focus on the implementation details needed to enable injecting contexts into the prompt
Next to detailing the implementation of the various components, this section will shortly introduce the general project setup, including the used dependencies, the structure and other hints. By transparently providing details on the whole setup, the reproducability shall be promoted.

=== Project setup
// Versioning
The general implementation of the proposed approach is versioned through Git and can be found here: #link("https://github.com/data-niklas/llm-lsp").
The project contains the installable Python package `llm_lsp`, which enables the usage of the proposed approach in any Python project, such as an evaluation pipeline.

To further simplify the installation, this repository includes a Dockerfile, which can be used to build a Docker image containing all necessary dependencies, to run the approach on GPUs.
#todo()[README with run instructions and installation instructions]

// Dependencies

=== Dependencies
This section will list the main package dependencies of the project and their respective uses.
The two main dependencies are `Transformers` (`transformers`) and `PyTorch` (`torch`), as introduced in @chapter:bg:transformers and @chapter:bg:torch.

//Transformers
`Transformers` enables neural code completion and provides high- and low-level control over the model's behavior. The implementation will integrate with this library to provide seamless #acr("LSP") aided code completion with any supported code completion model.
// PyTorch
To manipulate tensors and perform computations, the implementation uses `PyTorch`.
// pygls
Communication to a language server is done through `pygls`, as it enables asynchronous communication between language servers and clients. The types of the #acr("LSP") specification are implemented by `lsprotocol`.
The different asynchronous packages rely on `asyncio` for asynchronous programming.

Lastly, the used language server for the Python language is `python-language-server`, an official language server for Python maintained by the community. It can be installed as a Python package and is developed in Python itself.

=== Structure
The structure of the `llm_lsp` package is as follows:

#link(
  "https://github.com/data-niklas/llm-lsp/tree/main/llm_lsp",
  [#figure(
      terminal(```terminal
      [green,black]❯[text,medium] tree -L 1 --dirsfirst
      [subtext1]├── [sapphire,bold]code_utils
      [subtext1]├── [sapphire,bold]debug
      [subtext1]├── [sapphire,bold]generation_utils
      [subtext1]├── [sapphire,bold]interrupts
      [subtext1]├── [sapphire,bold]lsp
      [subtext1]├── [sapphire,bold]mixins
      [subtext1]├── [sapphire,bold]prompt_formatters
      [subtext1]├── config.py
      [subtext1]├── constants.py
      [subtext1]├── generator.py
      [subtext1]├── __init__.py
      [subtext1]├── __main__.py
      [subtext1]└── prompt_state.py
      ```),
      caption: [Directory structure of the `llm_lsp` package.],
    )<terminal:project:structure>],
)

The main component `Generator` is implemented in `generator.py`. Different feature sets of the generator, such as logging, editing token sequences and padding the edited sequences are extracted into the directory `mixins`.
The different `Monitors` `LSP Processor`, `Boundary Processor` and `Comments Processor` are contained in the directory `lsp`, as well as further utilities needed to interact with a language server.
The component `Prompt State` is implemented in `prompt_state.py`, while the `Prompt Formatter` is implemented in the `prompt_formatters` submodule.
Lastly, the submodule `interrupts` contains the behavior for the different types of interrupts.

The other files and submodules contain various types of utilities, fixes and configurations needed to enable the approach and make it configurable for evaluation. The next sections will focus on the components introduced in @chapter:design:lsp and then continue on with important details on the various other files and submodules.

#todo()[List all design components and classes in this section, to provide an overview]

=== Configuration
All behavior of the approach can be toggled through fields of the data class `LspGenerationConfig`. This enables the analysis of certain behaviors on the performance of the approach, as well as introspection through logging.

The `LspGenerationConfig` is defined as in @code:lsp_generation_config:
#figure(
  code(
    lang: "Python",
    ```python
    @dataclass
    class LspGenerationConfig:
        boundary_processor: bool = True
        comments_processor: bool = True
        lsp_processor: bool = True
        enabled: bool = True
        chat_history_log_file: Optional[str] = None
        force_custom_pad: bool = False
        predict_correct_completion_symbol: bool = True
        masked_gen: bool = True
        use_completion_context: bool = False
        use_deprecation_context: bool = True
        use_signature_context: bool = True
    ```,
  ),
  caption: [The `LspGenerationConfig` data class, enabling customizable behavior.],
)<code:lsp_generation_config>
The first fields enable the toggling of the `Boundary Processor`, `Comments Processor` and `LSP Processor`, which were introduced in @chapter:design:lsp and are monitors.
To quickly disable the whole approach, the `enabled` field can be set to `False` to overwrite any previous value.

To enable logging, the `chat_history_log_file` field can be set to a file path. The logging behavior is introduced in the `Introspection` section.

During the initialization of the tokenizer and model, the `Generator` may add a custom padding token, if no padding token is present. Setting `force_custom_pad` to `True` can force the addition of the padding token.

The `predict_correct_completion_symbol` field toggles custom behavior for the completion item context injection. If enabled, the list of retrieved completions is presented to the model, to directly predict the correct completion item. Then the predicted completion item is directly inserted into the prompt, before resuming the generation.
#todo()[Maybe explain later]

The next toggle `masked_gen` controls if the logits of "other" token ids are masked during generation, when completion items or signature help is available.

The final three toggles `use_completion_context`, `use_deprecation_context` and `use_signature_context` control the behavior of the `LSP Processor`. If disabled, the respective context is not injected into the prompt, as the monitor will not cause the respective interrupts.
#todo()[Generation config supports max_interrupts]

=== Enabling the beam search strategy
As discussed in @chapter:design:ibms, the approach must support generation strategies like the beam search. This requires the following:
1. Storing the final beams before selecting the single returned sequences.
2. Storing the beam selections during generation to reproduce reorderings on objects tracking state for each beam.

The classes providing support are the `BeamTracker` and `BeamIndexStoringSearchScores`, found in `generation_utils/beam_tracking.py`.
The `BeamTracker` class only tracks beam selections. It contains a list of tuples, where each tuple contains an index for each beam.
It forms a $|"beams"| times s$ matrix $T$, where $s$ is the number of steps and is increasing during the generation loop.
$T_(j,i)$ denotes that during step $i$ the beam $j$ was selected from the $T_(j,i)$ beam at step $i-1$.

By receiving a list of objects storing state for each beam, the `BeamTracker` can replay the selection process for all steps, reordering the objects. As several beams may be selected from the same previous index, the objects may be duplicated.

#todo()[Show code?]

The second piece of the puzzle is the `BeamIndexStoringSearchScores` class. It is a subclass of the `Transformers` `BeamSearchScorer` class. The `BeamSearchScorer` classes are used internally for the beam search strategy to process a single generation step to choose the next beams and to finalize the selection at the end of the generation process.
By subclassing the `BeamSearchScorer` class, the `BeamIndexStoringSearchScores` class has access to the indices of selected beams at each step.
The instance contains an instance of the `BeamTracker` class, tracking the indices at each step.
Additionally the `BeamIndexStoringSearchScores` class is called with the final beams before the final selection of the singular best beam directly before the generation loop ends. These `input_ids` are stored internally for external access by the `Generator` class.
Concretely, the class overwrites the two methods `process` and `finalize`, adding the additional behavior for each step and for the final step, then passing all arguments into the method on the superclass:
#figure(
  code(
    lang: "Python",
    ```python
    class BeamIndexStoringSearchScores(BeamSearchScorer):
        def process(self, beam_indices, ...):
            self.beam_tracker.track_beam_indices(beam_indices)
            return super().process(...)

        def finalize(self, input_ids, beam_indices, ...):
            self.input_ids = input_ids
            self.beam_tracker.track_beam_indices(beam_indices)
            return super().finalize(...)
    ```,
  ),
  caption: [
    The `BeamIndexStoringSearchScores` class, which tracks the indices of selected beams at each step and stores the final beams before the final selection of the singular best beam.
  ],
)

A later section will detail how the `BeamIndexStoringSearchScores` replaces another instance of the `BeamSearchScorer`.

=== InterruptStoppingCriteria
The `InterruptStoppingCriteria` class is a utility class, which is used to determine if an interrupt occured inside a monitor and the generation loop should be stopped.
Coloquially, it propagates the interrupt signal to the interrupt loop.
It subclasses the `Transformers` `StoppingCriteria` class.
The class implements the method seen in @code:interrupt_stopping_criteria:
#todo()[Add interrupt loop and generation loop to design images]
#figure(
  code(
    lang: "Python",
    ```python
    class InterruptStoppingCriteria(StoppingCriteria):
        def __init__(self, interrupt_token_id):
            self.interrupt_token_id = interrupt_token_id

        def __call__(self, input_ids, scores, **kwargs):
            # Any batch ends with the interrupt token
            for i in range(input_ids.shape[0]):
                if len(input_ids[i]) > 0 and input_ids[i][-1] == self.interrupt_token_id:
                    return True
            return False
    ```,
  ),
  caption: [The `InterruptStoppingCriteria` class, which determines that the generation loop should be stopped when the interrupt token id occurs.],
)<code:interrupt_stopping_criteria>

=== Generator
The `Generator` component is implemented by the class `Generator` in `generator.py`. It is the main component of the approach and orchestrates the generation process.
The idea is to provide a high-level interface to the user, somewhere between the interace of the `generate` function of #acrpl("CLM") and the `pipeline` abstraction in the `Transformers` library.
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
#todo()[Maybe show code]
#todo()[Reference codellama tokenizer -> llama2 tokenizer -> llama1 tokenizer -> sentencepiece implementation: https://arxiv.org/pdf/2307.09288, https://arxiv.org/pdf/1808.06226]

The `Generator` performs two distinct types of explicit initialization: the general initialization and generation specific initialization.
The general initialization creates objects upfront, which can be reused between neural code completions, as they do not depend on the input code.
In contrast, the generation specific initialization is performed for each neural code completion and is dependent on the input code.
The generation specific initialization will be detailed in the later section detailing the interrupt loop.

The general initialization creates both a beam tracker (`BeamTracker` class) and an instance of a `PromptFormatter` class.
The `BeamTracker` is the solution to enable support for the beam search generation strategy, as introduced in @chapter:design:ibms in `Generation Strategy Support`. It will be further detailed later in conjunction with the tweaked generation loop.
The `PromptFormatter` is a class directly implementing the `Prompt Formatter` component. The initialization picks one of two classes: An instance of `VanillaPromptFormatter` is chosen if no context is to be injected into the model, while an instance of `DefaultPromptFormatter` is chosen for the normal proceding of the approach.
The toggle allows for a seamless switch between a baseline and the approach itself, through the passed configuration.

// General initialization

==== Tensor initialization.
Another form of implicit initialization is the control of the default device placement. The device placement regulates on which physical device `PyTorch` tensors are placed on initialization.
It is important that all tensors used during the approach are placed on the same device, else the generation fails.

To control the device placement, the `Generator` class implements a context manager, which changes the default device to the device the model was initialized on. The context manager is implemented through the method `device_placement` in the mixin `PipelineMixin`. It sets default device through the `torch.device` function and is inspired by the same behavior occuring in the high level abstraction `pipeline` in the `Transformers` library.
#todo()[Ref to https://docs.python.org/3/library/contextlib.html]

Before starting the neural code completion, the context manager is entered to ensure that all tensors are placed on the correct device. The context manager is exited after the neural code completion is finished:
#figure(
  code(
    lang: "Python",
    ```python
    async def completion(...):
        with self.device_placement():
            return await self._completion(...)
    ```,
  ),
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
  code(
    lang: "Python",
    ```python
    async def _complete(self, code: str, repo_root: str, file_name: str) -> str:
            self.log_code(code, "START")
            (...) = self.initialize_generation_state(code, repo_root, file_name)

            prompt = prompt_states[0].format(code)
            input_ids = self.tokenizer(
                prompt, return_tensors="pt", add_special_tokens=False
            ).input_ids
            input_ids, _ = self.expand_input_ids(input_ids, config)<code_completion_expansion>
            while True:<code_completion_loop_while_start>
                decoded_text = self.resume_generation(input_ids, ...)
                interrupt = lsp_processor.interrupt
                if interrupt is None:
                    prompt_state = prompt_states[0]
                    return self.retrieve_final_code(prompt_state, decoded_text)<code_completion_loop_while_end>
                stopped_beam_index = self.index_of_beam_to_edit(interrupt.input_ids)
                prompt_state = prompt_states[stopped_beam_index]
                if max_interrupts is not None:
                    if max_interrupts == 0:
                        return self.retrieve_final_code(prompt_state, decoded_text)
                    max_interrupts = max_interrupts - 1
                code_util = code_utils[stopped_beam_index]
                edited_prompt = self.edit_generation_text_for_completion(<code_completion_prompt_edit_start>
                    decoded_text, prompt_state, interrupt, code_util
                )
                input_ids = self.edit_input_ids(<code_completion_loop_edit_input_ids_start>
                    interrupt, edited_prompt, stopped_beam_index
                )<code_completion_loop_edit_input_ids_end>
                self.log_interruption(input_ids, interrupt_count)
    ```,
  ),
  caption: [The interrupt loop, which is the core of the `Generator` class and which enables the #acr("IBMS"). Long argument lists are abbreviated by "`...`"],
)<code:completion_loop>

The core of the loop consists of @code_completion_loop_while_start - @code_completion_loop_while_end and @code_completion_loop_edit_input_ids_start - @code_completion_loop_edit_input_ids_end.
The first lines call the `resume_generation` method, which wraps around the modified `Transformers` generation loop. Lines 12 to 15 check if an interrupt occured and return the result if the generation ended with an #acr("EOS").
Else line 26 edits the changed prompt into the current input token ids for the next call to `resume_generation`.

To further enable introspection, the initial code is logged and the input token ids are logged between interrupts. The logging behavior is detailed further in the introspection section.

At the start of the method, the generation specific objects are initialized, such as the different monitors, the prompt state, code utilities and other objects. While the monitors work on the input token ids as a whole, other objects work on singular beams and are initialized for every beam.
Thus, the `PromptState`, `PromptFormatter` and `CodeUtil` instances are created as a list for every single beam.

Additionally, the initial input token ids are obtained by creating the initial prompt from the provided code and then tokenizing the result.
Usually the prompt is tied to a beam and formatted using the `PromptFormatter` instance associated with a beam. At the start of the neural code completion all beams are the same, which is why the first `PromptState` instance is used.

Other parts of the method handle the augmented generation config. Initially, fields supported by the approach, but unsupported by `Transformers` are removed from the `config` dictionary. Then during each iteration, values such as the maximum allowed time (`max_time`) are updated to reflect the then correct values.
The supported maximum interruptions configuration value is tracked by the `maximum_interrupts` variable.

@code_completion_expansion is further explained in a later section. The same is true for details on editing and resumption.
#todo()[Later sections editing, resumption and custom generation]

==== Resumption.
// 1. Wraps around a generate method, generation loop
// 1. Properly passes arguments into the wrapped method
// 1. Handles result
Although resumption refers to the continuation of the generation process after an interrupt, there is no functional difference between the first generation and generations following an interrupt.
In each case, the interrupt loop calls the `resume_generation` method.
It is a wrapper over the tweaked generation loop, which is detailed in the next section.

Firstly, it resets objects used in the previous generation. Secondly, configuration values are set for the internal generation loop.
At last, it processes the result of the generation loop, to enable support for different strategies and to handle the special interrupt case.

In particular, the wrapper resets both the `LspProcessor` and the `BeamTracker` instances, both clearing any previous interrupts and resetting the tracked selected beams.

Depending on the passed `LspGenerationConfig`, the different monitors are appended to a list of used `LogitsProcessor` passed to the generation loop.
Additionally, an `InterruptStoppingCriteria` instance is created and added to the parameters of the internal wrapped `generate` method.

The `resume_generation` method passes the parameters `return_dict_in_generate=True` and `output_scores=True`, influencing the structure of the returned result of the wrapped generation loop.
The result is a dictionary-like object containing the returned final sequences over all batches, of which there will be a single one in most cases.
This returned sequence is then processed and returned by the `resume_generation` method. First, any type of custom padding is removed, then any interrupt token is removed if found. At last the sequence is decoded into a text containing only the prompt without other special tokens.

Further steps are necessary to support the beam search strategy. As will be discussed in the `LspProcessor` section, it stores the final `input_ids` of the generation at the time an interrupt is set. These `input_ids` can be used to inject the context and then to resume the generation.
If the beam search strategy is used, these `input_ids` could have been reordered after the interrupt token has been set. Thus the `input_ids` need to be overwritten with the correct `input_ids` after the beam search strategy has applied its own logic.
In that case the correct `input_ids` are obtained from the generation result, which contains the value in the field `beam_input_ids`. This is not the default behavior and was added in the patched generation loop and will be discussed in the next section.

Furthermore, the list of `PromptState` and `CodeUtil` are reordered to match the new beam selection, using the `BeamTracker`.

==== Tweaked Model Generation.
The internal generation loop is implemented in the `resume` method located in the `InterruptMixin` class. The `resume` method is a patched copy `generate` function of the `Transformers` `GenerationMixin`.
The following patches were applied:
1. No `input_id` expansion is applied.
2. Beam search strategy generation loop calls are tweaked to use the `BeamIndexStoringSearchScores` class and return the final beam search `input_ids`.

Usually the `generate` function receives `input_ids`, which are expanded to fit the number of beams required by the decoding strategy. At the end of the strategy these beams are then reduced to a single result. For an #acr("IBMS") to work, the method must receive all beams upfront and return all beams at the end.
Thus, the expansion of the `input_ids` is extracted into the additional method `expand_input_ids`. It will be called at the start of the *interrupt loop*, instead of the start of the generation loop.

Secondly, every beam search strategy must use an instance of `BeamIndexStoringSearchScores` as discussed before. Instances of `BeamSearchScorer` are replaced with `BeamIndexStoringSearchScores`, additionally forwarding the instance of the `BeamTracker` into the instance, enabling the tracking of the beam selection process.
After the generation loop has finished for a beam search strategy, the stored `input_ids` are extracted from the instance and set in the generation result in the `beam_input_ids` field.

==== Editing.
#todo()[Streamline `input_ids` and other variable names, etc]
This section details how the prompt and then `input_ids` are edited to inject the new context. The behavior is located in the `TokenSequenceEditMixin` class and is called in @code_completion_prompt_edit_start and @code_completion_loop_edit_input_ids_start.

The first method `edit_generation_text_for_completion` is called with the decoded text and the context to inject.
The decoded text is the prompt of the interrupted beam, as that interrupt token led to the selection of the beam as the result.
The context to inject was retrieved from the instance of the `LspProcessor`.
The method performs one of the following two steps:
1. Inject the context into the `PromptState`.
2. If the option `predict_correct_completion_symbol` is enabled and a completion is present: Determine the next symbol from the given completions and insert it directly into the prompt.

In any case, the methods starts by retrieving the generated code from the prompt, using the `PromptState` instance. And finally, the generated code is formatted into the edited prompt using a maybe changed `PromptState`.

// Case 1
In the first case, the interrupt is used to format the retrieved context into a textual representation, insertable into the prompt, called "comment". The exact steps are discussed in the later section `Interrupt Types`.
The comment is then added into the `PromptState` with the interrupt type.

// Case 2
The second case is an experimental method to try and find the correct completion from the list of completion items directly, without inserting the list of completions and implicitly letting the model complete the item.
The method `determine_next_symbol_from_completions` is called, which starts a separate normal model generation. The model is provided the following:
1. The current completed code.
2. The list of non deprecated completions.
3. A comment created from the deprecated completions.

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
The output is expected to be the completion item wrapped in backticks, as usual for raw markdown text. If the model did not return a result in the expected format, the empty string is returned. Else the predicted completion is returned. The predicted completion is then directly appended to the generated code.

==== Introspection
For any type of neural model generation, introspection into the generation flow is crucial. The result determined by the model can be often times unexpected and confusing.
For complex approaches further manipulating the generation flow, introspection is even more so important, as the complexity hinders the understanding of the generation flow.

To enable understanding on how additional context affects the generation flow, the `Generator` class implements a logging mechanism in the `LogMixin` class. The core idea is to log the generated token sequences to an append-only log between interrupts.
This enables the user to understand how previous interrupts led the model to the token sequences logged in following interrupts.
Additionally, reordering of beams can be observed.

At its core, the `LogMixin` provides two methods: `log_interruption` and `log_code`.
The method `log_code` is used to log initial and final code states of singular provided and returned code.
Between interrupts the second method `log_interruption` is used to list the contents of each beam. For readability, the token id sequences are converted back to tokens through the `tokenizer.batch_decode` method.

Generally, the methods have their structure displayed in @code:log_mixin:
#figure(
  code(
    lang: "Python",
    ```python
    def log(self, text: str):
        with open(self.config.chat_history_log_file, "a") as f:
            f.write(text)
    def log_interruption(self, input_ids, interrupt_index):
        if self.config.chat_history_log_file is None:
            return
        code_snippets = self.tokenizer.batch_decode(input_ids)
        # ... text formatting into variable `text` ...
        self.log(text)
    ```,
  ),
  caption: [The general structure employed for logging by the `LogMixin`.],
)<code:log_mixin>
The logging mechanism is optional and can be enabled as discussed in the configuration section.
If disabled, the methods are no-ops.

=== Monitors
After discussing the complicated details of the interruption loop and prompt editing, this section provides details on the different monitors `LSP Processor`, `Boundary Processor` and `Comments Processor`.
These classes receive and use state objects created in the `Generator` class. The following sections will only list further created objects and and the state objects will not be listed explicitly.

==== LSP Processor Overview.
All processors implement the `LogitsProcessor` interface of the `Transformers` library through the `__call__` method. They receive the `input_ids` for each beam and the current scores of the next predicted token id.
The implementation of the `__call__` method is found in @code:lsp_processor:
#figure(
  code(
    lang: "Python",
    ```py
    def __call__(self, input_ids: LongTensor, scores: FloatTensor) -> FloatTensor:
        """Returns a 2d FloatTensor which has scores for every batch"""
        if not self.config.lsp_processor or not self.config.enabled:
            return scores
        for i in range(input_ids.shape[0]):
            try:
                scores[i] = self.scores_for_batch(i, input_ids[i], scores[i])
            except InterruptGeneration as ig:
                scores[i][self.interrupt_token_id] = INTERRUPT_LOGITS_SCORE
                self.interrupt = Interrupt(
                    input_ids=input_ids,
                    interrupt_context=ig.context,
                    interrupt_type_name=ig.interrupt_type_name,
                )
                return scores
        return scores
    ```,
  ),
  caption: [The `__call__` method of the `LSPProcessor` class.],
)<code:lsp_processor>

#todo[Maybe some algorithmic library]
The general flow is as follows:
1. If the `LSP Processor` is disabled through the configuration, the unchanged scores are returned.
2. Each beam is processed individually, after which the updated scores are returned.
3. For the current completed code in each beam, the following occurs:
  1. Static analysis is performed on the code.
  2. Heavy filtering is applied to the retrieved completions and signature help.
  3. An interrupt may be triggered, if context is available, throwing an `InterruptGeneration` exception.
  4. The scores are reranked using the available context, if no interrupt is triggered.
4. If an interrupt is triggered, the interrupt token id will be forced and the context saved in an interrupt object.

To perform these actions, in special the static analysis, filtering and reranking, the monitor requires a few additional attributes.

// Signature cache, current interrupt and objects for each beam, filename, expand size
The first additional attribute is the `signature_cache`, which overlays the plentiful information from the completion items with the signature help to enable complex filtering on the signature help items. By default this is initialized to an empty dictionary, which grows during the generation.

The second attribute is the `interrupt`, which is set to `None` at the start of the generation. If an interrupt is triggered, the interrupt object is set in the interrupt attribute. The method `resume` sets this object to `None`, effectively clearing the interrupt information.
#todo[Cross-reference resume to perivous mention in generate?]

The third attribute `file_names` contains a file name per code to complete. This name serves is used to create a temporary file containing the partial code for static analysis. It is a direct result of the `file_name` argument of the `_complete` method in the `Generator` and is relevant if code in a project file is to be completed.

Lastly, the `expand_size` attribute is used to determine the link between the number of total beams, beams per batch and batch count. Usually the different functions use flat lists which contain entries for all batch entries. To determine the batch index from an index of such a flat list, the `expand_size` contains the number of beams per batch.

==== LSP Processor Context Retrieval.
This section and the following section on the `LSP Processor` will provide details on the behavior of the `scores_for_batch` method, which contains the retrieval, filtering, interrupt triggering and reranking of scores.

The method starts with the following logic seen in @code:scores_for_batch_start:
#figure(
  code(
    lang: "Python",
    ```py
    def scores_for_batch(
        self, i, input_ids: LongTensor, scores: FloatTensor
    ) -> FloatTensor:
        """Returns a 1d FloatTensor for a single batch"""
        current_code = self.current_code(i, input_ids)
        file_name = self.file_name(i)
        with LspCodeFile(
            file_name, current_code, self.lsp_clients[i // self.expand_size]
        ) as lsp_code_file:
            if self.should_complete(current_code):
                completions = lsp_code_file.ask_completions()
                completions = lsp_code_file.resolve_completions(completions)
            else:
                completions = []
            trigger_phrase = re.search(r"[A-Za-z_]*$", current_code).group(0)
            signature_help = lsp_code_file.ask_signature()
            self.increase_signature_cache(signature_help, completions)
    ```,
  ),
  caption: [Start of the `scores_for_batch` method, listing how the context retrieved from a language server.],
)<code:scores_for_batch_start>

The method starts by determining the partially completed code of the current beam using the `current_code` method. The `current_code` method reuses the `PromptState` abstraction to do so. The only new difficulty lies in finding the correct `PromptState` instance, as the `LSPProcessor` stores an instance per beam and the ordering of the stored instances and the passed `input_ids` could be different due to beam search reordering. Generally, the class uses the `BeamTracker` to determine the reordered indices, then retrieve the correct object of the current beam and then use the object to perform the action.

Similarily, the file name of the current batch is retrieved using the `file_name` method.
#todo[`file_name` to `get_file_name_for_batch` method]

Lastly, the abstraction `LspCodeFile` is used to interact with the language server. The `LspCodeFile` abstraction is detailed in the `Language Server` section.
The returned `lsp_code_file` object is used to firstly retrieve the completion items and then the signature help items.
As detailed in @chapter:bg:lsp, retrieving the completions is a two-step process, as the completions must be resolved to include detailed information needed for filtering.

To prevent the use of completion items, if the completion is not needed, the method `should_complete` is called. If the current code ends in one of the following symbols, the completions are not needed: ")", "\\n", " ", "\\t", "]", "}". This effectively limits the use of completion items to the following scenarios:
- Completion of a symbol.
- Start of the dereference operator.
, and reduces model confusion after completing a single function call and reduces completion of unneeded symbols everywhere.
// TODO: reformulate?

To prepare for the filtering, a `trigger_phrase` is determined. The trigger phrase is used to determine if a completion item is already partially completed, the current code ends in a prefix of a completion item. This trigger phrase is obtained by finding any symbol the code ends with through the regular expression `[A-Za-z_]*$`.

#todo[Could be better, find all completion items that are builtin and extract keyword from there]
Lastly, the signature cache is increased using the retrieved completion items and signature help items. The method `increase_signature_cache` matches completion items to signature help items through the to be inserted text of the completion items and the keyword of the signature item. If a match occurs, the completion item is assigned to the keyword in the `builtin_cache` attribute.

==== LSP Processor Filtering.
First the signature help items are filtered, after which the completion items are filtered.
Each filtering is performed through a chain of methods, each taking at least a list of items and returning the filtered list.

From the signature help items, the following filters are applied:
1. Remove signature help items of builtin functions.
2. Remove items without parameters.

The method should improve completion of functions with changed parameters and complex signatures. As such the second filter ignores the case in which a function does not have parameters. The first filter reduces the model confusion by completing probably known functions unchanged.
To obtain the information if a signature help item is a builtin function, the signature cache is used, as the information is stored in the completion items. If a matching completion items is a builtin item, the signature help item is skipped.

#todo[Remove kind, as kind and postfix are merged]
From the completion items, the following filters are applied:
1. Remove builtin completion items.
2. Constrain completion items to relevant #link(label("code:completion_item_kind"), "Kinds").
3. Remove items from the current partial completion.
4. Constrain to public items (no private methods).
5. Remove items which are already fully completed.

The steps are as described in @chapter:design:lsp. Most filtering steps are straightforward, as they only require fields directly present in the completion items, or simple string matching.
The following minor details are required:
- Builtins are recognized by matching the value `"builtins"` in the `detail` field..
- Private methods are recognized through the name starting with an underscore.

==== LSP Processor Interrupt Triggering.

==== LSP Processor Reranking.

=== PromptState

=== PromptEditor
// fixing prompt back and forth
- "only for beam search"

=== Interrupt Types

=== Language Server
// 1. Initialization
// 2. Communication
// -> file abstraction
==== Sync vs Async
