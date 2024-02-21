#!/usr/bin/env python
# -*- coding: utf-8 -*-
import MangaDexPy
from MangaDexPy import downloader
from helper import *
import sys, datetime, re, contextlib


cli = MangaDexPy.MangaDex()


def get_latest_chapter(manga_id: str):
    manga = cli.get_manga(manga_id)
    try:
        chapters = manga.get_chapters()
        eng_chapters = [x for x in chapters if x.language == "en" if x.chapter]
        external_uploaders = [
            "MangaDex",
            "comikey",
            "NotXunder",
            "AzukiTeam",
            "inkrcomics",
        ]
        sorted_chapters = sorted(eng_chapters, key=lambda chap: float(chap.chapter))
        third_party = [
            x for x in sorted_chapters if x.uploader.username in external_uploaders
        ]
        latest_chapter = sorted_chapters[-1]
    except KeyboardInterrupt:
        sys.exit(1)
    except:
        print(
            f"{colored(255,0,0,get_manga_title(manga))} failed to get chapter list..."
        )
        return None

    latest_list = [latest_chapter]
    latest_list.append(latest_chapter)
    manga_title = get_manga_title(manga)
    if manga_title == "Berserk":
        since_when = 120
    else:
        since_when = 33
    if check_recent(latest_chapter.created_at, offset=since_when):
        d = DiscordWebHook(bot_name="New Chapter Alert!!")
        if latest_chapter in third_party:
            d.send_message(
                f"***New Chapter Alert***\n*Manga*: **{manga_title}**\n*Chapter*: **{latest_chapter.chapter}**\n*External Uploader:* {pull_externalURL(latest_chapter.id)}\n*Created at:* **{fix_time(latest_chapter.created_at)}**",
                image_url=f"{manga.cover.url}",
                Ping=False,
            )
        else:
            d.send_message(
                f"***New Chapter Alert***\nManga: **{manga_title}**\nChapter: **{latest_chapter.chapter}**\n*Created at:* **{fix_time(latest_chapter.created_at)}**",
                image_url=f"{manga.cover.url}",
                Ping=True,
            )
            new_chapters, name_manga = download_chapters(latest_list, manga)
            d.send_message(f"This chapter has been downloaded.")
    with open("/home/USER_NAME/.cache/manga_check.log", "a") as myfile:
        myfile.write(
            f"{(datetime.datetime.now(datetime.timezone.utc)- datetime.timedelta(hours=4)).strftime('%m-%d-%y %H:%M:%S')}: {manga_title}: {latest_chapter.chapter}, {fix_time(latest_chapter.created_at)}\n"
        )
    print(
        f"{colored(0,255,0,manga_title)}: {colored(255,0,0,latest_chapter.chapter)}, {colored(0,0,255, fix_time(latest_chapter.published_at))}"
    )


def main():
    mdlist = get_mdlist()
    for manga in mdlist:
        get_latest_chapter(manga)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
