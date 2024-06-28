#import "/utils.typ": *
= Appendix
#show figure: set block(breakable: true)
#columns(2)[
  #figure(
    table(
      columns: 2,
      table.header([*Language*], [*Language ID*]),
      [ABAP],
      [abap],
      [Windows Bat],
      [bat],
      [BibTeX],
      [bibtex],
      [Clojure],
      [clojure],
      [Coffeescript],
      [coffeescript],
      [C],
      [c],
      [C++],
      [cpp],
      [C\#],
      [csharp],
      [CSS],
      [css],
      [Diff],
      [diff],
      [Dart],
      [dart],
      [Dockerfile],
      [dockerfile],
      [Elixir],
      [elixir],
      [Erland],
      [erlang],
      [F\#],
      [fsharp],
      [Git],
      [git-commit and git-rebase],
      [Go],
      [go],
      [Groovy],
      [groovy],
      [Handlebars],
      [handlebars],
      [HTML],
      [html],
      [Ini],
      [ini],
      [Java],
      [java],
      [JavaScript],
      [javascript],
      [JavaScript React],
      [javascriptreact],
      [JSON],
      [json],
      [LaTeX],
      [latex],
      [Less],
      [less],
      [Lua],
      [lua],
      [Makefile],
      [makefile],
      [Markdown],
      [markdown],
      [Objective-C],
      [objective-c],
      [Objective-C++],
      [objective-cpp],
      [Perl],
      [perl],
      [Perl 6],
      [perl6],
      [PHP],
      [php],
      [Powershell],
      [powershell],
      [Pug],
      [jade],
      [Python],
      [python],
      [R],
      [r],
      [Razor],
      [razor],
      [Ruby],
      [ruby],
      [Rust],
      [rust],
      [SCSS],
      [scss or sass],
      [Scala],
      [scala],
      [ShaderLab],
      [shaderlab],
      [Shellscript],
      [shellscript],
      [SQL],
      [sql],
      [Swift],
      [swift],
      [TypeScript],
      [typescript],
      [TypeScript React],
      [typescriptreact],
      [TeX],
      [tex],
      [Visual Basic],
      [vb],
      [XML],
      [xml],
      [XSL],
      [xsl],
      [YAML],
      [yaml],
    ),
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
