class User:
    """Represents a MangaDex User."""
    __slots__ = ("id", "username", "roles", "client")

    def __init__(self, data, client):
        self.id = data.get("id")
        _attrs = data.get("attributes")
        self.username = _attrs.get("username")
        self.roles = _attrs.get("roles", [])
        self.client = client
