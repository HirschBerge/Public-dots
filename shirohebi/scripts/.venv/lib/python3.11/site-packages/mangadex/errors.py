from requests import Response
from typing import Union, Dict, List

class ApiError(Exception):
    def __init__(self, resp : Union[Response, dict], message = "The api responded with the error") -> None:
        self.resp = resp
        self.details = ""
        if type(self.resp) == Response:
            self.code = self.resp.status_code                
        else:
            self.code = self.resp["status"]

        self.message = message
        super().__init__(self.message)
        self.details = self.resp.text["detail"]
    def __str__(self) -> str:
        return f"{self.message}: {self.code} \n {self.details}"

class ApiClientError(Exception):
    pass

class BaseError(Exception):
    def __init__(self, data : dict, message : str = None) -> None:
        self.data = data
        self.message = message
        super(BaseError, self).__init__(self.message)
    
class MangaError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(MangaError, self).__init__(data, message=message)
        self.data = data
        self.message = message

class TagError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(TagError, self).__init__(data, message=message)
        self.data = data
        self.message = message
    

class ChapterError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(ChapterError, self).__init__(data, message=message)
        self.data = data
        self.message = message
    
class AuthorError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(AuthorError, self).__init__(data, message=message)
        self.data = data
        self.message = message

class ScanlationGroupError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(ScanlationGroupError, self).__init__(data, message=message)
        self.data = data
        self.message = message

class UserError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(UserError,self).__init__(data, message=message)
        self.data = data
        self.message = message

class CustomListError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(CustomListError, self).__init__(data, message)
        self.data = data
        self.message = message

class CoverArtError(BaseError):
    def __init__(self, data: dict, message: str) -> None:
        super(CoverArtError, self).__init__(data, message=message)
        self.data = data
        self.message = message