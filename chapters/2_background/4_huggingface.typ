#import "/utils.typ": *

== Torch <bg_torch>
// TODO: @rabanserIntroductionTensorDecompositions2017
Torch is a widely used machine learning library in Python. It enables the creation and manipulation of tensors in different precisions. The Transformers provides high level abstractions which base on Pytorch. // TODO as an example, other models are also possible
This section shortly introduces a few core concepts of Pytorch, which are used in the Transformers library. It will focus on version #link("https://pytorch.org/docs/2.2/")[`2.2`] of PyTorch.

// TODO: übergang
// TODO: introduce motivation
// What is a tensor
PyTorch provides operations on tensors. A tensor is a multi-dimensional array of numerical values and the generalization of a matrix@rabanserIntroductionTensorDecompositions2017.
// n-d array of numerical values => generalization of matrices
Each tensor typically only contains values of the same type, such as value from $RR$@rabanserIntroductionTensorDecompositions2017.

// multi-relational data:
One of the applications for tensors is to represent multi-relational data@rabanserIntroductionTensorDecompositions2017. In that case each dimension represents a single relation.

// example: first dimension: generated tokens, second dimension: batch
For #acr("CLM") inference different types of tensors are used. For example, the token sequence during parallel text generation is a two-dimensional tensors of the following relations: `(batch, token)`.
The second dimension represents a single token sequence, while the first dimension enables parallel text generation for `n` token sequences.

// TODO: reference
// other example: first dimension: batch, second dimension: prediction in shape of vocabulary
Another example is the next token prediction tensor, which is a two-dimensional tensor of the following relations: `(batch, vocabulary)`. The second dimension contains the probability distribution over the whole vocabulary, while the first dimension enables parallel text generation.

The second example only displays the tensor for a single next token prediction. By adding another dimension for the `token` relation, the whole probability distribution history could be represented.
// TODO: introduce batching

After providing the motivation for tensors, the following list will introduce core terminology for use with tensors:
/ Order: Number of dimensions of a tensor
/ Shape: Number of elements in each dimension
/ Slice: Two-dimensional subfield of a tensor. Obtained by fixing all but two indices.
/ Fiber: One-dimensional subarray of a tensor. Obtained by fixing all but one index.
/ Matrix: Two-dimensional tensor.
/ Vector: One-dimensional tensor.
/ Scalar: Zero-dimensional tensor.
@rabanserIntroductionTensorDecompositions2017

Fixing indices on a tensor will return a subfield or subarray, which in itself is a lower-order tensor. By fixing all indices a scalar is obtained. A slice and fiber are special terms for lower-order tensors obtained from fixing indices on a tensor.

// Precision
As introduced earlies, tensors usually contain values of the same type. Each PyTorch tensor contains values of a single data type, in short: `dtype`.
PyTorch supports many different numerical data types, of which the following are relevant:
#figure(
  table(
    columns: (auto, auto),
    table.header([Data Type], [dtype]),
    [32-bit floating point],
    [torch.float32],
    [16-bit floating point 1],
    [torch.float16],
    [16-bit floating point 2],
    [torch.bfloat16],
    [64-bit integer (signed)],
    [torch.int64],
    [32-bit integer (signed)],
    [torch.int32],
    [Boolean],
    [torch.bool],
  ),
  caption: "Relevant PyTorch data types",
)<table_data_types>

The data types can be used by specifying the `dtype` parameter when creating a tensor. The value is one of the variables listed in the `dtype` column in @table_data_types.

// float16 vs bfloat16
The difference between `torch.float16` and `torch.bfloat16` is the precision of the floating point number. Both formats use 16 bits to encode the floating point number. The difference lies in the number of bits used to encode the mantissa.

The `torch.float16` is a half-precision floating point number, as defined in the IEEE 754 standard. It uses one sign bit, five exponent bits and 10 mantissa bits@IEEEStandardsAssociation.
// TODO: better IEEE reference
#figure(
  image("/assets/float16.svg"),
  caption: "IEEE 754 half-precision floating point number: float16",
)

In contast, the `torch.bfloat16` keeps the full range of the full-precision floating point number of 8-bits, but has a reduced precision of 7 mantissa bits@BFloat16SecretHigh.
#figure(
  image("/assets/bfloat16.svg"),
  caption: "Brain Floating Point Format: bfloat16",
)
The format was introduced by Google Brain and is used in their Tensor Processing Units (TPUs)@BFloat16SecretHigh, as the reduced mantissa precision reduces the size needed for physical hardware multipliers@BFloat16SecretHigh.

// Device
// torch.device
// torch.to

// TEnsor, LongTensor, FloatTensor
// torch.Tensor
// .shape
// indexing
// iterating like normal python (over first dimension)

// functions
// torch.nn.functional

== Transformers Library <bg_transformers>
Transformers is the name of the popular Python machine learning library developed by HuggingFace. It provides broad support for many different machine learning domains, such as computer vision, audio processing, multimodal models and *natural language processing*.
For each domain, the library enables simple training and inference of state-of-the-art models.
The thesis heavily relies on functionality provided by this library, as it provides in-depth features to implement the more advanced features. It provides support for all techniques introduced in @bg_llms and @bg_text_generation.

As the library receives frequent updates, the thesis focuses on version #link("https://huggingface.co/docs/transformers/v4.41.3/en/index")[`4.41.3`]. In addition, the library is complex and enables many different use-cases through many abstraction layers. This section will focus on the #acr("CLM") use-case, omit unneeded arguments and list parameters only available for #acr("CLM").

The structure of this section will mirror the structure of previous sections. It will start by introducing #acrpl("CLM"), then continue with tokenizers. Afterwards, the text generation functions are presented.

Using different text generation strategies with the Transformers library will follow. At last, implementing controllable generation will be shown.

=== Models
In transformers, every type of model architecture is represented by a model class. Each model defines the layers of the model and the operations between layers. Common model functionality is inherited through the base class `PreTrainedModel`.

Pretrained models provide the following functionality (not exhaustive):
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
  caption: "Loading a pre-trained model",
)<code_model_from_pretrained>

Calling @code_model_from_pretrained returns a model instance with pre-trained weights, loaded onto one or several physical devices. The model is either loaded from a local directory, or from the HuggingFace model hub. Where the model is loaded from depends on the type of the `pretrained_model_name_or_path` parameter.

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
By default, the model will be loaded using

// Auto models

=== Config
Models show dynamic behavior, as they can be configured at runtime. This dynamic configuration enables the use of different generation strategies, by setting different model configuration values. Model configurations are classes inheriting from `PretrainedConfig`. The `PretrainedConfig` includes configuration values for the model architecture and for the mentioned dynamic behavior.

=== Tokenizers

=== Text Generation

=== Controllable Generation
