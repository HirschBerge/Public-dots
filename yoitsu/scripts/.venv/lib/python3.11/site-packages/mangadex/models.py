import datetime
from dateutil.parser import parse
from typing import Dict, List
from mangadex import (MangaError, TagError, ChapterError, AuthorError, 
                    ScanlationGroupError, UserError, CustomListError, CoverArtError, URLRequest)

class Manga():
    def __init__(self) -> None:

        self.manga_id : str = ""
        self.title : Dict[str, str] = {}
        self.altTitles : Dict[str, str] = {}
        self.description : Dict[str, str] = {}
        self.isLocked : bool = False
        self.links : Dict[str, str] = {}
        self.originalLanguage : str = ""
        self.lastVolume : str = ""
        self.lastChapter : str = ""
        self.publicationDemographic : str = ""
        self.status : str = ""
        self.year : int = 0
        self.contentRating : str = ""
        self.tags : List[str]  = []
        self.version = 1
        self.createdAt : datetime = ""
        self.updatedAt : datetime = ""
        self.authorId : List[str] = []
        self.artistId : List[str] = []
        self.coverId : str = ""

    @classmethod
    def MangaFromDict(cls, data : dict):

        try:
            data = data["data"]
        except (TypeError, KeyError):
            pass

        if data["type"] != 'manga' or not data:
            raise MangaError(data=data, message="The data probvided is not a Manga")

        attributes = data["attributes"]

        manga = cls()

        manga.manga_id = data["id"]
        manga.title = attributes["title"]
        manga.altTitles = attributes["altTitles"]
        manga.description = attributes["description"]
        try:
            manga.isLocked = attributes["isLocked"]
        except KeyError:
            pass
        
        manga.links = attributes["links"]
        manga.originalLanguage = attributes["originalLanguage"]
        manga.lastVolume = attributes["lastVolume"]
        manga.lastChapter = attributes["lastChapter"]
        manga.publicationDemographic = attributes["publicationDemographic"]
        manga.status = attributes["status"]
        manga.year = attributes["year"]
        manga.contentRating = attributes["contentRating"]
        manga.tags = Tag.create_tag_list(attributes["tags"])
        manga.createdAt = parse(attributes["createdAt"])
        manga.updatedAt = parse(attributes["updatedAt"])

        for elem in data["relationships"]:
            if elem['type'] == 'author':
                manga.authorId.append(elem['id'])
            elif elem['type'] == 'artist':
                manga.artistId.append(elem['id'])
            elif elem['type'] == 'cover_art':
                manga.coverId = elem['id']

        return manga

    @staticmethod
    def create_manga_list(resp) -> List['Manga']:
        resp = resp["data"]
        manga_list = []
        for elem in resp:
            manga_list.append(Manga.MangaFromDict(elem))
        return manga_list

    def __eq__(self, other : 'Manga') -> bool:
        my_vals = [self.manga_id, self.title, self.createdAt, self.authorId]
        other_vals = [other.manga_id, other.title, other.createdAt, other.authorId]
        return all((me == other for me, other in zip(my_vals, other_vals)))

    def __ne__(self, other: object) -> bool:
        return not self.__eq__(other)

    def __repr__(self) -> str:
        temp1 = f"Manga(id = {self.manga_id}, title = {self.title}, altTitles = {self.altTitles}, description = {self.description}, isLocked = {self.isLocked}, links = {self.links}, originalLanguage = {self.originalLanguage} \n"
        temp2 = f"lastVolume = {self.lastVolume}, lastChapter = {self.lastChapter}, publicationDemographic = {self.publicationDemographic}, status = {self.status}, year = {self.year}, contentRating = {self.contentRating} \n"
        temp3 = f"createdAt = {self.createdAt}, uploadedAt = {self.updatedAt}), authorId = {self.authorId}, artistId = {self.artistId}, coverId = {self.coverId}"
        return temp1 + temp2 + temp3

