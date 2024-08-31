#import "/utils.typ": *

== Transformers Library <chapter:bg:transformers>
Transformers is the name of the popular Python machine learning library developed by HuggingFace. It provides broad support for many different machine learning domains, such as computer vision, audio processing, multimodal models and *natural language processing*@Transformers.
For each domain, the library enables simple training and inference of state-of-the-art models.
The thesis heavily relies on functionality provided by this library, as it provides in-depth features to implement the more advanced features. It provides support for all techniques introduced in @chapter:bg:llms and @chapter:bg:text_generation@Transformers.
The library itself is built on top of PyTorch, for which further information may be found in the appendix.

As the library receives frequent updates, the thesis focuses on version #link("https://huggingface.co/docs/transformers/v4.41.3/en/index")[`4.41.3`]. In addition, the library is complex and enables many different use-cases through many abstraction layers. This section will focus on the #acr("CLM") use-case, omit unneeded arguments and list parameters only available for #acr("CLM").

The structure of this section will mirror the structure of previous sections. It will start by introducing #acrpl("CLM"), then continue with tokenizers. Afterwards, the text generation functions are presented.

Using different text generation strategies with the Transformers library will follow. At last, implementing controllable generation will be shown.

=== Models
In transformers, every type of model architecture is represented by a model class. Each model defines the layers of the model and the operations between layers. Common model functionality is inherited through the base class `PreTrainedModel`@Models.

Pretrained models provide the following functionality (not exhaustive)@Models:
- Loading pre-trained weights
- Resizing the token embeddings

Loading a pre-trained model for inference is done by calling the `from_pretrained` method on the model class:
#figure(
  code(
    lang: "Python",
    ```python
    from_pretrained(
        pretrained_model_name_or_path,
        torch_dtype: str | torch.dtype = None,
        device_map: str | Dict[str, Union[int, str, torch.device]] = None,
        **kwargs
    ) -> PreTrainedModel
    ```,
  ),
  caption: [Loading a pre-trained model@AutoClasses],
)<code:model_from_pretrained>

Calling @code:model_from_pretrained returns a model instance with pre-trained weights, loaded onto one or several physical devices. The model is either loaded from a local directory, or from the HuggingFace model hub. Where the model is loaded from depends on the type of the `pretrained_model_name_or_path` parameter.

The HuggingFace model hub allows for easy access of pre-trained models, given the name of the model and the name of the publisher. The model name has the format `publisher_name/model_name`.
Some#footnote()[
    More code generation models can be found in the #link("https://huggingface.co/spaces/bigcode/bigcode-models-leaderboard")[Bigcode models leaderboard]
]
of the many available #acr("CLM") for code generation are:
- `codellama/CodeLlama-7b-Instruct-hf`
- `deepseek-ai/deepseek-coder-6.7b-instruct`
- `m-a-p/OpenCodeInterpreter-DS-6.7B`
- `ise-uiuc/Magicoder-S-DS-6.7B` // MagiCoder is not in the leaderboard

In the case that a model name from the HuggingFace hub is provided, the model is downloaded and cached locally. If the model is already present, it is loaded from cache.
By default, the model will be loaded using the data type of the loaded weights. The `torch_dtype` parameters allows loading the weights in e.g. lower precision, to save memory during inference.

The `device_map` parameter controls on which devices the model is allocated. The parameter takes a PyTorch device as value. Passing `auto` computes the most optimized device map automatically.

// Auto models
Transformers provides an abstraction called `AutoClasses`. These abstractions solve the problem of finding the specific model, config and tokenizer classes to load and use a #acr("CLM"). Instead, the correct classes can be guessed from the name of a model alone@AutoClasses.
This simplifies code when trying different models for the same task, such as code generation:
#figure(
  code(
    lang: "Python",
    ```python
    from transformers import AutoModel, LlamaForCausalLM
    # The following line
    model = LlamaForCausalLM.from_pretrained("codellama/CodeLlama-7b-Instruct-hf")
    # Would be transformed into
    model = AutoModel.from_pretrained("codellama/CodeLlama-7b-Instruct-hf")
    ```,
  ),
  caption: [Using `AutoClasses` to load a model@AutoClasses],
)<code:auto_classes>

// Resizing token embeddings
The method `resize_token_embeddings` resizes the token embeddings of the model to a new size. The function is commonly used to account for new special tokens added to the tokenizer at runtime@Models.

=== Tokenizers
Tokenizers provide the functionality to convert text to and from sequences of token ids. In addition, they store the vocabulary, including information on special tokens, such as the #acr("EOS") token@Tokenizer.

Loading a tokenizer is done through the `AutoClasses` abstraction, which will return an instance of a subclass of a `PreTrainedTokenizer`:
#figure(
  code(
    lang: "Python",
    ```python
    from transformers import AutoTokenizer
    tokenizer = AutoTokenizer.from_pretrained("codellama/CodeLlama-7b-Instruct-hf")
    ```,
  ),
  caption: [Loading a tokenizer@AutoClasses],
)<code:auto_tokenizer>

