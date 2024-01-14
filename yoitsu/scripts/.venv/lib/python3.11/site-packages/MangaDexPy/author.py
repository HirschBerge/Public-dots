class Author:
    """Represents a MangaDex Author or Artist."""
    __slots__ = ("id", "name", "image", "bio", "created_at", "updated_at", "client")

    def __init__(self, data, client):
        self.id = data.get("id")
        _attrs = data.get("attributes")
        self.name = _attrs.get("name")
        self.image = _attrs.get("imageUrl")
        self.bio = _attrs.get("biography")
        self.created_at = _attrs.get("createdAt")
        self.updated_at = _attrs.get("updatedAt")
        self.client = client
