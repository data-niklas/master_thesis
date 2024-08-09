interface SignatureHelpParams {
    textDocument: TextDocumentIdentifier;
    position: Position;
    context?: SignatureHelpContext;
    // ... more fields omitted
}

