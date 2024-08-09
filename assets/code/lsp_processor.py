# llm_lsp/lsp/lsp_processor.py
def __call__(self, input_ids: LongTensor, scores: FloatTensor) -> FloatTensor:
    """Returns a 2d FloatTensor which has scores for every batch"""
    if not self.config.lsp_processor or not self.config.enabled:
        return scores
    for i in range(input_ids.shape[0]):
        try:
            scores[i] = self.scores_for_batch(i, input_ids[i], scores[i])
        except InterruptGeneration as ig:
            scores[i][self.interrupt_token_id] = INTERRUPT_LOGITS_SCORE
            self.interrupt = Interrupt(
                input_ids=input_ids,
                interrupt_context=ig.context,
                interrupt_type_name=ig.interrupt_type_name,
            )
            return scores
    return scores

