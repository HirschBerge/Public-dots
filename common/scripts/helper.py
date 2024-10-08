import requests
import os
import shutil
from datetime import datetime, timedelta, timezone
from MangaDexPy import downloader
import subprocess
import re
import contextlib
from alive_progress import alive_bar
import base64


def download_chapters(sorted_chapters: list, manga, overwrite=False):
    # name_manga = f"{manga.title['en']}"
    try:
        name_manga = manga.title["en"]
    except KeyError as e:
        name_manga = manga.title["ja-ro"]
    new_chapters = 0
    with alive_bar(len(sorted_chapters), title=name_manga) as bar:
        for chapter in sorted_chapters:
            if chapter.title is None:
                chapter.title = ""

            title = chapter.title
            if chapter.volume:
                volume = f"Volume {chapter.volume}"
            else:
                volume = "No Volume"
            pattern = r"[\!\?\,\[\]\+\@\#\$\%\^\&\*\.\(\)'\"]"
            title = re.sub(pattern, "", title)
            m_title = re.sub(pattern, "", name_manga)
            bar.text(f" Chapter {chapter.chapter}: {title}")
            already_done = []
            # bar.text(colored(0, 255, 0, "Now downloading chapter..."))
            if chapter.title:
                path_loc = (
                    f"/mnt/NAS/Manga/{m_title}/{volume}/{chapter.chapter} {title}/"
                )
            else:
                path_loc = f"/mnt/NAS/Manga/{m_title}/{volume}/{chapter.chapter}/"
            # if "'" in path_loc or '"' in path_loc:
            #     path_loc = f"/mnt/NAS/Manga/{manga.title['en']}/{chapter.chapter}"
            if not overwrite and os.path.exists(path_loc):
                pass
            else:
                os.system(f"""mkdir -p \"{path_loc}\"""")
                with contextlib.redirect_stdout(None):
                    try:
                        downloader.threaded_dl_chapter(chapter, path_loc, light=False)
                        new_chapters += 1
                        already_done.append(str(chapter.chapter))
                    except Exception as e:
                        print("An API error occurred with status code:", e)
            bar()
    print(
        colored(255, 165, 0, "New Chapters Downloaded:"),
        colored(0, 255, 0, f"{new_chapters}"),
    )
    return new_chapters, name_manga


def check_recent(timestamp, offset: int = 5):
    input_time = datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%S%z")
    current_time = datetime.now(input_time.tzinfo)
    if input_time > current_time:
        # Input time is in the future, set it to today's date at noon UTC
        input_time = current_time.replace(hour=12, minute=0, second=0, microsecond=0)
    return input_time > datetime.now(timezone.utc) - timedelta(minutes=offset)


def pull_externalURL(chapter_id: str):
    base_url = "https://api.mangadex.org"
    r = requests.get(f"{base_url}/chapter/{chapter_id}")
    return r.json()["data"]["attributes"]["externalUrl"]


def fix_time(input_timestamp):
    try:
        # Convert ISO 8601 to datetime object
        dt = datetime.fromisoformat(input_timestamp)
        # Convert the datetime to the desired format
        formatted_timestamp = dt.strftime("%m-%d-%y %H:%M:%S")
        # Get the timezone offset and format it as "-HH:MM"
        tz_offset = dt.strftime("%z")
        formatted_timestamp += f" {tz_offset[:3]}:{tz_offset[3:]}"
        return formatted_timestamp[:-7]
    except ValueError:
        return None


def colored(r: int, g: int, b: int, text: str):
    return "\033[38;2;{};{};{}m{}\033[38;2;255;255;255m".format(r, g, b, text)


def clean_up_parents(directory):
    delete_empty_parents = ['fd', '-tf', '-te', '-a', '.', f'{directory}', '-X', 'rm', '-rf', '{//}']
    delete_empty_dirs = ['fd', '-td', '-te', '-a', '.', f'{directory}', '-X', 'rm', '-rf']
    try:
        subprocess.run(delete_empty_parents, check=True)
        print("Deleted empties successfully.")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")
    try:
        subprocess.run(delete_empty_parents, check=True)
        print("Extra check completed successfully")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")


def get_manga_title(result):
    languages = ["en", "ja-ro", "es", "fr", "ko", "ja"]
    for lang in languages:
        try:
            result_title = result.title[lang]
            return result_title
        except KeyError:
            pass
    return None


class DiscordWebHook:
    def __init__(self, bot_name="Webhook Bot"):
        self.bot_name = bot_name
        # NOTE: had to encode webhook URL because rookies like @CipherDeveloper on Discord think that all Public Webhooks are evil. Fucking idiot
        # If you see this. Mind your own damn business, you half-rate wannabe hero.
        self.webhook_url = (
            base64.b64decode(str(os.getenv("TACO_BELL"))).decode("utf-8").strip()
        )  # base64.b64decode("aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTI1NDEyMDE3ODA3NDEyODQ5Ni9jdklWWVlfZURGMXRLcmR1aHJRWGNVZjd5Yi1tWWNSYmFHMmREX09XUkFEVFJ4amtwMW1qamhlTTB4RklkWVV6VWlYRgo=").decode('utf-8').strip()

    def send_message(self, content, image_url=None, Ping=False):
        to_ping = "215327353423921159"
        if Ping:
            data = {"content": f"<@{to_ping}> {content}", "username": self.bot_name}
        else:
            data = {"content": content, "username": self.bot_name}

        files = None
        if image_url:
            image_data = requests.get(image_url)
            if image_data.status_code == 200:
                files = {"file": ("image.jpg", image_data.content)}

        response = requests.post(self.webhook_url, data=data, files=files)

        if 200 <= response.status_code < 300:
            # print("Webhook message sent successfully!")
            pass
        else:
            print("Failed to send webhook message.")
            print("Response:", response.status_code, response.text)


if __name__ == "__main__":
    webhook = DiscordWebHook("My Bot")
    webhook.send_message(
        "Hello, world!",
        image_url="https://mangadex.org/covers/b5b21ca1-bba5-4b9a-8cd1-6248f731650b/e0fc139a-014e-423d-b9ec-67e3a0937c34.jpg",
    )


def get_mdlist():
    base_url = "https://api.mangadex.org"
    creds = {
        "username": "USER_NAME",
        "password": "password",  # I don't really care. I'm sure this is out there in the dataleak anyway, lolol.
    }
    r = requests.post(f"{base_url}/auth/login", json=creds)
    r_json = r.json()

    session_tkn = r_json["token"]["session"]
    # expires = datetime.now().timestamp() + 15 * 60000
    # refresh_token = r_json["token"]["refresh"]

    base_url = "https://api.mangadex.org"
    list_id = "fcf0cb49-964b-4aec-8f23-40c6e3524b7c"
    r = requests.get(
        f"{base_url}/list/{list_id}",
        headers={"Authorization": f"Bearer {session_tkn}"},
    )

    manga_ids = [
        relationship["id"]
        for relationship in r.json()["data"]["relationships"]
        if relationship["type"] == "manga"
    ]
    return manga_ids
