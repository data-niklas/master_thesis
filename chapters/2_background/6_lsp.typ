#import "/utils.typ": *

== Language Server Protocol <chapter:bg:lsp>
Many modern editors and #acrpl("IDE") provide features such as:
- Autocompletion
- Signature help
- Go to the definition of a symbol
- Go to the uses of a symbol
- Provide diagnostics data on the current file
- Rename symbols

// Important because
This list is not exhaustive, and the features between different editors may vary. These features are vital for any programmer, as the effort to create and maintain code is significantly reduced. Navigating large code bases and finding documentation on used code is highly beneficial.

// High effort
These many features take a significant effort to implement for a *single* programming language and editor. Providing support for several programming languages massively increases the implementation effort. In addition, the created features must be maintained next to the editor itself. As more programming languages are designed and adopted, the need for tooling for these programming languages arises. Editor maintainers must then integrate these features for the new programming language.
// Example Rust a few years ago, zig now, koka in the feature, crystal, ...

Providing support for an ever-increasing amount of programming languages is hard, but supporting these features for an ever-increasing amount of programming languages in every editor is impossible. Many diverse editors exist, such as Emacs @GNUEmacsGNU @LSPModeLanguage, VSCode @VisualStudioCode @LanguageServerExtension, Neovim (modern fork of Vim) @HomeNeovim @LspNeovimDocs, Zed (the successor of Atom) @ZedCodeSpeed @AddingNewLanguages, Jetbrains #acrpl("IDE") @JetBrainsIDEsEnjoy @LanguageServerProtocol, Helix @HelixeditorHelix2024 @LanguageSupport and many more.
// TODO: reference every editor

Thus, a solution is needed to extract the *common* features from the editors and provide them centrally, such that every editor need only implement an interface to integrate the common features.
The #acrl("LSP") is an effort to standardize a common feature set for programming language tooling for use in #acrpl("IDE"). The protocol was designed my Microsoft for use in its Visual Studio Code editor, but is now an open standard. This thesis will focus on version `3.17` of the protocol. The protocol includes many different features, of which the following sections introduce a few important. The full specification may be accessed #link("https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#languageFeatures")[here] @Specification.

=== Design
The protocol is based on a bidirectional client-server architecture. The client is a tool such as the #acr("IDE"). The server, henceforth called the language server, is programming language specific tooling that provides a subset of the protocol. Both the client and server must not implement the full protocol.
The protocol is capability based. Both parties define and communicate their capabilities, then find common capabilities and restrict their use to them.
Each client can connect to multiple language servers, and each language server can serve multiple clients. As such a client could use a language server for the Rust programming language while the user is coding on a Rust project. As soon as the user switches projects to a web project, the editor could then connect to several language servers to provide support for HTML, CSS and JavaScript at once. In that scenario several simultaneous language servers are necessary, as CSS and JavaScript can be embedded into HTML.
// Embedded programming languages!? Code block in markdown
The communication between the client and server must be bidirectional, as the server must be able to notify the client about events occurring, such as new diagnostic information.

=== JSON-RPC
The base protocol relies on #acr("JSON-RPC"). The following section will give a short introduction on the protocol.
The content part is specified using #acr("JSON-RPC"). #acr("JSON-RPC") is a light-weight and stateless protocol to encode #acrpl("RPC"). The specification defines data structures and processing rules. As such, the protocol is transport-agnostic and can be used with any type of message passing framework. The data structures are encoded using the #acr("JSON") data format.
// TODO: http, websockets, etc

// Versioning
The protocol is versioned. Currently, the versions `1.0` and `2.0` are specified. The #acr("LSP") uses version `2.0` of #acr("JSON-RPC"). Henceforth, the sections will focus on version `2.0` of the protocol.

#acr("JSON-RPC") defines three types of messages:
- Requests
- Responses
- Notifications
, though notifications could be considered a special case of requests. The following section will provide details on each type.

Messages will be defined using TypeScript interfaces, in accordance with the #acr("LSP") specification. A general message has the following interface:
#figure(
  codefile("/assets/code/lsp_message.ts"),
  caption: "General message interface",
)

