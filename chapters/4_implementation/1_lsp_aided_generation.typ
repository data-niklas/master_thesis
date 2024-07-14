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
  figure(
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
  ),
)

The main component `Generator` is implemented in `generator.py`. Different feature sets of the generator, such as logging, editing token sequences and padding the edited sequences are extracted into the directory `mixins`.
The different `Monitors` `LSP Processor`, `Boundary Processor` and `Comments Processor` are contained in the directory `lsp`, as well as further utilities needed to interact with a language server.
The component `Prompt State` is implemented in `prompt_state.py`, while the `Prompt Formatter` is implemented in the `prompt_formatters` submodule.
Lastly, the submodule `interrupts` contains the behavior for the different types of interrupts.

The other files and submodules contain various types of utilities, fixes and configurations needed to enable the approach and make it configurable for evaluation. The next sections will focus on the components introduced in @chapter:design:lsp and then continue on with important details on the various other files and submodules.

=== Generator
The `Generator` component is implemented by the class `Generator` in `generator.py`. It is the main component of the approach and orchestrates the generation process.
The idea is to provide a high-level interface to the user, somewhere between the interace of the `generate` function of #acrpl("CLM") and the `pipeline` abstraction in the `Transformers` library.
The interface shall provide the same interface as the `generate` function, while reducing a few pitfalls through the features of the `pipeline` abstraction, and the added configuration options for the approach.

The following sections include notes on the different features provided by the `Generator`.

==== Initialization
The
// General initialization

// Tensor initialization

// implemented using a class, wrap

// connection to LSP, but will be detailed in the next section

// add special tokens and resize embeddings
// add pad token, as not every model has padding

// contextmanager for device placement
// from huggingface pipeline, but needed

==== Completion
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

==== Resumption
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

=== Monitor
logits guider
- self.interrupt = Interrupt object
-

=== PromptEditor
// fixing prompt back and forth

=== Introspection

=== Configuration
