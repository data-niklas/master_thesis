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
  code(
    lang: "TypeScript",
    ```typescript
    namespace CompletionItemKind {
        const Text: 1;
        const Method: 2;
        const Function: 3;
        const Constructor: 4;
        const Field: 5;
        const Variable: 6;
        const Class: 7;
        const Interface: 8;
        const Module: 9;
        const Property: 10;
        const Unit: 11;
        const Value: 12;
        const Enum: 13;
        const Keyword: 14;
        const Snippet: 15;
        const Color: 16;
        const File: 17;
        const Reference: 18;
        const Folder: 19;
        const EnumMember: 20;
        const Constant: 21;
        const Struct: 22;
        const Event: 23;
        const Operator: 24;
        const TypeParameter: 25;
    }
    type CompletionItemKind = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25;
    ```,
  ),
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
