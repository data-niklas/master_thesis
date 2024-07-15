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

And lastly the `masked_gen` toggle controls if the logits of "other" token ids are masked during generation, when completion items or signature help is available.

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
            input_ids, _ = self.expand_input_ids(input_ids, config)
            while True:
                decoded_text = self.resume_generation(...)
                interrupt = lsp_processor.interrupt
                if interrupt is None:
                    prompt_state = prompt_states[0]
                    return self.retrieve_final_code(prompt_state)
                stopped_beam_index = self.index_of_beam_to_edit(interrupt.input_ids)
                prompt_state = prompt_states[stopped_beam_index]
                if max_interrupts is not None:
                    if max_interrupts == 0:
                        return self.retrieve_final_code(prompt_state)
                    max_interrupts = max_interrupts - 1
                code_util = code_utils[stopped_beam_index]
                edited_prompt = self.edit_generation_text_for_completion(
                    decoded_text, prompt_state, interrupt, code_util
                )
                input_ids = self.edit_input_ids(
                    interrupt, edited_prompt, stopped_beam_index
                )
                self.log_interruption(input_ids, interrupt_count)
    ```,
  ),
  caption: [The interrupt loop, which is the core of the `Generator` class and which enables the #acr("IBMS"). Long argument lists are abbreviated by `...`],
)<code:completion_loop>

1. init objects for generation for each beam (monitor is stateless so only 1 instance)
2. create lsp for each language
3. init config and add fixes
4. expand input ids (normally in generate function)
5. loop and use custom generation
  - if no interrupt -> get completion, done
  - else
    - edit prompt
    - insert into beams and edit input ids => add padding to max length of all to left side, then remove as much padding as possible on left (1. equalizes padding, 2. minimizes it)
    - clear interrupt
    - adjust config parameters

==== Resumption.
- same arguments as generate

- reordering of static analysis requires deepcopy, as several objects have the same ancestor, thus branching off (copies)

=== BeamTracker
- Custom BeamSearchScores to enable beam search + logits processor order tracking and beam retrieval:
- saves input_ids before returning from the generate function (finalizing the beams)
- calls the tracker at each step

- BeamTracker
- List of beam selections
- iterates through the list, reproducing the beam selection process and storing the original ancestor beam index
- provides to rearrange list of items in the order of the beam search

- "only for beam search"

==== Introspection
For any type of neural model generation, introspection into the generation flow is crucial. The result determined by the model can be often times unexpected and confusing.
For complex approaches further manipulating the generation flow, introspection is even more so important, as the complexity hinders the understanding of the generation flow.

To enable understanding on how additional context affects the generation flow, the `Generator` class implements a logging mechanism in the `LogMixin` class. The core idea is to log the generated token sequences to an append-only log between interrupts.
This enables the user to understand how previous interrupts led the model to the token sequences logged in following interrupts.
Additionally, reordering of beams can be observed.

At its core, the `LogMixin` provides two methods: `log_interruption` and `log_code`.
The method `log_code` is used to log initial and final code states of singular provided and returned code.
Between interrupts the second method `log_interruption` is used to list the contents of each beam. For readability, the token id sequences are converted back to tokens through the `tokenizer.batch_decode` method.

Generally, the methods have the structure displayed in @code:log_mixin:
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

=== Monitor
logits guider
- self.interrupt = Interrupt object
-

=== PromptEditor
// fixing prompt back and forth

