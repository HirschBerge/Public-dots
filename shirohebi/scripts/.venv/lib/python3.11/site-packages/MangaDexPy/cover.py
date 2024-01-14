class Cover:
    """Represents a MangaDex Cover."""
    __slots__ = ("id", "desc", "volume", "file", "parent_manga", "url", "url_512", "url_256", "created_at",
                 "updated_at", "client")

    def __init__(self, data, client):
        self.id = data.get("id")
        _attrs = data.get("attributes")
        _rel = data.get("relationships", [])
        self.desc = _attrs.get("description")
        self.volume = _attrs.get("volume")
        self.file = _attrs.get("fileName")
        self.parent_manga = next((x["id"] for x in _rel if x["type"] == "manga"), None)
        self.url = f"https://uploads.mangadex.org/covers/{self.parent_manga}/{self.file}"
        self.url_512 = f"{self.url}.512.jpg"
        self.url_256 = f"{self.url}.256.jpg"
        self.created_at = _attrs.get("createdAt")
        self.updated_at = _attrs.get("updatedAt")
        self.client = client