To define the other message types, additional TypeScript types are introduced:
- `integer`: A signed 32-bit integer aliased to the TypeScript type `number`.
- `uinteger`: An unsigned 32-bit integer aliased to the TypeScript type `number`.
- `LSPArray`:

// Request
Request objects have the following #acr("JSON") format, as defined by the following Typescript interface:
#figure(
  codefile("/assets/code/lsp_request.ts"),
  caption: "Request object format",
)
The `jsonrpc` field contains the version used and must be set to `2.0`. The `method` field contains the name of the remote procedure to be called.
// TODO: special case rpc_
Any parameters needed to call the remote function should be passed in the optional field `params`.
At last, the `id` field identifies the message and thus allows correlation between requests and responses. Using fractional numbers is discouraged, as the floating point accuracy issue contradicts the identification of the `id`.
// TODO: refactor previous sentence

Each request must be answered by a response. The response object has the following format:
#figure(
  codefile("/assets/code/lsp_response.ts"),
  caption: "Response object format",
)
Similar to the request object, the `jsonrpc` field must be set to `2.0`.
Either the `result` or `error` field will be set, depending on the success of the request. To correlate requests and responses, the response will contain the `id` of the request in the field `id`.

Error responses contain the error `code`, a short descriptive `message` and optional additional `data`. The specification defines the following error codes and messages:
#figure(
  table(
    columns: 3,
    table.header([*Code*], [*Message*], [*Meaning*]),
    [-32700],
    [Parse error],
    [The server received invalid #acr("JSON")],
    [-32600],
    [Invalid Request],
    [The request is not a valid request object],
    [-32601],
    [Method not found],
    [The method does not exist or is not available],
    [-32602],
    [Invalid params],
    [Invalid method parameters],
    [-32603],
    [Internal error],
    [An internal error occurred while processing the request],
    [-32000],
    [Server error],
    [Reserved for implementation-defined server errors],
  ),
  caption: "Error codes and messages",
)

In addition, the protocol allows custom error codes.

The final type of message is the notification. Notifications are a special type of request, as they do not contain an `id`. Notifications do not require a response from the server:
#figure(
  codefile("/assets/code/lsp_notification.ts"),
  caption: "Notification object format",
)

// TODO: say that batch not required

=== Base protocol
The base protocol defines the general format, in which `messages` are sent between the client and server. Each message contains a headers and a content part, separated by `\r\n`.
// TODO: comparison to HTTP? Do the headers use the ASCII coding, same as HTTP?
// TODO: insert figure of message format

The headers part contains at least one header field, which are key-value pairs separated by a colon. Each header field is terminated by a `\r\n`.
The following headers are currently supported:
- `Content-Length`: A mandatory header that specifies the length of the content part in bytes.
- `Content-Type`: The #acr("MIME") type of the content part. The default is `application/vscode-jsonrpc; charset=utf-8` and no other charset is currently supported.

The content part is a #acr("JSON") object, as defined by the #acr("JSON-RPC") specification. The #acr("LSP") specification differs from the #acr("JSON-RPC") in the use of certain types. It restricts the numeric type used for `id` and `code` from `number` to `integer`, to disallow floating point identifiers.

=== Basic JSON structures
Many #acrpl("RPC") share common structures needed to communicate about language features. The following section introduces a few necessary ones.

// URI
The first important structure is the #acr("URI"), as defined by rfc3986 @berners-leeUniformResourceIdentifier2005. #acrpl("URI") are passed as strings and are used to uniquely identify files the language server and client work with.

// Position
To identify a position inside such a file, the protocol defines the `Position` structure:
#figure(
  codefile("/assets/code/lsp_position.ts"),
  caption: "Position structure",
)<code:position>
Line and character define the position in the file starting at `0`.

The last structure is `TextDocumentItem`, which represents an editable text document:
#figure(
  codefile("/assets/code/lsp_text_document_item.ts"),
  caption: "TextDocumentItem structure",
)<code:text_document_item>
In addition to the unique identifier of the document, the `uri`, the structure contains the content of the document in the field `text`. The `languageId` field defines the language of the document. This is needed especially when the language server processes documents of different languages. Passing the `languageId` prevents re-interpreting the file extension. The possible language ids are defined in the specification and can be seen in @table:language_ids in full.

