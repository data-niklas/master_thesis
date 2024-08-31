#import "/utils.typ": *
#let masking = load-evaluations("2024-08-27-masking")
#let default = load-evaluations("2024-08-26-default")
#let use-completions = load-evaluations("2024-08-28-use-completions")
#let raw-copilot = load-evaluation("2024-08-23", "copilot")
#let all-stats = get-all-stats((
  ("Default", default),
  ("Masking", masking),
  ("Use Completions", use-completions),
))
= Appendix
#show figure: set block(breakable: true)

== Torch <chapter:bg:torch>
// TODO: @rabanserIntroductionTensorDecompositions2017
Torch is a widely used machine learning library in Python. It enables the creation and manipulation of tensors in different precisions. The Transformers provides high level abstractions which base on PyTorch. // TODO as an example, other models are also possible
This section shortly introduces a few core concepts of PyTorch, which are used in the Transformers library. It will focus on version #link("https://pytorch.org/docs/2.2/")[`2.2`] of PyTorch.
// TODO: übergang
// TODO: introduce motivation
// What is a tensor
PyTorch provides operations on tensors. A tensor is a multidimensional array of numerical values and the generalization of a matrix@rabanserIntroductionTensorDecompositions2017.
// n-d array of numerical values => generalization of matrices
Each tensor typically only contains values of the same type, such as value from $RR$@rabanserIntroductionTensorDecompositions2017.

// multi-relational data:
One of the applications for tensors is to represent multi-relational data@rabanserIntroductionTensorDecompositions2017. In that case each dimension represents a single relation.

// example: first dimension: generated tokens, second dimension: batch
For #acr("CLM") inference different types of tensors are used. For example, the token id sequence during parallel text generation is a two-dimensional tensor of the following relations: `(batch, token)`.
The second dimension represents a single token id sequence, while the first dimension enables parallel text generation for `n` token id sequences.

// TODO: reference
// other example: first dimension: batch, second dimension: prediction in shape of vocabulary
Another example is the next token prediction tensor, which is a two-dimensional tensor of the following relations: `(batch, vocabulary)`. The second dimension contains the probability distribution over the whole vocabulary, while the first dimension enables parallel text generation.

The second example only displays the tensor for a single next token prediction. By adding another dimension for the `token` relation, the whole probability distribution history could be represented.
// TODO: introduce batching

After providing the motivation for tensors, the following list will introduce core terminology for use with tensors@rabanserIntroductionTensorDecompositions2017:
/ Order: Number of dimensions of a tensor
/ Shape: Number of elements in each dimension
/ Slice: Two-dimensional subfield of a tensor. Obtained by fixing all but two indices.
/ Fiber: One-dimensional subarray of a tensor. Obtained by fixing all but one index.
/ Matrix: Two-dimensional tensor.
/ Vector: One-dimensional tensor.
/ Scalar: Zero-dimensional tensor.

Fixing indices on a tensor will return a subfield or subarray, which in itself is a lower-order tensor. By fixing all indices a scalar is obtained. A slice and fiber are special terms for lower-order tensors obtained from fixing indices on a tensor.

// Precision
As introduced earlier, tensors usually contain values of the same type. Each PyTorch tensor contains values of a single data type, in short: `dtype`.
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
  caption: [Relevant PyTorch data types@TensorAttributesPyTorch],
)<table:data_types>

The data types can be used by specifying the `dtype` parameter when creating a tensor. The value is one of the variables listed in the `dtype` column in @table:data_types@TorchTensorPyTorch.

// float16 vs bfloat16
The difference between `torch.float16` and `torch.bfloat16` is the precision of the floating point number. Both formats use 16 bits to encode the floating point number. The difference lies in the number of bits used to encode the mantissa@TensorAttributesPyTorch.

The `torch.float16` is a half-precision floating point number, as defined in the IEEE 754 standard. It uses one sign bit, five exponent bits and 10 mantissa bits@IEEEStandardsAssociation.
// TODO: better IEEE reference
#figure(
  image("/assets/float16.svg"),
  caption: "IEEE 754 half-precision floating point number: float16",
)