class Tag():
    def __init__(self) -> None:
        self.id : str= ""
        self.name : Dict[str, str] = {}
        self.description : str = ""
        self.group : str = ""

    @classmethod
    def TagFromDict(cls, data : dict) -> 'Tag':
        tag = cls()
        try:
            data = data["data"]
        except KeyError:
            pass

        if data["type"] != 'tag' or not data:
            raise TagError(data=data, message="The data provided is not a Tag")

        attributes = data["attributes"]

        tag.id = data["id"]
        tag.name = attributes["name"]
        tag.description = attributes["description"]
        tag.group = attributes["group"]

        return tag

    @staticmethod
    def create_tag_list(resp) -> List['Tag']:
        tag_list = []
        try:
            resp = resp["data"]
        except (TypeError, KeyError):
            pass

        for tag in resp:
            tag_list.append(Tag.TagFromDict(tag))
        return tag_list

    def __eq__(self, other : 'Tag') -> bool:
        my_vals = [self.id, self.name]
        other_vals = [other.id, other.name]
        return all((me == other for me,other in zip(my_vals, other_vals)))

    def __ne__(self, other: 'Tag') -> bool:
        return not self.__eq__(other)

    def __repr__(self) -> str:
        return f"Tag(id = {self.id}, name = {self.name})"

class Chapter():
    def __init__(self) -> None:
        self.id : str = ""
        self.title : str = ""
        self.volume : str = ""
        self.chapter : float = None
        self.Mangaid : str = ""
        self.scanlation_group_id : str = ""
        self.translatedLanguage : str= ""
        self.hash : str = ""
        self.data : List[str] = []
        self.uploader : str = ""
        self.createdAt : datetime = ""
        self.updatedAt : datetime = ""
        self.publishAt : datetime = ""
        

    @classmethod
    def ChapterFromDict(cls, data) -> 'Chapter':
        chapter = cls()
        try:
            data = data["data"]
        except KeyError:
            pass

        if data["type"] != 'chapter' or not data:
            raise ChapterError(data = data, message="The data provided is not a Chapter")

        attributes = data["attributes"]

        chapter.id = data["id"]
        chapter.title = attributes["title"]
        chapter.volume = attributes["volume"]
        chapter.chapter = float(attributes["chapter"]) if attributes['chapter'] is not None else None
        chapter.translatedLanguage = attributes["translatedLanguage"]
        # chapter.hash = attributes["hash"]
        # chapter.data = attributes["data"]
        chapter.publishAt = parse(attributes["publishAt"])
        chapter.createdAt = parse(attributes["createdAt"])
        chapter.updatedAt = parse(attributes["updatedAt"])
        chapter.scanlation_group_id = data["relationships"][0]["id"]
        chapter.Mangaid = data["relationships"][1]["id"]
        try:
            chapter.uploader = data["relationships"][2]["id"]
        except IndexError:
            pass

        return chapter

    def fetch_chapter_images(self) -> List[str]: #maybe make this an async function?
        """
        Get the image links for the chapter

        Returns
        -----------
        `List[str]`. A list with the links with the chapter images

        NOTE: There links are valid for 15 minutes until you need to renew the token

        Raises
        -----------
        `ApiError`
        """
        url = f"https://api.mangadex.org/at-home/server/{self.id}"
        image_server_url = URLRequest.request_url(url, "GET", timeout=5)
        self.hash = image_server_url["chapter"]["hash"]
        self.data = image_server_url["chapter"]["data"]
        image_server_url = image_server_url["baseUrl"].replace("\\", "")
        image_server_url = f"{image_server_url}/data"
        image_urls = []
        for filename in self.data:
            image_urls.append(f"{image_server_url}/{self.hash}/{filename}")

        return image_urls

    @staticmethod
    def create_chapter_list(resp) -> List['Chapter']:
        resp = resp["data"]
        chap_list = []
        for elem in resp:
            chap_list.append(Chapter.ChapterFromDict(elem))
        return chap_list

    def __eq__(self, other: 'Chapter') -> bool:
        my_vals = [self.id, self.Mangaid, self.chapter]
        other_vals = [other.id, other.Mangaid, other.chapter]
        return all((me == other for me,other in zip(my_vals, other_vals)))

    def __ne__(self, other: 'Chapter') -> bool:
        return not self.__eq__(other)
    
    def __repr__(self) -> str:
        temp1 =  f"Chapter(id = {self.id}, title = {self.title}, volume = {self.volume}, chapter = {self.chapter}, translatedLanguage = {self.translatedLanguage}, hash = {self.hash} \n"
        temp2 = f"data = List[filenames], publishAt = {self.publishAt}, createdAt = {self.createdAt}, uploadedAt = {self.updatedAt}, scanlation_group_id = {self.scanlation_group_id}, Mangaid = {self.Mangaid}, uploader = {self.uploader})"
        return temp1 + temp2