// containde knowledge
The vocabulary can be accessed through the `get_vocab` method, which returns a dictionary mapping tokens to token ids@Tokenizer.
Special tokens and token ids can be accessed directly through special attributes of the tokenizer:
#figure(
  table(
    columns: 3,
    align: left,
    table.header([Token attribute], [Token ID attribute], [Description]),
    // only bos, eos, pad
    [bos_token], [bos_token_id], [Beginning of sequence token and token id],
    [eos_token], [eos_token_id], [End of sequence token and token id],
    [pad_token], [pad_token_id], [Padding token and token id],
  ),
  caption: [Special tokens and token id attributes@Tokenizer],
)<code:special_tokens>

// Adding knowledge
Special tokens can be added at runtime by calling `add_special_tokens` with a dictionary containing the key `additional_special_tokens` with the list of new tokens@Tokenizer.

// Tokenization
The main functionality of a tokenizer is to convert text to token ids. This is done by calling the tokenizer directly, as it implements the special `__call__` function@Tokenizer:
#figure(
  code(
    lang: "Python",
    ```python
    __call__(
        text: Union[str, List[str]],
        add_special_tokens: bool = True,
        return_tensors: str = None,
        // ... omitted parameters
    ) -> BatchEncoding
    ```,
  ),
  caption: "Tokenizing text",
)<code:tokenization>

The function in @code:tokenization either tokenizes a single string, or a batch of strings. The output `BatchEncoding` has the field `input_ids`, which contains the sequence of token ids, or batch of token ids.

The output format of `input_ids` is controlled by the parameter `return_tensors`. By setting it to `pt`, the `input_ids` will be a PyTorch tensor.

By default, the tokenizer adds special tokens to the input text, such as the #acr("BOS") and #acr("EOS") tokens. This behavior can be controlled by the `add_special_tokens` parameter.

// Detokenization
In contrast to tokenization, the `PretrainedTokenizer` class provides two different methods for detokenization. Both functions are similar in signature with the single difference that one method takes a single sequence of token ids, and the other method a batch of sequences@Tokenizer.

The method `decode` decodes a single sequence and has the following signature:
#figure(
  code(
    lang: "Python",
    ```python
    decode(
        token_ids: Union[torch.Tensor, List[int]],
        skip_special_tokens: bool = False,
        // ... omitted parameters
    ) -> str
    ```,
  ),
  caption: [Detokenizing a single sequence@Tokenizer],
)<code:detokenization_single>

The method `batch_decode` has a similar signature, but decodes a whole batch of sequences.
The parameter `skip_special_tokens` can be enabled to remove special tokens, which might be unwanted when e.g. displaying the returned text@Tokenizer.

// convert_tokens_to_ids
If single tokens are already present, these can be convert to token ids by calling the method `convert_tokens_to_ids`. The converse direction is possible by calling the method `convert_ids_to_tokens`. The method `convert_ids_to_tokens` also takes the parameter `skip_special_tokens`@Tokenizer.

=== Config
Models show dynamic behavior, as they can be configured at runtime. This dynamic configuration enables the use of different generation strategies, by setting different model configuration values. Model configurations are classes inheriting from `PretrainedConfig`. The `PretrainedConfig` includes configuration values for the model architecture and for the mentioned dynamic behavior@Configuration.
Instantiation a `PretrainedConfig` is possible through the abstraction `AutoClasses`, by using `AutoConfig`@AutoClasses.

Often single configuration values can be passed into the model as single keyword arguments, without the need for a dedicated configuration object@Generationa.
Different configuration values will be introduced as function arguments in the following sections.

=== Text Generation
After obtaining a model and a tokenizer, the text generation process can be performed by using one of the following three abstraction. The to be introduced abstraction build upon the previous abstraction.

// forward
The lowest level abstraction is the `forward` method of the model, which takes previous token ids and returns the logits for the next token id. The arguments to the function only control the provided output format and cache behavior@Models.

// generate
The next abstraction is the `generate` method, which generates a whole sequence of tokens until a stopping criteria is met, such as the #acr("EOS") token.
The functions is provided by the `GenerationMixin` class, which #acr("CLM") inherit from using multiple-inheritance.
The `GenerationMixin` implements the different text generation strategies, which can be controlled through the provided parameters@Generationa.
The `generate` function has the following signature:
#figure(
  code(
    lang: "Python",
    ```python
    generate(
        inputs: torch.Tensor,
        generation_config: GenerationConfig = None,
        logits_processor: LogitsProcessorList = None,
        stopping_criteria: StoppingCriteriaList = None,
        **kwargs
        // ... omitted parameters
    ) -> Union[ModelOutput, torch.LongTensor]
    ```,
  ),
  caption: [Generating a sequence of tokens@Generationa],
)<code:generate>
Next to the provided input tensor `inputs`, the `generation_config` parameter contains configuration values to control the generation. Extra matching keyword arguments override keys in the generation config. @table:generation_config contains important configuration parameters:

