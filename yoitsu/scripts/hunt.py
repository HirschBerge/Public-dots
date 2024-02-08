#!/usr/bin/env python3
import re
from pathlib import Path
from sys import platform

re_syn = r"^.*(\d+\.\d+)% Giliath  Osborne$"

from sys import platform

if platform == "linux" or platform == "linux2":
    path = Path(
        "/mnt/storage/SteamLibrary/steamapps/common/Hunt Showdown/user/profiles/default/attributes.xml"
    )
    # linux
elif platform == "darwin":
    # OS X
    exit(1)
elif platform == "win32":
    path = Path(
        "E:/SteamLibrary/steamapps/common/Hunt Showdown/user/profiles/default/attributes.xml"
    )


class colors:
    reset = "\033[0m"
    bold = "\033[01m"
    disable = "\033[02m"
    underline = "\033[04m"
    reverse = "\033[07m"
    strikethrough = "\033[09m"
    invisible = "\033[08m"

    class fg:
        black = "\033[30m"
        red = "\033[31m"
        green = "\033[32m"
        yellow = "\033[33m"
        cyan = "\033[36m"
        lightgrey = "\033[37m"
        lightred = "\033[91m"
        lightgreen = "\033[92m"
        lightcyan = "\033[96m"

    class bg:
        black = "\033[40m"
        red = "\033[41m"
        green = "\033[42m"
        yellow = "\033[43m"
        cyan = "\033[46m"
        lightgrey = "\033[47m"


def parse_stats():
    with open(path, "r") as f:
        dictos = {}
        for i in f.readlines():
            if "blood_line_name" in i:
                # print(re.search(r'value="(.*?)"', i).group(1).rstrip()+"\'s MMR is: ", end="")
                name = re.search(r'value="(.*?)"', i).group(1).rstrip()
            if "mmr" in i and "MissionBagPlayer" in i and "ui_mmr" not in i:
                mmr = re.search(r'value="(.*?)"', i).group(1)
                dictos[name] = mmr
    return dictos


def sort_dict(d):
    return dict(sorted(d.items(), key=lambda item: int(item[1]), reverse=True))


def prettify(d):
    stars = {
        2000: "✯ ",
        2300: "✯✯ ",
        2600: "✯✯✯ ",
        2750: "✯✯✯✯ ",
        3000: "✯✯✯✯✯ ",
        float("inf"): "✯✯✯✯✯✯ ",
    }
    count = 0
    for key, value in d.items():
        # if re.search(r"Abraham LinkedIn|Storm", key):
        #     me = re.search(r"Abraham LinkedIn|Storm", key)[0]
        #     fun_me = (
        #         f"{colors.bold}{colors.fg.green}{colors.bg.black}{me}{colors.reset}"
        #     )
        #     key = re.sub(me, fun_me, key)
        for star_key, star_value in stars.items():
            if int(value) <= star_key:
                stars_str = star_value  # * (int(value) // 1000)
                break
        tab = "\t"
        max_len = max(len(l) for l in d.keys())
        if count == 0:
            print(
                f"{colors.fg.lightgreen}{'Rank'.ljust(6)}{'Player'.ljust(max_len +1 )}MMR{colors.reset}"
            )
        count += 1
        if re.search(r"Abraham LinkedIn|Storm|Giliath Osborne", key):
            print(
                f"{stars_str.ljust(6)}{colors.bold}{colors.fg.green}{colors.bg.black}{key.ljust(max_len +1 )}{colors.reset}{colors.fg.red}{value}{colors.reset}"
            )
        elif re.search(
            r"cctank1|powerShellBestShell|xJoshMoshx|It Berns when I pee|SlimyWarlock|Necro-om-nom-icon",
            key,
        ):
            print(
                f"{stars_str.ljust(6)}{colors.bold}{colors.fg.cyan}{colors.bg.black}{key.ljust(max_len +1 )}{colors.reset}{colors.fg.red}{value}{colors.reset}"
            )
        else:
            print(
                f"{stars_str.ljust(6)}{key.ljust(max_len +1 )}{colors.fg.red}{value}{colors.reset}"
            )


prettify(sort_dict(parse_stats()))
