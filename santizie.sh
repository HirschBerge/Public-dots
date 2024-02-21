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
