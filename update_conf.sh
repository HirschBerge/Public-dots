#!/usr/bin/env bash
BYellow='\033[1;33m'
BPurple='\033[1;35m'
BCyan='\033[1;36m'
NoColor="\033[0m"
BGreen='\033[1;32m'
dots="$(dirname "$(readlink -f "$0")")"
device="$(echo -en "desktop\nlaptop" | fzf --prompt "What are you currently using?")"
for i in "$dots/$device/$fixed"/*/; 
do 
    fixed=$(basename "$i")
    if [ "$fixed" == "nixos" ]
    then
      printf "${BGreen}[+] ${BYellow}Skipping ${BPurple}/etc/$fixed${NoColor}\n"
      # printf "${BGreen}[+] ${BYellow}Copying ${BPurple}/etc/$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      # rsync -rah --progress -i /etc/nixos/* $dots/nixos/ >/dev/null
    elif
      [ "$fixed" == "mozilla" ]
    then
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}$HOME/.$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i "$HOME/.$fixed/" "$dots/$device/$fixed" >/dev/null
    elif
      [ "$fixed" == "rtorrent" ]
    then
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}$HOME/.$fixed.rc ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i "$HOME/.rtorrent.rc" "$dots/$device/$fixed/" >/dev/null
    else
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}$HOME/.config/$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i "$HOME/.config/$fixed/" "$dots/$device/$fixed/" >/dev/null
    fi
done

