from typing import Any, Dict

from pydantic import BaseModel


class User(BaseModel):
    name: str
    email: str
    age: int

def convert_user_to_dict(user: User) -> Dict[str, Any]:
    """Convert the user into a Python dictionary.

    Args:
        user (User): Pydantic user model

    Returns:
        Dict[str, Any]: User attributes as a Python key value mapping
    """
    # The following methods are deprecated, use alternatives as instructed in the given docstrings:
    # - The `dict` method is deprecated; use `model_dump` instead.
    # - The `json` method is deprecated; use `model_dump_json` instead.
    # - ...
    return user.
