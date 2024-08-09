# llm_lsp/config.py
@dataclass
class LspGenerationConfig:
    boundary_processor: bool = True
    comments_processor: bool = True
    lsp_processor: bool = True
    enabled: bool = True
    chat_history_log_file: Optional[str] = None
    force_custom_pad: bool = False
    predict_correct_completion_symbol: bool = True
    masked_gen: bool = True
    use_completion_context: bool = False
    use_deprecation_context: bool = True
    use_signature_context: bool = True