#figure(
  table(
    columns: 4,
    align: left,
    table.header([Category], [Parameter], [Type], [Description]),
    // table.cell(colspan: 3, raw("// Stopping criteria")),
    [Stopping Criteria], [max_length],
    [int],
    [Maximum length of the generated sequence],
    [], [max_new_tokens],
    [int],
    [Maximum number of new tokens to generate. Overrides `max_length`],
    [], [max_time],
    [float],
    [Maximum time in seconds to generate],
    [Generation Strategy], [do_sample], [bool], [Whether to sample from the logits],
    [], [num_beams], [int], [Number of beams for beam search],
    [Logits manipulation], [temperature], [float], [Temperature for sampling],
    [], [top_k], [int], [Number of tokens to sample from],
    [], [top_p], [float], [Cumulative probability for sampling from],
    [], [repetition_penalty], [float], [Penalizes repeated tokens],
    // [Output format], [], [bool], [Whether to return the full text],
    // TODO: continue
  ),
  caption: [Generation configuration parameters@Generationa],
)<table:generation_config>

// TODO: add references to previous chapters for logits manipulation, controllable generation, etc
// stopping criteria
The first parameters in @table:generation_config configure the first stopping criteria. The generation can be stopped when the sequence reaches a certain length, or when a certain time is reached.

The following diagram displays the different used generation strategies, depending on the provided parameters:
#figure(
  cetz.canvas(
    length: 2.3cm,
    {
      import cetz.draw: *
      rect((1, -1), (3, -3), radius: .2, stroke: rgb("#222222"), name: "box")
      content((name: "box", anchor: 115deg), move(dy: -8pt, "sampling"))
      content((name: "box", anchor: 65deg), move(dy: -8pt, "no sampling"))
      content((name: "box", anchor: 155deg), move(dx: -16pt, [> 1\ beam]))
      content((name: "box", anchor: 205deg), move(dx: -16pt, [\= 1\ beam]))
      content((1.5, -1.5), [beam-search\ multinomial\ sampling])
      content((2.5, -1.5), [beam-search\ decoding])
      content((1.5, -2.5), [multinomial\ sampling])
      content((2.5, -2.5), [greedy\ decoding])
      line((1, -2), (3, -2))
      line((2, -1), (2, -3))
    },
  ),
  caption: "Generation strategies",
)
// Logits manipulation
The final parameters manipulate the logits before sampling. They enable `Top-k`, `Top-p` and `Temperature` sampling. The last parameter hinders models from endlessly repeating the same token, until a stopping criterium is reached.

// pipeline
// TODO: maybe pipeline if needed

=== Controllable Generation
The `generation` method provides parameters to overview and control the generation process. These parameters enable strategies as discussed in @chapter:bg:controllable_generation.

// stopping criteria
The first control mechanism are the stopping criteria. The stopping criteria define custom conditions that terminate the generation, when one of the conditions is met.

Transformers defines a few vital stopping criteria, like the maximum time or the maximum number of tokens to generate. These stopping criteria are enabled by passing certain keyword arguments into the `generate` method, as introduced in the section before@UtilitiesGeneration@Generationa.

Custom stopping criteria are defined by subclassing the `StoppingCriteria` class and adding an instance of the new class to the `stopping_criteria` list in the `generate` method@UtilitiesGeneration.

A subclass of `StoppingCriteria` only needs to implement the `__call__` method:
#figure(
  code(
    lang: "Python",
    ```python
    __call__(
        input_ids: torch.LongTensor,
        scores: torch.FloatTensor,
        **kwargs
    ) -> bool
    ```,
  ),
  caption: [Stopping criteria signature@UtilitiesGeneration],
)<code:stopping_criteria>
The method in @code:stopping_criteria returns whether the generation should be stopped, based on the previous token ids `input_ids` and the current `scores`. The method must support batching, as `input_ids` has the shape `(batch_size, sequence_length)` and `scores` the shape `(batch_size, vocab_size)`@UtilitiesGeneration.

// logits processor
The second control mechanism are the logits processors. Logits processors manipulate the current logits before a decoding strategy chooses the next token id on the then manipulated logits.

Custom logits processors are defined by subclassing the `LogitsProcessor` class and adding an instance of the new class to the `logits_processor` list in the `generate` method.
A subclass of `LogitsProcessor` only needs to implement the `__call__` method:
#figure(
  code(
    lang: "Python",
    ```python
    __call__(
        input_ids: torch.LongTensor,
        scores: torch.FloatTensor,
        **kwargs
    ) -> torch.FloatTensor
    ```,
  ),
  caption: [Logits processor signature@UtilitiesGeneration],
)<code:logits_processor>
The arguments in @code:logits_processor are identical to the arguments in @code:stopping_criteria. The method must return the manipulated logits, which have the same shape as the input `scores`.

// todo: logitswarper?
