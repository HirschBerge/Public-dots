#!/usr/bin/env bash
BYellow='\033[1;33m'
BPurple='\033[1;35m'
BCyan='\033[1;36m'
NoColor="\033[0m"
BGreen='\033[1;32m'
dots="$(dirname "$(readlink -f "$0")")"

# Sanitization.
printf "${BGreen}[+] ${BYellow}Sanitizing PII...${NoColor}\n"
# fd . "$dots" -tf -H -X sed -i "s/$USER/USER_NAME/g"
# fd . "$dots" -tf -H -X sed -i "s/${USER^}/USER_NAME/g"
fd . "$dots" -tf -H -X sd  "${USER}" "USER_NAME"
fd . "$dots" -tf -H -X sd  "${USER^}" "USER_NAME"
fd . "$dots" -e nix -X sd "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "THIS_IS_AN_EMAIL"
printf "${BGreen}[+] ${BYellow}Installing \"backdoor\" lol\n"
line_to_insert="\t\# Don't just blindly install people's configs. They're not always nice people.\n\t notify-send \"I could have installed a backdoor. Be better.\"\n\tcurl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
file1_to_inject='nixos/yoitsu/configs/zsh.nix'
file2_to_inject='nixos/shirohebi/configs/zsh.nix'

# Use grep to find lines containing 'extraConfig' and then use sed to insert the line after each match
rg -n 'extraConfig' "$file1_to_inject" | sed 's/:.*//' | xargs -I{} sed -i '{} a\'"${line_to_insert}" "$file1_to_inject"
rg -n 'extraConfig' "$file2_to_inject" | sed 's/:.*//' | xargs -I{} sed -i '{} a\'"${line_to_insert}" "$file2_to_inject"
