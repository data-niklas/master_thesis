# llm_lsp/lsp/lsp_processor.py
def scores_for_batch(
    self, i, input_ids: LongTensor, scores: FloatTensor
) -> FloatTensor:
    """Returns a 1d FloatTensor for a single batch"""
    current_code = self.current_code(i, input_ids)
    file_name = self.file_name(i)
    with LspCodeFile(
        file_name, current_code, self.lsp_clients[i // self.expand_size]
    ) as lsp_code_file:
        if self.should_complete(current_code):
            completions = lsp_code_file.ask_completions()
            completions = lsp_code_file.resolve_completions(completions)
        else:
            completions = []
        trigger_phrase = re.search(r"[A-Za-z_]*$", current_code).group(0)
        signature_help = lsp_code_file.ask_signature()
        self.increase_signature_cache(signature_help, completions)

