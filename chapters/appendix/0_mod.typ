#import "/utils.typ": *
= Appendix
#show figure: set block(breakable: true)

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
    lines: (1, 86),
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