class User():
    def __init__(self) -> None:
        self.id : str = ""
        self.username :str = ""
    @classmethod
    def UserFromDict(cls, data) -> 'User':
        if "data" in data:
            data = data["data"]

        if data["type"] != "user" or not data:
            raise UserError(data = data, message="The data provided is not a User")
        
        attributes = data["attributes"]

        user = cls()
        user.id = data["id"]
        user.username = attributes["username"]

        return user

    @staticmethod    
    def create_user_list(resp) -> List['User']:
        resp = resp["data"]
        user_list = []
        for elem in resp:
            user_list.append(User.UserFromDict(elem))
        return user_list

    def __eq__(self, other: 'User') -> bool:
        my_vals = [self.id, self.username]
        other_vals = [other.id, other.username]
        return all((me == other for me,other in zip(my_vals, other_vals)))

    def __ne__(self, other: 'User') -> bool:
        return not self.__eq__(other)

    def __repr__(self) -> str:
        return f"User(id = {self.id}, username = {self.username})"

class Author():
    def __init__(self) -> None:
        self.id : str = ""
        self.name : str = ""
        self.imageUrl : str = ""
        self.bio : Dict[str,  str] = {}
        self.createdAt : datetime = ""
        self.updatedAt : datetime = ""
        self.mangas : List[str] = []
    @classmethod
    def AuthorFromDict(cls, data):

        try:
            data = data["data"]
        except KeyError:
            pass

        if data["type"] != "author" or not data:
            raise AuthorError(data = data, message= f"The data provided is not Author is : {data['type']}")

        author = cls()

        attributes = data["attributes"]

        author.id = data["id"]
        author.name = attributes["name"]
        author.imageUrl = attributes["imageUrl"]
        author.bio = attributes["biography"]
        author.createdAt = parse(attributes["createdAt"])
        author.updatedAt = parse(attributes["updatedAt"])
        author.mangas =  [manga["id"] for manga in data["relationships"] if manga["type"] == "manga"] # better keep it like this to not consume computing time

        return author

    @staticmethod
    def create_authors_list(resp) -> List['Author']:
        resp = resp["data"]
        authors_list = []
        for elem in resp:
            authors_list.append(Author.AuthorFromDict(elem))
        return authors_list

    def __eq__(self, other: 'Author') -> bool:
        my_vals = [self.id ,self.name]
        other_vals = [other.id, other.name]
        return all((me == other for me,other in zip(my_vals, other_vals)))

    def __ne__(self, other: 'Author') -> bool:
        return not self.__eq__(other)

    def __repr__(self) -> str:
        return f"Author(id = {self.id}, name = {self.name}, imageUrl = {self.imageUrl}, createdAt = {self.createdAt}, updatedAt = {self.updatedAt})"

