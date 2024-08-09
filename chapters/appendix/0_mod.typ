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
