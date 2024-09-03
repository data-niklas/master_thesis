def model_dump(
    *,
    mode: Literal["json", "python"] | str = "python",
    include: IncEx = None,
    exclude: IncEx = None,
    context: Any | None = None,
    by_alias: bool = False,
    exclude_unset: bool = False,
    exclude_defaults: bool = False,
    exclude_none: bool = False,
    round_trip: bool = False,
    warnings: (
        bool | Literal["none", "warn", "error"]
    ) = True,
    serialize_as_any: bool = False
) -> dict[str, Any]
