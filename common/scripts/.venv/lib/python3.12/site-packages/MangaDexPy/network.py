import time


class NetworkChapter:
    """Represents a link between the MD@H Network and a Chapter."""
    __slots__ = ("valid_thru", "parent_chapter", "node_url", "hash", "files", "files_redux", "pages", "pages_redux",
                 "client")

    def __init__(self, data, parent_chapter, client):
        self.valid_thru = int(time.time()) + 900
        self.parent_chapter = parent_chapter
        self.node_url = data.get("baseUrl")
        _ch = data.get("chapter")
        self.hash = _ch.get("hash")
        self.files = _ch.get("data")
        self.files_redux = _ch.get("dataSaver")
        self.pages = [f"{self.node_url}/data/{self.hash}/{x}" for x in self.files]
        self.pages_redux = [f"{self.node_url}/data-saver/{self.hash}/{x}" for x in self.files_redux]
        self.client = client

    def report(self, url, success, cache_header, req_bytes, req_duration):
        return self.client.network_report(url, success, cache_header, req_bytes, req_duration)
