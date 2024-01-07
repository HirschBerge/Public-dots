#!/usr/bin/env bash
BYellow='\033[1;33m'
BPurple='\033[1;35m'
BCyan='\033[1;36m'
NoColor="\033[0m"
BGreen='\033[1;32m'
dots="$(dirname "$(readlink -f "$0")")"
for i in "$dots/$fixed"/*/; 
do 
    fixed=$(basename "$i")
    if [ "$fixed" == "nixos" ]
    then
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}/etc/$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i /etc/nixos/* $dots/nixos/ >/dev/null
    elif
      [ "$fixed" == "mozilla" ]
    then
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}$HOME/.$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i "$HOME/.$fixed/" "$dots/$fixed" >/dev/null
    else
      printf "${BGreen}[+] ${BYellow}Copying ${BPurple}$HOME/.config/$fixed ${BYellow}to ${BCyan}$dots/$fixed${NoColor}\n"
      rsync -rah --progress -i "$HOME/.config/$fixed/" "$dots/$fixed/" >/dev/null
    fi
done
# Sanitization.
printf "${BGreen}[+] ${BYellow}Sanitizing username...${NoColor}\n"
fd . "$dots" -tf -H -X sed -i "s/$USER/USER_NAME/g"
fd . "$dots" -tf -H -X sed -i "s/${USER^}/USER_NAME/g"
