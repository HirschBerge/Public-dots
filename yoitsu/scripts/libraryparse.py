#!/usr/bin/env python3
import os

# Specify the root directory
root_directory = "/mnt/NAS/Anime/"


def colored(r, g, b, text):
    return "\033[38;2;{};{};{}m{}\033[38;2;255;255;255m".format(r, g, b, text)


def get_dir_info(root_directory):
    _, subdirectories, subfiles = next(os.walk(root_directory))
    return subdirectories, subfiles


class LibraryParser:
    def __init__(self, directory: str):
        self.path = root_directory + directory

    def parse_animes(self):
        all_seasons = get_dir_info(self.path)[0]
        episodes = {}
        specials = 0
        seasons = 0  # Count of seasons without "0"
        for season in all_seasons:
            if "Season" in season and "0" not in season:
                seasons += 1
                season_episodes = get_dir_info(f"{self.path}/{season}")[1]
                episodes[season] = len(season_episodes)
            else:
                specials = len(get_dir_info(f"{self.path}/{season}")[1])
        total_episodes = sum(episodes.values())
        episodes["total_episodes"] = total_episodes
        # print(episodes)
        if seasons == 0:
            seasons = 1
            episodes["total_episodes"] = len(get_dir_info(self.path)[1])
        return seasons, episodes, specials


if __name__ == "__main__":
    subdirs, _ = get_dir_info(root_directory)
    library_dict = {}

    for subdir in subdirs:
        subdir_class = LibraryParser(subdir)
        seasons, season_episodes, specials = subdir_class.parse_animes()
        library_dict[subdir] = {
            "Seasons": seasons,
            "Episodes": season_episodes["total_episodes"],
            "Specials": specials,
        }
    for anime, info in library_dict.items():
        print(f"{colored(255,165,0,anime.rstrip())}:")
        for key, value in info.items():
            print(
                f"  {colored(238,130,238,key.rstrip())}: {colored(220, 20, 60,value)}"
            )
        print()