class ScanlationGroup():
    def __init__(self) -> None:
        self.id : str = ""
        self.name : str = ""
        self.leader : User = None
        self.createdAt : datetime = None
        self.updatedAt : datetime = None

    @classmethod
    def ScanlationFromDict(cls, data) -> 'ScanlationGroup':

        if data["type"] != "scanlation_group" or not data:
            raise ScanlationGroupError(data,"The data provided is not an scanlation group")

        scan_group = cls()

        attributes = data["attributes"]
        relationships = data["relationships"]
        scan_group.id = data["id"]
        scan_group.name = attributes["name"]

        leader = User()
        for elem in relationships:
            try:
                if elem["type"] == "leader":
                    leader.id = elem["id"]
                    break
            except KeyError:
                continue

        scan_group.leader =  leader

        scan_group.createdAt = parse(attributes["createdAt"])
        scan_group.updatedAt = parse(attributes["updatedAt"])

        return scan_group

    @staticmethod
    def create_group_list(resp) -> List['ScanlationGroup']:
        resp = resp["data"]
        group_list = []
        for elem in resp:
            group_list.append(ScanlationGroup.ScanlationFromDict(elem))
        return group_list

    def __eq__(self, other: 'ScanlationGroup') -> bool:
        my_vals = []
        other_vals = []
        return all((me == other for me,other in zip(my_vals, other_vals)))

    def __ne__(self, other: 'ScanlationGroup') -> bool:
        return not self.__eq__(other)
        
    def __repr__(self) -> str:
        return f"ScanlationGroup(id = {self.id}, name = {self.name}, leader = {self.leader}, createdAt = {self.createdAt}, updatedAt = {self.updatedAt})"

class CustomList():
    def __init__(self) -> None:
        self.id : str = ""
        self.name : str = ""
        self.visibility : str = ""
        self.owner : str = ""
        self.mangas : List[str] = []

    @classmethod
    def ListFromDict(cls, data):
        if data["type"] != "custom_list" or not data:
            raise CustomListError(data,"The data provided is not a Custom List")

        custom_list = cls()

        attributes = data["attributes"]
        relationships = data["relationships"]

        custom_list.id = data["id"]
        custom_list.name = attributes["name"]
        custom_list.visibility = attributes["visibility"]
        for elem in relationships:
            if elem["type"] == "user":
                custom_list.owner = elem["id"]
            elif elem["type"] == "manga":
                custom_list.mangas.append(elem["id"])

        return custom_list

    @staticmethod
    def create_customlist_list(resp) -> List['CustomList']:
        resp = resp["data"]
        custom_lists = []
        for elem in resp:
            custom_lists.append(CustomList.ListFromDict(elem))
        return custom_lists

    def __repr__(self) -> str:
        return f"CustomList(id = {self.id}, name = {self.name}, visibility = {self.visibility}, owner = {self.owner}, Manga = List[Manga])"

class CoverArt():
    def __init__(self) -> None:
        self.id : str = ""
        self.volume : str = None
        self.fileName : str = ""
        self.description : str = None
        self.createdAt : datetime = None
        self.updatedAt : datetime = None
        self.mangaId : str = None

    @classmethod
    def CoverFromDict(cls, data) -> 'CoverArt':

        try:
            data = data["data"]
        except (KeyError, TypeError):
            pass

        if data["type"] != "cover_art" or not data:
            raise CoverArtError(data, "The data provided is not a Custom List")

        cover = cls()

        attributes = data["attributes"]

        cover.id = data["id"]
        cover.volume = attributes["volume"]
        cover.fileName = attributes["fileName"]
        cover.description = attributes["description"]
        cover.createdAt = parse(attributes["createdAt"])
        cover.updatedAt = parse(attributes["updatedAt"])
        cover.mangaId = data["relationships"][0]["id"]

        return cover
    
    def fetch_cover_image(self, quality : str = "source") -> str:
        """
        Returns the url of a cover art

        Parametes
        -------------
        quality : `str`. Values : `medium`,  `small`

        Returns
        -----------
        url : `str`. The cover url
        """
        url = f"https://uploads.mangadex.org/covers/{self.mangaId}/{self.fileName}"

        if quality == "medium":
            url = f"{url}.512.jpg"
        elif quality == "small":
            url = f"{url}.256.jpg"

        return url

    @staticmethod
    def createCoverImageList(resp) -> List['CoverArt']:
        resp = resp["data"]
        coverimage_list = []
        for elem in resp:
            coverimage_list.append(CoverArt.CoverFromDict(elem))
        return coverimage_list

    def __repr__(self) -> str:
        return f"CoverArt(id = {self.id}, mangaId = {self.mangaId}, volume = {self.volume}, \
                fileName = {self.fileName}, description = {self.description}, \
                createdAt = {self.createdAt}, updatedAt = {self.updatedAt})"