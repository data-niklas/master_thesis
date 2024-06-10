#import "/utils.typ": *

== Language Server Protocol <bg_lsp>
Many modern editors and #acrpl("IDE") provide features such as:
- Autocompletion
- Signature help
- Go to the definition of a symbol
- Go to the uses of a symbol
- Provide diagnostics data on the current file
- Rename symbols

// Important because
This list is not exhaustive, and the features between different editors may wary. These features are vital for any programmer, as the effort to create and maintain code is significantly reduced. Navigating large code bases and finding documentation on used code is highly beneficial.

// High effort
These many features take a significant effort to implement for a *single* programming language and editor. Providing support for several programming languages massively increases the implementation effort. In addition, the created features must be maintained next to the editor itself. As more programming languages are designed and are adopted, the need for tooling for these programming languages arises. Editor maintainers must then integrate these features for the new programming language.
// Example Rust a few years ago, zig now, koka in the feature, crystal, ...

Providing support for an ever increasing amount of programming languages is hard, but supporting these features for an ever increasing amount of programming languages in every editor is impossible. Many diverse editors exist, such as Emacs, VSCode, Neovim (modern fork of Vim), Zed (the successor of Atom), Jetbrains #acrpl("IDE"), Helix and many more.
// TODO: reference every editor

Thus, a solution is needed to extract thes *common* features from the editors and provide them centrally, such that every editor need only implement an interface to integrate the common features.
The #acrl("LSP") is an effort to standardize a common feature set for programming language tooling for use in #acrpl("IDE"). The protocol was designed my Microsoft for use in its Visual Studio Code editor, but is now an open standard. This thesis will focus on version `3.17` of the protocol. The protocol includes many different features, of which the following sections introduce a few important. The full specification may be accessed // TODO: here ref lsp spec

=== Design
The protocol is based on a bidirectional client-server architecture. The client is a tool such as the #acr("IDE"). The server, henceforth called the language server, is programming language specific tooling that provides a subset of the protocol. Both the client and server must not implement the full protocol. 
The protocol is capability based. Both parties define and communicate their capabilities, then find common capabilities and restrict their use to them.
Each client can connect to multiple language servers, and each language server can serve multiple clients. As such a client could use a language server for the Rust programming language while the user is coding on a Rust project. As soon as the user switches projects to a web project, the editor could then connect to several language servers to provide support for HTML, CSS and JavaScript at once. In that scenario several simultaneous language servers are necessary, as CSS and JavaScript can be embedded into HTML.
// Embedded programming languages!? Code block in markdown
The communication between the client and server must be bidirectional, as the server must be able to notify the client about events occuring, such as new diagnostic information.


=== JSON-RPC
The base protocol relies on #acr("JSON-RPC"). The following section will give a short introduction on the protocol.
The content part is specified using #acr("JSON-RPC"). #acr("JSON-RPC") is a light-weight and stateless protocol to encode #acrpl("RPC"). The specification defines data structures and processing rules. As such, the protocol is transport-agnostic and can be used with any type of message passing framework. The data structures are encoded using the #acr("JSON") data format.
// TODO: http, websockets, etc

// Versioning
The protocol is versioned. Currently the versions `1.0` and `2.0` are specified. The #acr("LSP") uses version `2.0` of #acr("JSON-RPC"). Henceforth, the sections will focus on version `2.0` of the protocol.

#acr("JSON-RPC") defines three types of messages:
- Requests
- Responses
- Notifications
, though notifications could be considered a special case of requests. The following section will provide details on each type.

Messages will be defined using TypeScript interfaces, in accordance with the #acr("LSP") specification. A general message has the following interface:
#figure(code(lang: "TypeScript",
```typescript
interface Message {
    jsonrpc: string;
}
```), caption: "General message interface")

To define the other message types, additional TypeScript types are introduced:
- `integer`: A signed 32-bit integer aliased to the TypeScript type `number`.
- `uinteger`: An unsigned 32-bit integer aliased to the TypeScript type `number`.
- `LSPArray`: 

// Request
Request objects have the following #acr("JSON") format, as defined by the following json format: 
#figure(code(lang: "JSON", ```json
{
    "jsonrpc": "string",
    "method": "string",
    "params": "any",
    "id": "string|number|null"
}
```), caption: "Request object format")
The `jsonrpc` field contains the version used and must be set to `2.0`. The `method` field contains the name of the remote procedure to be called.
// TODO: special case rpc_
Any parameters needed to call the remote function should be passed in the optional field `params`.
At last, the `id` field identifies the message and thus allows correlation between requests and responses. Using fractional numbers is discouraged, as the floating point accuracy issue contradicts the identification of the `id`.
// TODO: refactor previous sentence

Each request must be answered by a response. The response object has the following format:
#code(lang: "JSON", ```json
{
    "jsonrpc": "string",
    "result": "any",
    "error": {
        "code": "number",
        "message": "string",
        "data": "any"
    },
    "id": "string|number|null"
}
```)
Similar to the request object, the `jsonrpc` field must be set to `2.0`.
Either the `result` or `error` field will be set, depending on the success of the request. To correlate requests and responses, the response will contain the `id` of the request in the field `id`.

Error responses contain the error `code`, a short descriptive `message` and optional additional `data`. The specification defines the following error codes and messages:
#table(
columns: (auto, auto, auto),
    table.header([*Code*], [*Message*], [*Meaning*]),
    [-32700], [Parse error], [The server received invalid #acr("JSON")],
    [-32600], [Invalid Request], [The request is not a valid request object],
    [-32601], [Method not found], [The method does not exist or is not available],
    [-32602], [Invalid params], [Invalid method parameters],
    [-32603], [Internal error], [An internal error occurred while processing the request],
    [-32000], [Server error], [Reserved for implementation-defined server errors]
)

In addition, the protocol allows custom error codes.

The final type of message is the notification. Notifications are a special type of request, as they do not contain an `id`. Notifications do not require a response from the server.

// TODO: say that batch not required

=== Base protocol
The base protocol defines the general format, in which `messages` are sent between the client and server. Each message contains a headers and a content part, separated by `\r\n`.
// TODO: comparison to HTTP? Do the headers use the ASCII coding, same as HTTP?
// TODO: insert figure of message format

The headers part contains at least one header field, which are key-value pairs separated by a colon. Each header field is terminated by a `\r\n`.
The following headers are currently supported:
- `Content-Length`: A mandatory header that specifies the length of the content part in bytes.
- `Content-Type`: The #acr("MIME") type of the content part. The default is `application/vscode-jsonrpc; charset=utf-8` and no other charset is currently supported.

The content part is a #acr("JSON") object, as defined by the #acr("JSON-RPC") specification.


=== Basic JSON structures

=== Lifecycle Messages

=== Document Synchronization

=== Language Features

=== Completion
- types of items (functions, fields, etc.)
- documentation
- flags, such as deprecated
- implementation up to servers
- many servers for many languages
=== Signature help
- Arguments
=== Note thingy
