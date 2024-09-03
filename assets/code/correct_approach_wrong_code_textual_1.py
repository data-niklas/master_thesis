# default/codellama_7b_greedy/textual_1.py
from textual.widgets import TextArea

def create_textual_text_area_with_indent() -> TextArea:
    """Create a TextArea widget, which indents its content when tab is pressed.

    Returns:
        TextArea: New instance of TextArea with indentation on tab press
    """
    return TextArea(tab_behavior=Literal["indent"])
