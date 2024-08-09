# llm_lsp/mixins/log_mixin.py
def log(self, text: str):
    with open(self.config.chat_history_log_file, "a") as f:
        f.write(text)
def log_interruption(self, input_ids, interrupt_index):
    if self.config.chat_history_log_file is None:
        return
    code_snippets = self.tokenizer.batch_decode(input_ids)
    # ... text formatting into variable `text` ...
    self.log(text)

