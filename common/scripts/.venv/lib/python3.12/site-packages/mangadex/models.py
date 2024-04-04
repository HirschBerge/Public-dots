from urllib3 import PoolManager
import urllib3
from aiohttp import ClientSession
from json import loads
from asyncio import get_event_loop

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning) # begone warnings

async_loop = get_event_loop()

async_sessions = []

class __ModuleInitializer():
  def __init__(self):
    pass
  def __del__(self):
    for session in async_sessions:
      async_loop.run_until_complete(session.close())
    async_loop.close()
    # This is a temporary solution until I figure out aiohttp

__module_init = __ModuleInitializer()

class Manga():
  def __init__(self, manga_id, session=None, async_session=None, **kwargs):
    if not session:
      session = PoolManager()
    if not async_session:
      async_session = ClientSession()
      async_sessions.append(async_session)
    self.id = manga_id
    self.session = session
    self.async_session = async_session
    self.populated = False if not kwargs else True
    self.valid = True
    self.url = 'https://mangadex.org/api/manga/{}'.format(self.id)
    self.attr_list = ['session', 'async_session', 'id', 'populated', 'valid', 'url']

    for attr in kwargs.keys():
      setattr(self, 'cached_'+attr, kwargs[attr])
      self.attr_list.append('cached_'+attr)

  async def async_populate(self):
    async with self.async_session.get(self.url) as response:
      text = await response.text()
    self.json = loads(text)
    self.status = self.json['status']
    self.attr_list.append('status')

    if self.json['status'] == 'OK':
      self.valid = True
      self.populated = True

      self.chapters = self.json['chapter']
      self.attr_list.append('chapters')

      for attr in self.json['manga'].keys():
        setattr(self, attr, self.json['manga'][attr])
        self.attr_list.append(attr)
      
      return self
    else:
      self.valid = False
      self.populated = True
      return self
    
  
  def populate(self):
    self.json = loads(self.session.request('GET',self.url).data)
    self.status = self.json['status']
    self.attr_list.append('status')

    if self.json['status'] == 'OK':
      self.valid = True
      self.populated = True

      self.chapters = self.json['chapter']
      self.attr_list.append('chapters')

      for attr in self.json['manga'].keys():
        setattr(self, attr, self.json['manga'][attr])
        self.attr_list.append(attr)
      
      return self
    else:
      self.valid = False
      self.populated = True
      return self
  
  def get_chapters(self):
    if self.valid and self.populated:
      chapters = []
      for chapter_id in self.chapters.keys():
        chapters.append(Chapter(chapter_id, session=self.session, async_session=self.async_session, **self.chapters[chapter_id]))
      return chapters
    elif self.valid and not self.populated:
      self.populate()
      if self.valid:
        chapters = []
      for chapter_id in self.chapters.keys():
        chapters.append(Chapter(chapter_id, session=self.session, async_session=self.async_session, **self.chapters[chapter_id]))
        return chapters
      else:
        return None
    else:
      return None

class Chapter():
  def __init__(self, chapter_id, session=None, async_session=None, **kwargs):
    if not session:
      session = PoolManager()
    if not async_session:
      async_session = ClientSession()
      async_sessions.append(async_session)
    self.id = chapter_id
    self.session = session
    self.async_session = async_session
    self.populated = True if kwargs.get('server') and kwargs.get('hash') and kwargs.get('page_array') else False
    self.valid = True
    self.url = 'https://mangadex.org/api/chapter/{}'.format(self.id)
    self.attr_list = ['session','async_session', 'id', 'populated', 'valid', 'url']

    for attr in kwargs.keys():
      setattr(self, 'cached_'+attr, kwargs[attr])
      self.attr_list.append('cached_'+attr)
    
    if self.populated:
      setattr(self,'server',kwargs['server'])
      setattr(self,'hash',kwargs['hash'])
      setattr(self,'page_array',kwargs['page_array'])
  
  async def async_populate(self):
    async with self.async_session.get(self.url) as response:
      text = await response.text()
    self.json = loads(text)

    for attr in self.json.keys():
      setattr(self, attr, self.json[attr])
      self.attr_list.append(attr)
    if 'page_array' in self.attr_list:
      self.pages = self.page_array
      self.attr_list.append('pages')

    if self.status != 'OK':
      self.valid = False
    
    self.populated = True

    return self
  
  def populate(self):
    self.json = loads(self.session.request('GET',self.url).data)

    for attr in self.json.keys():
      setattr(self, attr, self.json[attr])
      self.attr_list.append(attr)
    if 'page_array' in self.attr_list:
      self.pages = self.page_array
      self.attr_list.append('pages')

    if self.status != 'OK':
      self.valid = False
    
    self.populated = True

    return self
  
  def get_pages(self):
    if self.valid and self.populated:
      return [Page(self.server, self.hash, page, session=self.session, async_session=self.async_session) for page in self.pages]
    elif self.valid and not self.populated:
      self.populate()
      if self.valid:
        return [Page(self.server, self.hash, page, session=self.session, async_session=self.async_session) for page in self.pages]
      else:
        return None
    else:
      return None

class Page():
  def __init__(self, page_server, chapter_hash, page_filename, session=None, async_session=None, **kwargs):
    if not session:
      session = PoolManager()
    if not async_session:
      async_session = ClientSession()
      async_sessions.append(async_session)
    self.session = session
    self.async_session = async_session
    self.page_server = page_server
    self.chapter_hash = chapter_hash
    self.page_filename = page_filename
    self.url = f'{page_server}{chapter_hash}/{page_filename}'
    self.attr_list = ['url', 'page_server', 'chapter_hash', 'page_filename', 'session', 'async_session']
    
    for attr in kwargs.keys():
      setattr(self, 'cached_'+attr, kwargs[attr])
      self.attr_list.append('cached_'+attr)
  
  def download(self, filename=None):
    if not filename:
      filename = self.page_filename
    r = self.session.request('GET',self.url, preload_content=False)
    if r.status == 200:
      with open(filename, 'wb') as f:
        for chunk in r.stream(32):
          f.write(chunk)
    r.release_conn()
  
  async def async_download(self, filename=None):
    if not filename:
      filename = self.page_filename
    async with self.async_session.get(self.url) as r:
      if r.status_code == 200:
        with open(filename, 'wb') as f:
          f.write(await r.read()) # Do you really want another dependency?
  