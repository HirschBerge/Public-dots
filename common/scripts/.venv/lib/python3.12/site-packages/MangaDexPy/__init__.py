import requests
import json
import time
from typing import List, Dict, Union, Type
from .manga import Manga, MangaTag
from .chapter import Chapter
from .group import Group
from .user import User
from .author import Author
from .cover import Cover
from .network import NetworkChapter
from .search import SearchMapping

INCLUDE_ALL = ["cover_art", "manga", "chapter", "scanlation_group", "author", "artist", "user", "leader", "member"]


class MDException(Exception):
    pass


class APIError(MDException):
    def __init__(self, r):
        self.status = r.status_code
        self.data = None
        try:
            self.data = r.json()
        except json.decoder.JSONDecodeError:
            self.data = r.content


class NoContentError(APIError):
    pass


class LoginError(APIError):
    pass


class NotLoggedInError(MDException):
    pass


class NoResultsError(MDException):
    pass


class MangaDex:
    """Represents the MangaDex API Client."""
    def __init__(self):
        self.api = "https://api.mangadex.org"
        self.net_api = "https://api.mangadex.network"
        self.session = requests.Session()
        self.session.headers["Authorization"] = ""
        self.login_success = False
        self.session_token = None
        self.refresh_token = None
        self.rate_limit = 0.25
        self.constants = {"INCLUDE_ALL": INCLUDE_ALL}

    def login(self, username: str, password: str) -> bool:
        """Logs in to MangaDex using an username and a password."""
        credentials = {"username": username, "password": password}
        post = self.session.post(f"{self.api}/auth/login", data=json.dumps(credentials),
                                 headers={"Content-Type": "application/json"})
        return self._store_token(post)

    def login_token(self, token: str) -> bool:
        """Logs in to MangaDex using a refresh token."""
        credentials = {"token": token}
        post = self.session.post(f"{self.api}/auth/refresh", data=json.dumps(credentials),
                                 headers={"Content-Type": "application/json"})
        return self._store_token(post)

    def logout(self):
        """Resets the current session."""
        self.__init__()

    def refresh_session(self, token: str = None) -> bool:
        """Refreshes the session using the refresh token."""
        if not self.login_success:
            raise NotLoggedInError
        token = token or self.refresh_token
        data = {"token": token}
        post = self.session.post(f"{self.api}/auth/refresh", data=json.dumps(data),
                                 headers={"Content-Type": "application/json"})
        return self._store_token(post)

    def check_session(self) -> bool:
        """Checks if the stored Authorization token is still valid."""
        req = self.session.get(f"{self.api}/auth/check")
        if req.status_code == 200:
            resp = req.json()
            return resp["isAuthenticated"]
        else:
            raise APIError(req)

    def _store_token(self, post):
        if post.status_code == 401:
            raise LoginError(post)
        elif not post.status_code == 200:
            raise APIError(post)
        else:
            resp = post.json()
            self.login_success = True
            self.session_token = resp["token"]["session"]
            self.refresh_token = resp["token"]["refresh"]
            self.session.headers["Authorization"] = resp["token"]["session"]
            return True

    def get_manga(self, uuid: str, includes: list = None) -> Manga:
        """Gets a manga with a specific uuid."""
        includes = INCLUDE_ALL if not includes else includes
        params = None
        if includes:
            params = {"includes[]": includes}
        req = self.session.get(f"{self.api}/manga/{uuid}", params=params)
        if req.status_code == 200:
            resp = req.json()
            return Manga(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def get_chapter(self, uuid: str, includes: list = None) -> Chapter:
        """Gets a chapter with a specific uuid."""
        includes = INCLUDE_ALL if not includes else includes
        params = None
        if includes:
            params = {"includes[]": includes}
        req = self.session.get(f"{self.api}/chapter/{uuid}", params=params)
        if req.status_code == 200:
            resp = req.json()
            return Chapter(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def get_chapters(self, ids: List[str], includes: list = None) -> List[Chapter]:
        """Gets chapters with specific uuids."""
        includes = INCLUDE_ALL if not includes else includes
        chapters = []
        sub = [ids[x:x+100] for x in range(0, len(ids), 100)]
        _rem = len(sub)
        for s in sub:
            p = {"ids[]": s, "includes[]": includes}
            req = self.session.get(f"{self.api}/chapter", params=p)
            _rem -= 1
            if _rem:
                time.sleep(self.rate_limit)
            if req.status_code == 200:
                resp = req.json()
                chapters += [x for x in resp["data"]]
            elif req.status_code == 204:
                pass
            else:
                raise APIError(req)
        if not sub or not chapters:
            raise NoResultsError()
        return [Chapter(x, self) for x in chapters]

    def get_manga_chapters(self, mg: Manga, params: dict = None, includes: list = None) -> List[Chapter]:
        """Gets chapters associated with a specific Manga."""
        includes = INCLUDE_ALL if not includes else includes
        params = params or {}
        if includes:
            params["includes[]"] = includes
        return self._retrieve_pages(f"{self.api}/manga/{mg.id}/feed", Chapter, call_limit=100, params=params)

    def get_manga_covers(self, mg: Manga, params: dict = None) -> List[Cover]:
        """Gets covers associated with a specific Manga."""
        params = params or {}
        params["manga[]"] = mg.id
        return self._retrieve_pages(f"{self.api}/cover", Cover, call_limit=100, params=params)

    def get_cover(self, uuid: str) -> Cover:
        """Gets a cover with a specific uuid."""
        req = self.session.get(f"{self.api}/cover/{uuid}")
        if req.status_code == 200:
            resp = req.json()
            return Cover(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def read_chapter(self, ch: Chapter, force_443: bool = False) -> NetworkChapter:
        """Pulls a chapter from the MD@H Network."""
        data = {"forcePort443": force_443}
        req = self.session.get(f"{self.api}/at-home/server/{ch.id}", params=data)
        if req.status_code == 200:
            resp = req.json()
            return NetworkChapter(resp, ch, self)
        else:
            raise APIError(req)

    def network_report(self, url: str, success: bool, cache_header: bool, req_bytes: int, req_duration: int) -> bool:
        """Reports statistics back to the MD@H Network."""
        data = {"url": url, "success": success, "cached": cache_header, "bytes": req_bytes, "duration": req_duration}
        req = self.session.post(f"{self.net_api}/report", data=json.dumps(data),
                                headers={"Content-Type": "application/json"})
        if req.status_code == 200:
            return True
        else:
            raise APIError(req)

    def get_group(self, uuid: str, includes: list = None) -> Group:
        """Gets a group with a specific uuid."""
        includes = INCLUDE_ALL if not includes else includes
        params = None
        if includes:
            params = {"includes[]": includes}
        req = self.session.get(f"{self.api}/group/{uuid}", params=params)
        if req.status_code == 200:
            resp = req.json()
            return Group(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def get_user(self, uuid: str = "me") -> User:
        """Gets an user with a specific uuid."""
        if uuid == "me" and not self.login_success:
            raise NotLoggedInError
        req = self.session.get(f"{self.api}/user/{uuid}")
        if req.status_code == 200:
            resp = req.json()
            return User(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def get_user_list(self, limit: int = 100) -> List[Manga]:
        """Gets the currently logged user's manga list."""
        if not self.login_success:
            raise NotLoggedInError
        return self._retrieve_pages(f"{self.api}/user/follows/manga", Manga, limit=limit, call_limit=100)

    def get_user_updates(self, limit: int = 100, params: dict = None) -> List[Chapter]:
        """Gets the currently logged user's manga feed."""
        if not self.login_success:
            raise NotLoggedInError
        params = params or {}
        return self._retrieve_pages(f"{self.api}/user/follows/manga/feed", Chapter, call_limit=100,
                                    limit=limit, params=params)

    def get_author(self, uuid: str) -> Author:
        """Gets an author with a specific uuid"""
        req = self.session.get(f"{self.api}/author/{uuid}")
        if req.status_code == 200:
            resp = req.json()
            return Author(resp["data"], self)
        elif req.status_code == 404:
            raise NoContentError(req)
        else:
            raise APIError(req)

    def get_artist(self, uuid: str) -> Author:
        """Gets an artist (named as 'author') with a specific uuid. Alias to get_author()"""
        return self.get_author(uuid)

    def transform_ids(self, obj: str, content: List[int]) -> Dict:
        """Gets uuids from legacy ids."""
        data = {"type": obj, "ids": content}
        post = self.session.post(f"{self.api}/legacy/mapping", data=json.dumps(data),
                                 headers={"Content-Type": "application/json"})
        if post.status_code == 200:
            resp = post.json()
            return {x["data"]["attributes"]["legacyId"]: x["data"]["attributes"]["newId"] for x in resp}
        else:
            raise APIError(post)

    def search(self, obj: str, params: dict,
               limit: int = 100) -> List[Union[Manga, Chapter, Group, Author, Cover, User]]:
        """Searches an object."""
        m = SearchMapping(obj)
        return self._retrieve_pages(f"{self.api}{m.path}", m.object, limit=limit, call_limit=100, params=params)

    def _retrieve_pages(self, url: str, obj: Type[Union[Manga, Chapter, Group, Author, Cover]],
                        limit: int = 0, call_limit: int = 500,
                        params: dict = None) -> List[Union[Manga, Chapter, Group, Author, Cover]]:
        params = params or {}
        data = []
        offset = 0
        resp = None
        remaining = True
        if "limit" in params:
            params.pop("limit")
        if "offset" in params:
            params.pop("offset")
        while remaining:
            p = {"limit": limit if limit <= call_limit and limit != 0 else call_limit, "offset": offset}
            p = {**p, **params}
            req = self.session.get(url, params=p)
            if req.status_code == 200:
                resp = req.json()
                data += [x for x in resp["data"]]
            elif req.status_code == 204:
                pass
            else:
                raise APIError(req)
            if limit and len(data) >= limit:
                break
            if resp is not None:
                remaining = resp["total"] > offset + call_limit
                offset += call_limit
            else:
                remaining = False
            if remaining:
                time.sleep(self.rate_limit)
        if not data:
            raise NoResultsError()
        return [obj(x, self) for x in data]


Client = MangaDex
