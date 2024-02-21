from MangaDexPy import APIError, Chapter, Manga
import os
import time
import threading
from requests import exceptions as rex
from pathlib import Path
net_table = {}

# This script is provided 'as-is', as an example for library usage.
# Overriding it in your code is strongly recommended to gain control on it and fine-tune its behavior.


def page_name_to_integer(page, pages_total):
    num = ''.join([x for x in page.split("-")[0] if x.isdigit()])
    leading_zeros = len(str(pages_total)) - len(num)
    final_name = ""
    for _ in range(leading_zeros):
        final_name += "0"
    final_name += num + Path(page).suffix
    return final_name


def dl_page(net, page, pages_total, path):
    """Helper for dl_chapter to download pages with."""
    try:
        with net.client.session.get(page) as p:
            name = page_name_to_integer(page.rsplit("/", 1)[1], pages_total)
            with open(str(Path(path + "/" + name)), "wb") as f:
                f.write(p.content)
            success = True if p.status_code <= 400 else False
            try:
                cached = True if p.headers["x-cache"] == "HIT" else False
            except KeyError:  # No cache header returned: the client is at fault
                cached = False
            try:
                net.report(page, success, cached, len(p.content), int(p.elapsed.microseconds/1000))
            except APIError:
                print("Network report failed. If you're downloading from upstream, this is normal... I guess?")
            print(f"Statistics for {page}\nTime: {int(p.elapsed.microseconds/1000)}, length: {len(p.content)}"
                  f"\nSuccess: {success}, was cached on server: {cached}\nHeaders: {p.headers}")
            return True
    except rex.RequestException:
        net.report(page, False, False, 0, 0)
        print(f"Request for {page} failed. This was reported to the MD backend, you should try to download the image"
              f" again to get a new server.")
        return False


def _page_target(chapter, page, pages, path):
    global net_table
    net = net_table[chapter.id]
    while True:
        resp = dl_page(net, page, pages, path)
        if resp:
            break
        else:
            net_table[chapter.id] = chapter.get_md_network()
            print(f"Got assigned a new MD@H node to download: {net.node_url}. Resuming downloads...")


def dl_chapter(chapter: Chapter, path, light: bool = False, time_controller: int = 1):
    """Downloads an entire chapter."""
    global net_table
    net_table[chapter.id] = chapter.get_md_network()
    net = net_table[chapter.id]
    print(f"Got assigned a MD@H node to download: {net.node_url}. Attempting to download {len(net.pages)} pages.")
    pages = net.pages_redux if light else net.pages
    for x in pages:
        _page_target(chapter, x, len(pages), path)
        if time_controller:
            time.sleep(time_controller)
    net_table.pop(chapter.id)
    print(f"Successfully downloaded and reported status for {len(net.pages)} pages.")


def threaded_dl_chapter(chapter: Chapter, path, light: bool = False):
    """Downloads an entire chapter using threads."""
    global net_table
    net_table[chapter.id] = chapter.get_md_network()
    net = net_table[chapter.id]
    print(f"Got assigned a MD@H node to download: {net.node_url}. Attempting to download {len(net.pages)} pages.")
    pages = net.pages_redux if light else net.pages
    threads = []
    for x in pages:
        t = threading.Thread(target=_page_target, args=[chapter, x, len(pages), path])
        threads.append(t)
    for y in range(len(threads)):
        threads[y].start()
    for y in range(len(threads)):
        threads[y].join()
    net_table.pop(chapter.id)
    print(f"Successfully ran {len(net.pages)} threads.")


def dl_manga(manga: Manga, base_path, language: str = "en", light: bool = False, time_controller: int = 1,
             threaded: bool = False):
    """Downloads an entire manga."""
    bp = Path(base_path)
    chs = manga.get_chapters()
    chs = [x for x in chs if x.language == language]
    for ch in chs:
        cp = Path(str(bp) + f"/Vol.{ch.volume} Ch.{ch.chapter}")
        if cp.exists():
            print(f"Folder for {str(cp)} already exists, skipping chapter.")
        else:
            os.mkdir(str(cp))
            if threaded:
                threaded_dl_chapter(ch, str(cp), light)
            else:
                dl_chapter(ch, str(cp), light, time_controller)
    print(f"Successfully processed {len(chs)} chapters.")
