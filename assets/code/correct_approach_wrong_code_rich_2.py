# default/mistralhermes_codepro_7b_sampling/rich_2.py
from rich.prompt import Prompt

def create_case_insensitive_prompt(text: str) -> Prompt:
    """Create a prompt instance, providing the text and using case insensitivity.

    Args:
        text (str): prompt text

    Returns:
        Prompt: created prompt
    """
    return Prompt(text, case_sensitive=False)</s>
    123456789
``

