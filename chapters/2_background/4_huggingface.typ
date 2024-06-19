#import "/utils.typ": *

== Torch <bg_torch>
Torch is a widely used machine learning library in Python. It enables the creation and manipulation of tensors in different precisions. The Transformers provides high level abstractions which base on Pytorch. // TODO as an example, other models are also possible
This section shortly introduces a few core concepts of Pytorch, which are used in the Transformers library. It will focus on version #link("https://pytorch.org/docs/2.2/")[`2.2`] of PyTorch.

// What is a tensor

// Precision

// Device

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
