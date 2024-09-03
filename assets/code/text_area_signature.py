class TextArea(
        text: str="",
        *,
        language: str | None=None,
        theme: str="css",
        soft_wrap: bool=True,
        tab_behavior: Literal["focus", "indent"]="focus",
        read_only: bool=False,
        show_line_numbers: bool=False,
        line_number_start: int=1,
        max_checkpoints: int=50,
        name: str | None=None,
        id: str | None=None,
        classes: str | None=None,
        disabled: bool=False,
        tooltip: RenderableType | None=None
)
