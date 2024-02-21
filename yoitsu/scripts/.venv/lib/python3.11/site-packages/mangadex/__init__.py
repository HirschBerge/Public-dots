from .errors import (ApiError, ApiClientError, MangaError, TagError, ChapterError, \
                    AuthorError, ScanlationGroupError, UserError, CustomListError, CoverArtError)

from .url_models import (URLRequest)

from .models import (Manga, Tag, Chapter, User, ScanlationGroup, Author, CustomList, CoverArt)

from .api import (Api)

__author__ = 'Eduardo Ceja'
__version__ = "2.5.2"
__license__ = "MIT"
__copytight__ = "Copyright (c) 2021 Eduardo Ceja"