In contast, the `torch.bfloat16` keeps the full range of the full-precision floating point number of 8-bits, but has a reduced precision of 7 mantissa bits@BFloat16SecretHigh@TensorAttributesPyTorch.
#figure(
  image("/assets/bfloat16.svg"),
  caption: "Brain Floating Point Format: bfloat16",
)
The format was introduced by Google Brain and is used in their Tensor Processing Units (TPUs)@BFloat16SecretHigh, as the reduced mantissa precision reduces the size needed for physical hardware multipliers@BFloat16SecretHigh.
// TODO: paper to show that less precision not really relevant for model quality

In addition to the precision, another aspect of a PyTorch tensor is the *physical location* it is allocated at, the `device`. The function `torch.device` creates a reference to such a physical location.
Possible relevant device locations are `cpu` and `cuda`, where `cpu` allocates a tensor on the CPU memory, while `cuda` allocates the tensor on GPU memory@TensorAttributesPyTorch.
// Device
// torch.device
// torch.to
Already creates tensor can be *moved to a different device* by calling the `to` method with the new device@TorchTensorPyTorcha.

// TEnsor, LongTensor, FloatTensor
To *create a tensor*, the function `torch.tensor` is used. It takes `data` and optionally `dtype` and the `device`@TorchTensorPyTorch.
// torch.Tensor
The order and shape of the tensor can be accessed through the `dim` and `shape` attributes@TorchTensorDim@TorchTensorShape. Indexing the tensor is done through the Python `tensor[indice_list]` notation, where untouched dimensions are marked through the `:` symbol, e.g.: `tensor[3,:,1]`@TensorIndexingAPI.
// .shape
// indexing
// iterating like normal python (over first dimension)
Iterating the tensor will iterate over the first dimension.

// functions
// torch.nn.functional

== Language Server Protocol
#columns(2)[
  #figure(
    csvtable("/assets/tables/lsp_language_ids.csv"),
    caption: "Possible language ids defined in the LSP specification",
  )<table:language_ids>
]

#figure(
  codefile("/assets/code/lsp_completion_item_kind.ts"),
  caption: "CompletionItemKind enum",
)<code:completion_item_kind>

== DependencyEval Dataset
=== Schema
#let schema-code = raw(
  block: true,
  lang: "json",
  read("/assets/DependencyEval.schema.json"),
)
#figure(
  code(
    lang: "JSON Schema",
    lines: (1, 89),
    schema-code,
  ),
  caption: "Full JSON schema of the DependencyEval dataset. The schema defines the structure of each task entry in the distributed JSONL file.",
)<code:dataset:format>

