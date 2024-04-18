from __future__ import absolute_import
import re #for validating email and prevent spam
from typing import Dict, List, Union
from mangadex import (Manga, Tag, Chapter, User, UserError, ChapterError,
                    Author, ScanlationGroup, CoverArt, CustomList, URLRequest, TagError)
class Api():
    def __init__(self, timeout = 5):
        self.URL = 'https://api.mangadex.org'
        self.bearer = None
        self.timeout = timeout

    def __auth_handler(self, json_payload) -> None:
        url = f"{self.URL}/auth/login"
        auth = URLRequest.request_url(url, "POST", params = json_payload, timeout=self.timeout)
        token = auth['token']['session']
        bearer = {"Authorization" : f"Bearer {token}"}
        self.bearer = bearer

    @staticmethod
    def __parse_manga_params(params : dict) -> dict:
        if "authors" in params:
            temp = params.pop("authors")
            params["authors[]"] = temp
        if "artist" in params:
            temp = params.pop("artist")
            params["artist[]"] = temp
        if "excludedTags" in params:
            temp = params.pop("excludedTags")
            params["excludedTags[]"] = temp
        if "originalLanguage" in params:
            temp = params.pop("originalLanguage")
            params["originalLanguage[]"] = temp
        if "includedTags" in params:
            temp = params.pop("includedTags")
            params["includedTags[]"] = temp
        if "publicationDemographic" in params:
            temp = params.pop("publicationDemographic")
            params["publicationDemographic[]"] = temp
        if "ids" in params:
            temp  = params.pop("ids")
            params["ids[]"] = temp
        if "altTitles" in params:
            temp = params.pop("altTitles")
            params["altTitles[]"] = temp
        if "description" in params:
            temp = params.pop("description")
            params["description[]"] = temp
        if "authors" in params:
            temp = params.pop("authors")
            params["authors[]"] = temp
        if "artists" in params:
            temp = params.pop("artists")
            params["artists[]"] = temp
        if "translatedLanguage" in params:
            temp = params.pop("translatedLanguage")
            params["translatedLanguage[]"] = temp
        if "status" in params:
            params["status[]"] = params.pop("status")
        if "contentRating" in params:
            params["contentRating[]"] = params.pop("contentRating")
        return params

    def get_manga_list(self, **kwargs) -> List[Manga]:
        """
        Search a List of Manga

        Parameters
        -------------
        This parameters may be used by ohter methods
        ### QueryParams:

        limit : `int`
        offset : `int`
        title : `str`
        authors : `List[str]`
        artist : `List[str]`
        year : `int`
        includedTags : `List[Tag.id]`
        includedTagsMode: `str`. Default `"AND"`. Enum: `"AND"` `"OR"`
        excludedTags : `List[Tag.id]`
        exludedTagsMode : `str`. Default `"AND"`, Enum : `"AND"`, `"OR"`
        status : `List[str]`. Items Enum : `"ongoing"`, `"completed"`, `"hiatus"`, `"cancelled"`
        originalLanguage : `List[str]`
        publicationDemographic : `List[str]`. Items Enum: `"shounen"` `"shoujo"` `"josei"` `"seinen"` `"none"`
        ids :  `List[str]`. Limited to 100 per call
        contentRating : `List[str]`. Items Enum : `"safe"` `"suggestive"` `"erotica"` `"pornographic"`
        createdAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        updatedAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS

        Returns
        -------------
        `List[Manga]`. A list of Manga objects

        Raises
        -------------
        `ApiError` `MangaError`
        """
        params = kwargs
        params = Api.__parse_manga_params(params)
        url = f"{self.URL}/manga"
        resp = URLRequest.request_url(url, 'GET', params=params, timeout=self.timeout)
        return Manga.create_manga_list(resp)

    def view_manga_by_id(self, manga_id: str)-> Manga:
        """
        Get a Manga by its id

        Parameters
        ------------
        manga_id: `str`. The manga id

        Returns
        -------------
        `Manga`. A Manga object

        Raises
        ------------
        `ApiError` `MangaError`
        """
        url = f"{self.URL}/manga/{manga_id}"
        resp = URLRequest.request_url(url, "GET", timeout=self.timeout)
        return Manga.MangaFromDict(resp)

    def random_manga(self) -> Manga:
        """
        Get a random Manga

        Returns
        ----------
        `Manga`. A Manga object

        Raises
        ----------
        `ApiError` `MangaError`
        """
        url = f"{self.URL}/manga/random"
        resp = URLRequest.request_url(url, "GET", timeout=self.timeout)
        return Manga.MangaFromDict(resp)

    def create_manga(self, title : str, **kwargs) -> Manga:
        """
        Creates a manga

        Parameters
        -----------
        title : `str`. The manga title

        ### Optional Parameters
        altTitles : `List[Dict[str,str]]`. The alt titles
        description : `Dict[str,str]`. The alt titles in different languages
        authors : `List[str]`. The list of author id's
        artists : `List[str]`. The list of artist id's
        links : `Dict[str,str]`. The links in differents sites (al, ap, bw, mu, etc).
        Please refer to the [documentation](https://api.mangadex.org/docs.html#section/Static-data/Manga-links-data)
        originalLanguage : `str`. The original Language
        lastVolume : `str`. The last volume
        lastChapter : `str`. The last chapter
        publicationDemographic : `str`.
        status : `str`.
        year : `int`.
        contentRating : `str`.
        modNotes : `str`

        Returns
        ------------
        `Manga`. A manga object if `ObjReturn` is set to `True`
        """
        params = self.__parse_manga_params(kwargs)
        url = f"{self.URL}/manga"
        params["title"] = title
        resp = URLRequest.request_url(url, "POST", params=params, headers=self.bearer, timeout = self.timeout)
        return  Manga.MangaFromDict(resp)

    def get_manga_volumes_and_chapters(self, manga_id : str, **kwargs) -> Dict[str, str]:
        """
        Get a manga volumes and chapters

        Parameters
        ------------
        manga_id : `str`. The manga id
        translatedLanguage : `List[str]`

        Returns
        ------------
        `Dict[str, str]`. A dictionary with the volumes and the chapter id's
        """
        params = None
        if "translatedLanguage" in kwargs:
            params = {"translatedLanguage[]" : kwargs["translatedLanguage"]}
        url = f"{self.URL}/manga/{manga_id}/aggregate"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout, params = params)
        return resp["volumes"]

    def update_manga(self, manga_id : str, ObjReturn : bool = False ,**kwargs) -> Manga:
        """
        Updates a manga parameters

        Parameters
        -------------
        ### Required parameters
        manga_id : `str`. The manga id
        version : `int`
        ObjReturn : `bool`. `True` if you want a Manga Object return

        ### Optional Parameters
        title : `Dict[str,str]`. The manga title
        altTitles : `List[Dict[str,str]]`. The alt titles
        description : `Dict[str,str]`. The alt titles in different languages
        authors : `List[str]`. The list of author id's
        artists : `List[str]`. The list of artist id's
        links : `Dict[str,str]`. The links in differents sites (al, ap, bw, mu, etc). Please refer to the [documentation](https://api.mangadex.org/docs.html#section/Static-data/Manga-links-data)
        originalLanguage : `str`. The original Language
        lastVolume : `str`. The last volume
        lastChapter : `str`. The last chapter
        publicationDemographic : `str`.
        status : `str`.
        year : `int`.
        contentRating : `str`.
        modNotes : `str`

        Returns
        ------------
        `Manga`. A manga object if `ObjReturn` is set to `True`
        """
        kwargs = self.__parse_manga_params(kwargs)
        url = f"{self.URL}/manga/{manga_id}"
        resp = URLRequest.request_url(url, "PUT", params=kwargs, headers=self.bearer, timeout=self.timeout)
        if ObjReturn:
            return Manga.MangaFromDict(resp)
        return None

    def delete_manga(self, manga_id : str) -> None:
        """
        Deletes a manga

        Parameters
        ------------
        id : `str`. The manga id
        """
        url = f"{self.URL}/manga{manga_id}"
        URLRequest.request_url(url, "DELETE", headers=self.bearer, timeout= self.timeout)

    def get_manga_read_markes(self, manga_id : str) -> List[Chapter]:
        # this needs a performance update
        """
        A list of Chapter Id's That are marked fro the given manga Id

        Parameters
        ------------
        manga_id : `str`. The Manga id

        Returns
        -------------
        `List[Chapters]`. A list of chapters that are marked as read
        """
        url = f"{self.URL}/manga/{manga_id}/read"
        resp = URLRequest.request_url(url, "GET", timeout= self.timeout ,headers=self.bearer)
        chap_ids = resp["data"]
        return [self.get_chapter(chap) for chap in chap_ids]

    def tag_list(self) -> List[Tag]:
        """
        Get the list of available tags

        Returns
        ------------
        `List[Tag]`. A list of Tag objects

        Raises
        -----------
        `ApiError` `TagError`
        """
        url = f"{self.URL}/manga/tag"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout)
        return Tag.create_tag_list(resp)

    def manga_feed(self, manga_id : str, **kwargs) -> List[Chapter]:
        """
        Get the manga feed

        Parameters
        ------------
        manga_id `str`, Required. The manga id

        ### QueryParams:

        limit : `int`
        offset : `int`
        translatedLanguage : `List[str]`. The translated laguages to query
        createdAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        updatedAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS

        Returns
        -------------
        `List[Chapter]` A list of Chapter Objects

        Raises
        -------------
        `ApiError` `ChapterError`
        """
        kwargs = self.__parse_manga_params(kwargs)
        url = f"{self.URL}/manga/{manga_id}/feed"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout, params = kwargs)
        return Chapter.create_chapter_list(resp)

    @staticmethod
    def __parse_chapter_list_args(params : Dict[str, str]) -> Dict[str,str]:
        if "groups" in params:
            params["groups[]"] =  params.pop("groups")
        if "volume" in params:
            params["volume[]"] = params.pop("volume")
        if "translatedLanguage" in params:
            params["translatedLanguage[]"] = params.pop("translatedLanguage")

        return params

    def chapter_list(self, **kwargs) -> List[Chapter]:
        """
        The list of chapters.
        To get the chpaters of a specific manga the manga parameter must be provided

        Parameters
        -----------
        ### QueryParams:

        limit : `int`
        offset : `int`
        title : `str`
        groups : `List[str]`
        uploader : `str`
        manga : `str`
        volume : `str | List[str]`
        chapter : `str`
        translatedLanguage : `List[str]`
        createdAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        updatedAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        publishAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS

        Returns
        ----------
        `List[Chpater]` A list of Chpater Objects

        Raises
        -------------
        `ApiError` `ChapterError`
        """
        params =  Api.__parse_chapter_list_args(kwargs)
        url = f"{self.URL}/chapter"
        resp = URLRequest.request_url(url, "GET", timeout= self.timeout, params= params)
        return Chapter.create_chapter_list(resp)

    def get_chapter(self, chapter_id: str) -> Chapter:
        """
        Get a Chapter by its id

        Parameters
        ------------
        id : `str` The chapter id

        Returns
        ------------
        `Chapter` A chapter Object

        Raises
        ------------
        `ApiError` `ChapterError`
        """
        url = f"{self.URL}/chapter/{chapter_id}"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout)
        return Chapter.ChapterFromDict(resp)

    def get_author(self, **kwargs) -> List[Author]:
        """
        Get the author List

        Parameters
        ------------
        limit : `int`
        offset : `int`
        ids : List[`str`]. Array of ids
        name : `str`

        Returns
        -----------
        `List[Author]`. A list of Author objects

        Raises
        ------------
        `ApiError` `AuthorError`
        """
        if "ids" in kwargs:
            kwargs["ids[]"] = kwargs.pop("ids")

        url = f"{self.URL}/author"
        resp = URLRequest.request_url(url, "GET", timeout=self.timeout ,params = kwargs)
        return Author.AuthorFromDict(resp)

    def get_author_by_id(self, author_id : str) -> Author:
        """
        Get's an author by its id

        Parameters
        -------------
        author_id `str` The id of the author

        Returns
        ------------
        `Author`

        Raises
        ------------
        `ApiError` `AuthorError`
        """
        url = f"{self.URL}/author/{author_id}"
        resp = URLRequest.request_url(url, "GET", timeout=self.timeout)
        return Author.AuthorFromDict(resp)

    def create_author(self, name : str, version : int, ObjReturn : bool = False) -> Author:
        """
        Creates an Author

        Parameters
        --------------
        name : `str`. The author name
        version : `int`. The version of the author
        ObjReturn : `bool`.  `True` if you want a Author Object return

        Returns
        --------------
        `Author` if `ObjReturn` is `True`
        """
        url = f"{self.URL}/author"
        params = {"name" : name, "version" : version}
        resp = URLRequest.request_url(url, "POST", timeout=self.timeout, params=params, headers=self.bearer)
        if ObjReturn:
            return Author.AuthorFromDict(resp)

    def update_author(self, author_id : str, version : int, name : str = None, ObjReturn : bool = False) -> Author:
        """
        Updates an Author

        Parameters
        -------------
        author_id : `str`. Required. The author id
        version : `int`. Required
        name : `str`.
        ObjReturn : `bool`.  `True` if you want a Author Object return

        Returns
        -----------
        `Author` if `ObjReturn` is `True`
        """
        url = f"{self.URL}/author/{author_id}"
        params  = {"version" : version}
        if name is not None:
            params["name"] = name
        resp = URLRequest.request_url(url, "PUT", timeout = self.timeout, params=params, headers=self.bearer)

        if ObjReturn:
            return Author.AuthorFromDict(resp)

    def delete_author(self, author_id : str) -> None:
        """
        Deletes an author

        Parameters
        ---------------
        author_id : `str`. Required. The author id
        """
        url = f"{self.URL}/author/{author_id}"
        URLRequest.request_url(url, "DELETE", headers=self.bearer, timeout= self.timeout)

    def get_user(self, user_id : str) -> User:
        """
        Get User by its id

        Parameters
        ------------
        user_id `str` The user id

        Returns
        ------------
        `User`

        Raises
        ------------
        `ApiError` \n
        `UserError`
        """
        url = f"{self.URL}/user/{user_id}"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout)
        return User.UserFromDict(resp)

    def scanlation_group_list(self, limit : int = None, offset : int = None,
                            group_ids : List[str] = None, name : str = None) -> List[ScanlationGroup]:
        """
        Get the scanlation groups list

        Parameters
        --------------
        ### Optional

        limit : `int`
        offset : `int`
        group_ids : `List[str]`
        name : `str`

        Returns
        -------------
        `List[ScanlationGroup]`
        """
        url = f"{self.URL}/group"
        params = {}
        if limit is not None:
            params["limit"] = limit
        if offset is not None:
            params["offset"] = offset
        if group_ids is not None:
            params["ids[]"] = group_ids
        if name is not None:
            params["name"] = name

        resp = URLRequest.request_url(url, "GET", timeout = self.timeout ,params=params)
        return ScanlationGroup.create_group_list(resp)

    def login(self, username : str, password : str):
        """
        Method to login into the website

        Parameters
        ---------------
        username `str` your username. \n
        password `str` your password

        Raises
        ---------------
        `ApiError`
        """
        self.__auth_handler(json_payload= {"username" : username, "password" : password})

    def me(self) -> User:
        """
        Get your user info

        Returns
        ---------
        `User`
        """
        url = f"{self.URL}/user/me"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout, headers = self.bearer)
        return User.UserFromDict(resp)

    def get_my_mangalist(self, **kwargs) -> List[Manga]:
        """
        Get the mangas you follow

        Parameters
        -------------
        limit `int`
        offset `int`

        Returns
        -------------
        `List[Manga]`
        """
        url = f"{self.URL}/user/follows/manga"
        resp = URLRequest.request_url(url, "GET", timeout= self.timeout, params = kwargs, headers=self.bearer)
        return Manga.create_manga_list(resp)

    def get_my_followed_groups(self, **kwargs) -> List[ScanlationGroup]:
        """
        Get the Scanlination Groups you follow

        Parameters
        -------------
        limit `int`
        offset `int`
        translatedLanguage : `List[str]`

        Returns
        -------------
        `List[ScanlationGroup]`
        """
        if "translatedLanguage" in kwargs:
            kwargs['translatedLanguage[]'] = kwargs.pop("translatedLanguage")
        url = f"{self.URL}/user/follows/group"
        resp = URLRequest.request_url(url, "GET", timeout = self.timeout,  params=kwargs, headers= self.bearer)
        return ScanlationGroup.create_group_list(resp)

    def get_my_followed_users(self, **kwargs) -> List[User]:
        """
        Get the users you follow

        Parameters
        -------------
        limit : `int`
        offset : `int`

        Returns
        -------------
        `List[User]`
        """
        url = f"{self.URL}/user/follows/user"
        resp = URLRequest.request_url(url, "GET", timeout= self.timeout ,params=kwargs, headers=self.bearer)
        return User.create_user_list(resp)

    def get_manga_reading_status(self, manga_id : Union[str, int]) -> str:
        """
        Get a manga reading status given its id

        Parameters
        ------------
        manga_id : `str`. The manga id

        Returns
        ------------
        `str` The manga reading status
        """
        url = f"{self.URL}/manga/{manga_id}/status"
        resp = URLRequest.request_url(url, "GET", headers=self.bearer, timeout=self.timeout)
        return resp["status"]

    def get_all_manga_reading_status(self, status : str = None) -> Dict[str, str]:
        """
        Get all Manga followed by the user reading status

        Parameters
        ------------
        status : `str`. Optional. Values : `"reading"` `"on_hold"` `"plan_to_read"` `"dropped"` `"re_reading"` `"completed"`

        Returns
        -----------
        `Dict[str,str]` A dictionary with the Manga id and its status
        """
        url = f"{self.URL}/manga/status"
        resp = URLRequest.request_url(url, "GET", params={"status": status}, headers=self.bearer, timeout= self.timeout)
        return resp["statuses"]

    def follow_manga(self, manga_id : Union [str, int]) -> None:
        """
        Follow a manga

        Parameters
        --------------
        manga_id : `str`. The manga id

        Raises
        -------------
        `ApiError`
        """
        url = f"{self.URL}/manga/{manga_id}/follow"
        URLRequest.request_url(url, "POST", headers=self.bearer, timeout=self.timeout)

    def unfollow_manga(self, manga_id : str) -> None:
        """
        Unfollows a Manga

        Parameters
        -------------
        manga_id : `str`. The manga id

        Raises
        -----------
        `ApiError`
        """
        url = f"{self.URL}/manga/{manga_id}/follow"
        URLRequest.request_url(url, "DELETE", headers=self.bearer, timeout=self.timeout)

    def update_manga_reading_status(self, manga_id : str, status : str ) -> None:
        """
        Update the reading stauts of a manga

        Parameters
        -------------
        manga_id : `str`. The manga id.\n
        status : `str`. Values : `"reading"` `"on_hold"` `"plan_to_read"` `"dropped"` `"re_reading"` `"completed"`

        Raises
        -------------
        `ApiError`
        """
        url = f"{self.URL}/manga/{manga_id}/status"
        URLRequest.request_url(url, "POST", params={"status" : status}, headers=self.bearer, timeout=self.timeout)

    def add_manga_to_customlist(self, manga_id : str, listId :str) -> None:
        """
        Adds a manga to a custom list

        Parameters
        --------------
        id : `str`. The manga id.
        listId : `str`. The list id.
        """
        url = f"{self.URL}/{manga_id}/list{listId}"
        URLRequest.request_url(url, "POST", headers=self.bearer, timeout=self.timeout)

    def remove_manga_from_customlist(self, manga_id : str, listId : str) -> None:
        """
        Removes a manga from a custom list

        Parameters
        ------------
        id : `str`. The manga id
        listId : `str`. The list id
        """
        url = f"{self.URL}/manga/{manga_id}/list/{listId}"
        URLRequest.request_url(url, "DELETE", headers=self.bearer, timeout=self.timeout)

    def create_customlist(self, name : str, visibility : str = "public", manga : List[str] = None, version : int = 1) -> None:
        """
        Creates a custom list

        Parameters
        -------------
        ### QueryParams:

        name : `str`. The custom list name
        visibility : `str. The visibility of the custom list
        manga : `List[str]`. List of manga ids
        """
        url = f"{self.URL}/list"
        params = {"name" : name, "version" : version}
        params["visibility"] =  visibility
        params["manga[]"] = manga
        URLRequest.request_url(url, "POST", params=params, timeout=self.timeout)

    def get_customlist(self, custom_list_id : str, **kwargs) -> CustomList:
        """
        Get a custom list by its id

        Parameters
        ------------
        custom_list_id : `str`. The id of the custom list
        limit : int
        offset : int
        translatedLanguage : List[str]
        createdAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        updatedAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        publishAtSince : `str`. Datetime String with the following format YYYY-MM-DDTHH:MM:SS
        Returns
        ------------
        `CustomList`
        """
        url = f"{self.URL}/list/{custom_list_id}"
        resp = URLRequest.request_url(url, "GET", headers=self.bearer,
                                      timeout=self.timeout, params=kwargs)
        return CustomList.ListFromDict(resp["result"])

    def update_customlist(self, custom_list_id : str, **kwargs) -> CustomList:
        """
        Update a custom list

        Parameters
        ------------
        custom_list_id : `str`. The custom list id

        ### QueryParams:
        name : `str`. The custom list name
        visibility : `str`. Values : `"public"` `"private"`

        Returns
        -----------
        `CustomList`
        """
        url = f"{self.URL}/list/{custom_list_id}"
        resp = URLRequest.request_url(url, "PUT", params= kwargs,
                                    headers=self.bearer, timeout=self.timeout)
        return CustomList.ListFromDict(resp["result"])

    def delete_customlist(self, customlist_id : str) -> None:
        """
        Deletes a Custom List

        Parameters
        ------------
        customlist_id : `str`. The custom list id
        """
        url = f"{self.URL}/list{customlist_id}"
        URLRequest.request_url(url, "DELETE", headers=self.bearer, timeout=self.timeout)

    def get_my_customlists(self, **kwargs) -> List[CustomList]:
        """
        Get my custom lists

        Parameters
        ------------
        ### QueryParams:
        limit : `int`. The limit of custom lists to return
        offset : `int`. The amout of offset

        Returns
        ----------
        `List[CustomList]`
        """
        url = f"{self.URL}/user/list"
        resp = URLRequest.request_url(url, "GET", params=kwargs, headers=self.bearer, timeout=self.timeout)
        return CustomList.create_customlist_list(resp)

    def get_user_customlists(self, user_id : str, **kwargs) -> List[CustomList]:
        """
        Get a user's custom list. This will list only public custom lists

        Parameters
        ------------
        user_id : `str`. the User id

        ### QueryParams:
        limit : `int`. The limit of custom lists to return
        offset : `int`. The amout of offset

        Returns
        ----------
        `List[CustomList]`
        """
        url = f"{self.URL}/user/{user_id}/list"
        resp = URLRequest.request_url(url, "GET", params=kwargs, headers=self.bearer, timeout=self.timeout)
        return CustomList.create_customlist_list(resp)

    @staticmethod
    def __parse_coverart_params(params : Dict[str,str]) -> Dict[str, str]:
        if "manga" in params:
            params["manga[]"] = params.pop("manga")
        if "ids" in params:
            params["ids[]"] = params.pop("ids")
        if "uploaders" in params:
            params["uploaders[]"] = params.pop("uploaders")

        return params
    def get_coverart_list(self, **kwargs):
        """
        Get the list of cover arts (like the manga feed)

        Optional parameters
        -------------------------
        manga : List[str]. Manga ids
        ids : List[str]. Cover ids
        uploaders : List[str]. User ids
        """
        params = Api.__parse_coverart_params(kwargs)
        url = f"{self.URL}/cover"
        resp = URLRequest.request_url(url, "GET", params = params, timeout= self.timeout)
        return CoverArt.createCoverImageList(resp)

    def get_cover(self, coverId : str) -> CoverArt:
        """
        Gets a cover image

        Parameters
        --------------
        coverId : `str`. The cover id

        Returns
        --------------
        `CoverArt`. A cover art object
        """
        url = f"{self.URL}/cover/{coverId}"
        resp = URLRequest.request_url(url, "GET", timeout=self.timeout)
        return CoverArt.CoverFromDict(resp)

    def upload_cover(self, manga_id : str, filename : str, ObjReturn : bool = False) -> Union[CoverArt, None]:
        """
        Uploads a cover

        Parameters
        --------------
        manga_id : `str`
        filename : `str`
        ObjReturn : `bool`

        Returns
        -------------
        `CoverArt` if `ObjReturn` set to `True`
        """
        url = f"{self.URL}/cover/{manga_id}"
        with open(filename, 'rb') as f:
            file = f.read()

        resp = URLRequest.request_url(url, "POST", params = {"file" : file}, headers= self.bearer, timeout=self.timeout)
        return CoverArt.CoverFromDict(resp) if ObjReturn else None

    def edit_cover(self, coverId : str, description : str, volume : str = None, version : int = None, ObjReturn : bool = False) -> Union[None, CoverArt]:
        """
        Edit a cover parameters

        Parameters
        ------------
        coverId : `str`. The coverId
        description : `str`. The cover description
        volume : `str`. The volume representing the volume
        version : `int`. The version of the cover
        ObjReturn : `bool`. Default `False`. If set to `True`, it will return a CoverArt

        Returns
        -----------
        `CoverArt` if `ObjReturn` set to `True`
        """
        if version is None:
            raise ValueError("Version cannot be null")

        params = {"volume" : volume, "version" : version}
        if description is not None:
            params["description"] = description

        url = f"{self.URL}/cover/{coverId}"
        resp = URLRequest.request_url(url, "PUT", params=params, headers=self.bearer, timeout=self.timeout)
        return CoverArt.CoverFromDict(resp) if ObjReturn else None

    def delete_cover(self, coverId : Union[str , CoverArt]):
        """
        Deletes a cover

        Params
        -----------
        coverId : `str` | `CoverArt`. The cover id or the cover object
        """
        if not coverId:
            raise ValueError("coverId cannot be empty")
        if isinstance(coverId, CoverArt):
            coverId = coverId.id
        url = f"{self.URL}/cover/{coverId}"
        URLRequest.request_url(url, "DELETE", headers= self.bearer, timeout=self.timeout)

    def create_account(self, username : str, password : str, email : str, ObjReturn : bool = False) -> Union[User, None]:
        """
        Creates an account

        Parameters
        ---------------
        username : `str`.
        password : `str`.
        email : `str`.
        ObjReturn : `bool`.

        Returns
        -------------
        `User` if `ObjReturn` set to `True`
        """
        url = f"{self.URL}/account/create"
        email_regex = '^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$' # regular expression for email
        if re.search(email_regex, email) is None:
            raise ValueError("The email provided is not valid")

        if len(password) < 8:
            raise ValueError("Password must have at least 8 characters")
        params = {"username" : username, "password" : password, "email" : email}
        resp = URLRequest.request_url(url, "POST", timeout=self.timeout, params=params)
        return User.UserFromDict(resp["data"]) if ObjReturn else None

    def activate_account(self, code : str):
        """
        Handles the activation code for the account creation

        Parameters
        ------------
        code : `str`. The activation code sent to the email provided
        """
        url = f"{self.URL}/account/activate/{code}"
        URLRequest.request_url(url, "GET", timeout=self.timeout)

    def resend_activation_code(self, email : str):
        """
        Resends the activation code to another email

        Parameters
        -----------------
        email : `str`.
        """
        email_regex = '^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$' # regular expression for email
        if re.search(email_regex, email) is not None:
            raise ValueError("The email provided is not valid")
        params = {"email" : email}
        url = f"{self.URL}/account/activate/resend"
        URLRequest.request_url(url, "POST", timeout=self.timeout, params=params)

    def recover_account(self, email : str):
        """
        Recover an existing account

        Parameters
        --------------
        email : `str`.
        """
        email_regex = '^(\w|\.|\_|\-)+[@](\w|\_|\-|\.)+[.]\w{2,3}$'
        if re.search(email_regex, email) is None:
            raise ValueError("The email provided is not valid")
        params = {"email" : email}
        url = f"{self.URL}/account/recover"
        URLRequest.request_url(url, "POST", self.timeout, params)

    def complete_account_recover(self, code : str, newPassword : str):
        """
        Completes the account recover process

        Parameters
        --------------
        code : `str`. The code sended to the email given in `recover_account`
        newPassword : `str`. The new password for the account
        """
        if len(newPassword) < 8:
            raise ValueError("Password must have at least 8 characters")
        url = f"{self.URL}/account/recover/{code}"
        params = {"newPassword" : newPassword}
        URLRequest.request_url(url, "POST", timeout=self.timeout, params=params)
