from typing import Any, Dict
from pydantic import BaseModel

class User(BaseModel):
    ...

def convert_user_to_dict(user: User) -> Dict[str, Any]:
    """Convert the user into a Python dictionary.
    ...
    """
    return user.model_dump()