=== Tasks
#show figure: set block(breakable: false)
#figure(
  codefile("/assets/code/dataset/bidict_1.py"),
  caption: [Task: `bidict_1.py`],
)<code:dataset:task:bidict_1>
#figure(
  codefile("/assets/code/dataset/bidict_2.py"),
  caption: [Task: `bidict_2.py`],
)<code:dataset:task:bidict_2>
#figure(
  codefile("/assets/code/dataset/dateutil_1.py"),
  caption: [Task: `dateutil_1.py`],
)<code:dataset:task:dateutil_1>
#figure(
  codefile("/assets/code/dataset/dotted_1.py"),
  caption: [Task: `dotted_1.py`],
)<code:dataset:task:dotted_1>
#figure(
  codefile("/assets/code/dataset/dotted_2.py"),
  caption: [Task: `dotted_2.py`],
)<code:dataset:task:dotted_2>
#figure(
  codefile("/assets/code/dataset/emoji_1.py"),
  caption: [Task: `emoji_1.py`],
)<code:dataset:task:emoji_1>
#figure(
  codefile("/assets/code/dataset/fastapi_1.py"),
  caption: [Task: `fastapi_1.py`],
)<code:dataset:task:fastapi_1>
#figure(
  codefile("/assets/code/dataset/numpy_1.py"),
  caption: [Task: `numpy_1.py`],
)<code:dataset:task:numpy_1>
#figure(
  codefile("/assets/code/dataset/pandas_1.py"),
  caption: [Task: `pandas_1.py`],
)<code:dataset:task:pandas_1>
#figure(
  codefile("/assets/code/dataset/polars_1.py"),
  caption: [Task: `polars_1.py`],
)<code:dataset:task:polars_1>
#figure(
  codefile("/assets/code/dataset/pydantic_1.py"),
  caption: [Task: `pydantic_1.py`],
)<code:dataset:task:pydantic_1>
#figure(
  codefile("/assets/code/dataset/pydantic_2.py"),
  caption: [Task: `pydantic_2.py`],
)<code:dataset:task:pydantic_2>
#figure(
  codefile("/assets/code/dataset/pydantic_3.py"),
  caption: [Task: `pydantic_3.py`],
)<code:dataset:task:pydantic_3>
#figure(
  codefile("/assets/code/dataset/pytorch_1.py"),
  caption: [Task: `pytorch_1.py`],
)<code:dataset:task:pytorch_1>
#figure(
  codefile("/assets/code/dataset/pytorch_2.py"),
  caption: [Task: `pytorch_2.py`],
)<code:dataset:task:pytorch_2>
#figure(
  codefile("/assets/code/dataset/pytorch_3.py"),
  caption: [Task: `pytorch_3.py`],
)<code:dataset:task:pytorch_3>
#figure(
  codefile("/assets/code/dataset/rich_1.py"),
  caption: [Task: `rich_1.py`],
)<code:dataset:task:rich_1>
#figure(
  codefile("/assets/code/dataset/rich_2.py"),
  caption: [Task: `rich_2.py`],
)<code:dataset:task:rich_2>
#figure(
  codefile("/assets/code/dataset/sklearn_1.py"),
  caption: [Task: `sklearn_1.py`],
)<code:dataset:task:sklearn_1>
#figure(
  codefile("/assets/code/dataset/sklearn_2.py"),
  caption: [Task: `sklearn_2.py`],
)<code:dataset:task:sklearn_2>
#figure(
  codefile("/assets/code/dataset/sqlalchemy_1.py"),
  caption: [Task: `sqlalchemy_1.py`],
)<code:dataset:task:sqlalchemy_1>
#figure(
  codefile("/assets/code/dataset/textual_1.py"),
  caption: [Task: `textual_1.py`],
)<code:dataset:task:textual_1>
#figure(
  codefile("/assets/code/dataset/textual_2.py"),
  caption: [Task: `textual_2.py`],
)<code:dataset:task:textual_2>
#figure(
  codefile("/assets/code/dataset/theflow_1.py"),
  caption: [Task: `theflow_1.py`],
)<code:dataset:task:theflow_1>
#figure(
  codefile("/assets/code/dataset/tsv2py_1.py"),
  caption: [Task: `tsv2py_1.py`],
)<code:dataset:task:tsv2py_1>

== Full Evaluation Results
#show figure: set block(breakable: true)
=== Baseline
#figure(
  stats-table(
    (
      all-stats.map(stat-with-name => (
        stat-with-name.at(0),
        stat-with-name.at(1).at(0),
      )) + (("Copilot", aggregate-stats(get-baseline((raw-copilot,)))),)
    ).sorted(key: task-sorted-key).rev(),
  ),
  caption: [
    All evaluation baseline results.
  ],
)<table:results:approach:baseline-all-stats-all>

// #pagebreak(weak: true)
=== Approach
#figure(
  stats-table(
    all-stats.map(stat-with-name => (
      stat-with-name.at(0),
      stat-with-name.at(1).at(1),
    )).sorted(key: task-sorted-key).rev(),
  ),
  caption: [
    All evaluation results using the approach.
  ],
)<table:results:approach:llm-lsp-all-stats-all>

#pagebreak(weak: true)
=== Improvements
#figure(
  stats-table(
    all-stats.map(stat-with-name => (
      stat-with-name.at(0),
      stat-with-name.at(1).at(2),
    )).sorted(key: task-sorted-key).rev(),
    diff: true,
  ),
  caption: [
    All differences between the evaluation with and without the approach.
  ],
)<table:results:approach:diff-all-stats-all>
