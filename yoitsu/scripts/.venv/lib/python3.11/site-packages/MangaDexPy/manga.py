class Manga:
    """Represents a MangaDex Manga."""
    __slots__ = ("id", "title", "titles", "desc", "links", "language", "last_volume", "last_chapter",
                 "type", "status", "year", "content", "tags", "created_at", "updated_at", "author", "artist", "cover",
                 "client")

    def __init__(self, data, client):
        self.id = data.get("id")
        _attrs = data.get("attributes")
        _rel = data.get("relationships", [])
        self.title = _attrs.get("title")
        self.titles = _attrs.get("altTitles")
        self.desc = _attrs.get("description")
        self.links = _attrs.get("links")
        self.language = _attrs.get("originalLanguage").lower()
        self.last_volume = _attrs.get("lastVolume")
        self.last_chapter = _attrs.get("lastChapter")
        self.type = _attrs.get("publicationDemographic")
        self.status = _attrs.get("status")
        self.year = _attrs.get("year")
        self.content = _attrs.get("contentRating")
        self.tags = [MangaTag(x) for x in _attrs.get("tags")]
        self.created_at = _attrs.get("createdAt")
        self.updated_at = _attrs.get("updatedAt")
        try:
            _author = [x["attributes"] for x in _rel if x["type"] == "author"]
            from .author import Author
            self.author = [Author(x, client) for x in _rel if x["type"] == "author"]
        except (IndexError, KeyError):
            self.author = [x["id"] for x in _rel if x["type"] == "author"]
        try:
            _artist = [x["attributes"] for x in _rel if x["type"] == "artist"]
            from .author import Author
            self.artist = [Author(x, client) for x in _rel if x["type"] == "artist"]
        except (IndexError, KeyError):
            self.artist = [x["id"] for x in _rel if x["type"] == "artist"]
        try:
            _cover = [x["attributes"] for x in _rel if x["type"] == "cover_art"]
            from .cover import Cover
            _related_cover = next((x for x in _rel if x["type"] == "cover_art"), None)
            if _related_cover is not None:
                _related_cover["relationships"] = [{"type": "manga", "id": self.id}]
                _related_cover = Cover(_related_cover, client)
            self.cover = _related_cover
        except (IndexError, KeyError):
            self.cover = next((x["id"] for x in _rel if x["type"] == "cover_art"), None)
        self.client = client

    def get_chapters(self, params=None, includes=None):
        includes = self.client.constants.get("INCLUDE_ALL") if not includes else includes
        return self.client.get_manga_chapters(self, params, includes)

    def get_covers(self, params=None):
        return self.client.get_manga_covers(self, params)


class MangaTag:
    """Represents a MangaDex Manga Tag."""
    __slots__ = ("id", "name")

    def __init__(self, data):
        self.id = data.get("id")
        self.name = data.get("attributes").get("name")