=== Lifecycle Messages
After defining the basic structures, this section introduces the first messages to control the lifecycle of the language server.

// Initialize
The first message the client sends the server, is the `initialize` message. No other communication will occur, until the server acknowledges the initialization with the response. The connection between client and server may only be initialized once.
The `initialize` message has the following key fields:
#figure(
  codefile("/assets/code/lsp_initialize.ts"),
  caption: "Initialize message parameters",
)<code:initialize>
The `rootUri` is an optional field that specifies the root path of the workspace, the client is working on. Setting the workspace e.g. enables finding virtual environments needed to scan the local code base.
The next field `capabilities` is a complex structure of flags, which specify all capabilities the client has.

The server responds with the initialize result, which contains the server capabilities.

After receiving the response, the client must then acknowledge the response, by sending the `initialized` message. The server then has the option to e.g. register capabilities dynamically or run further initializations. Afterward, the initialization process is finished.

// TODO: replace many after
After using the language server, the client can stop the server in a two-step process. First, the client sends a `shutdown` message. The server then stops itself, but preserves its messaging capabilities to send a proper response. In the next step, the client sends the `exit` message, after which the server exits its process.

=== Document Synchronization
After introducing messages to establish and control the connection between server and client, this section focused on the next step, the document synchronization. The goal of these messages is to synchronize the server to the users actions. The server should provide capabilities for a file, while the user works on it.

The first message is the `textDocument/didOpen` notification. Sending this notification informs the server that the client opened the document. The message has the following structure:
#figure(
  codefile("/assets/code/lsp_did_open_text_document.ts"),
  caption: "DidOpenTextDocument message parameters",
)<code:did_open_text_document>

As soon as the file is closed, the client sends the `textDocument/didClose` notification. The message has the same structure as in @code:did_open_text_document.

Other messages for synchronizing documents and notebooks exist and are omitted.
// TODO: for in depth information look here

// Not needed, as workspace root files are specified in the initialize message
// === Workspace Synchronization

=== Language Features
This section displays messages to query language features. The #acr("LSP") specification defines many different features, of which this section highlights the few relevant ones:
- Auto-Completion
- Signature help
- Provide diagnostics data on the current file

// Completion
The auto-completion feature provides a list of completion items for a given position in a document. The completion items can be selected to provide more detailed information. On applying the selected completion item, the completion text is inserted into the document at the given position.
The feature is split into the two messages `textDocument/completion` and `completionItem/resolve`.The first message queries the completion items for the given position in a text document. Each completion item only contains basic information. If further details are required, the second message `completionItem/resolve` asks the server to extend a single completion item with in depth details.

A completion item has the following structure:
#figure(
  codefile("/assets/code/lsp_completion_item.ts"),
  caption: "CompletionItem structure",
)<code:completion_item>

The first key property is `label`. The `label` is the main text to be inserted into the document and provides the full symbol. In case the document already contains a prefix of the `label` in the given location, the inserted text must not contain the prefix. In these cases the `label` property remains untouched, but `insertText` is set to the shortened text. `insertText` overrides the text to be inserted, but remains optional.

The `labelDetails` property contains additional information, such as the locator of the symbol to be inserted. The structure of the property can be found in @code:completion_item_label_details.

For accessibility, the completion item includes several human readable properties:
- `detail` provides a short description of the completion item.
- `documentation` provides a detailed description of the completion item. The description can be plain text or Markdown. The structure of the property can be found in @code:markup_content.

The next field `kind` specifies the type of the completion item. The type refers to the symbol kind, such as a "function", "field" or "string". The full list is defined in @code:completion_item_kind.

Annotations can be found in the field `tags`. The only supported tag is `Deprecated`, as defined in @code:completion_item_tag. It replaces the now deprecated field `deprecated`.

After receiving the completion items, the client can display the items in a list. The field `preselect` can mark a *single* completion item to be preselected in the list. Additionally, the client may filter and sort the items. In these cases it should use the fields `filterText` and `sortText` for these tasks, instead of `label`.

