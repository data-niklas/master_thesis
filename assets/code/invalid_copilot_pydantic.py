from typing import Any, Dict
from pydantic import BaseModel


class User(BaseModel):
    name: str
    email: str
    age: int


def convert_user_to_dict(user: User) -> Dict[str, Any]:
    # the function user.dict is deprecated, and user.model_dump should be used instead
    return user.dict()