Additional server specific data is stored in the field `data`. This information is needed by the server to resolve the completion item and should not be changed.
// CompletionItemLabelDetails
#figure(
  codefile("/assets/code/lsp_completion_item_label_details.ts"),
  caption: "CompletionItemLabelDetails structure",
)<code:completion_item_label_details>

// CompletionItemTag
#figure(
  codefile("/assets/code/lsp_completion_item_tag.ts"),
  caption: "CompletionItemTag enum",
)<code:completion_item_tag>

// MarkupContent
#figure(
  codefile("/assets/code/lsp_markup_content.ts"),
  caption: "MarkupContent structure",
)<code:markup_content>

// Markup Kind
#figure(
  codefile("/assets/code/lsp_markup_kind.ts"),
  caption: "MarkupKind enum",
)<code:markup_kind>

The @code:markup_content structure includes markup content in the field `value`. The type of markup is defined in the field `kind`. Currently the two kinds *plain text* and *Markdown* are supported, as seen in @code:markup_kind.

// Completion request
To request completions, the client then sends the `textDocument/completion` message. The request the following structure:
#figure(
  codefile("/assets/code/lsp_completion_params.ts"),
  caption: "Completion message parameters",
)<code:completion_params>

The request contains a `position` in the document `textDocument`. The optional `context` has further details on how the completion was triggered (`triggerKind`) and with which character it was triggered (`triggerCharacter`), as seen in @code:completion_context. Several trigger kinds are currently supported, such as invoked, triggered by a character, or re-triggered to expand an incomplete completion list (@code:completion_trigger_kind).

// Completion Context
#figure(
  codefile("/assets/code/lsp_completion_context.ts"),
  caption: "CompletionContext structure",
)<code:completion_context>

#figure(
  codefile("/assets/code/lsp_completion_trigger_kind.ts"),
  caption: "CompletionTriggerKind enum",
)<code:completion_trigger_kind>

// TODO: use such links everywhere
The server then responds either with no result, directly with a list of #link(<code:completion_item>)[completion items], or a completion list, as seen in @code:completion_list.

#figure(
  codefile("/assets/code/lsp_completion_list.ts"),
  caption: "CompletionList structure",
)<code:completion_list>
In addition to containing the completion items, the structure also may indicate that the list is incomplete and will be recomputed // TODO: recomputed when
through the field `isIncomplete`.

// Resolving completion items
Resolving a single completion item is done by sending the `completionItem/resolve` message. The message is the completion item to be resolved. The server then responds with the resolved completion item. The resolved completion item is a superset of the provided completion item.

// TODO: improve readability / formatting
// Signature help
The second feature is the signature help. The signature help provides information about the signature of the symbol at the specified position. A common use case is to display function and class parameters.

// TODO: check the most specific words are used, so notification / request over message
Sending the `textDocument/signatureHelp` request to the server returns the signature help. The request has a similar structure to @code:completion_params, as seen in @code:signature_help_params:

#figure(
  codefile("/assets/code/lsp_signature_help_params.ts"),
  caption: "SignatureHelp message parameters",
)<code:signature_help_params>

The `context` field contains additional information about the context in which the signature help was triggered.
// TODO: maybe emit or list

The server responds with the signature help in the structure of @code:signature_help:
#figure(
  codefile("/assets/code/lsp_signature_help.ts"),
  caption: "SignatureHelp structure",
)<code:signature_help>

The symbol could have several signatures, of which each is represented by a `SignatureInformation` structure. Each single `SignatureInformation` has a `label`, to be shown in the UI, as well as the documentation regarding the whole item.
Single parameters can be retrieved through the `parameters` field. When typing a function call, the currently typed parameter becomes the active parameter in the `SignatureInformation` (`activeParameter`).
The parameters each come with a `label` and `documentation` field. The `label` either is a string, or a range referring to the label of the outer signature.

The signature help structure is defined in @code:signature_information, while the single parameter information is provided in @code:parameter_information.

#figure(
  codefile("/assets/code/lsp_signature_information.ts"),
  caption: "SignatureInformation structure",
)<code:signature_information>

#figure(
  codefile("/assets/code/lsp_parameter_information.ts"),
  caption: "ParameterInformation structure",
)<code:parameter_information>

// TODO: outro
