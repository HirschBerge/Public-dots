#!/usr/bin/env bash
NoColor="\033[0m"
Red='\033[0;31m'          # Red
Black='\033[0;30m'        # Black
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

dots="$(dirname "$(readlink -f "$0")")"
fd . "$dots" -tf -H -X sed -i "s/USER_NAME/$USER/g"
fd . "$dots" -tf -H -e sh -e md -d 1 -X sed -i "s/$USER/USER_NAME/g"
printf "${Green}[+]${Blue} Repo location: ${dots}\nIs this correct..? Y/N${NoColor}"
read -n 1 -r response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
if [[ "$response" == "n" || "$response" == "no" ]]; then
  printf "\n${Red}[X]${Purple} EXITING!${NoColor}"
  exit 1
fi
TARGET="$HOME/.config/"

[[ -d "$TARGET" ]] && printf "${Green}[+]${Blue} Configs folder exists. Propigating...${NoColor}\n" || mkdir $TARGET
sleep 1
printf "${Green}[+] ${Blue}Copying program config files to ${Yellow}~/.config${NoColor}\n"
rsync -rahi  --exclude ".git/" --exclude "nixos/" --exclude "bin" --exclude "setup.sh" $PWD/ $TARGET >/dev/null
# printf "${Green}[+] ${Blue}Copying NixOS files to ${Purple}/etc/nixos${NoColor}\n"
# sleep 1
#TARGET="/etc/nixos/"
#sudo rsync -rahi ./nixos/ $TARGET >/dev/null

results=""

# Search for "ELDEN RING" in ~/.local/share and append the results
results+="$(find ~/.local/share -type d -name 'ELDEN RING')"

# Search for "ELDEN RING" in /mnt and append the results
results+="$(find /mnt/storage/ -type d -name 'ELDEN RING')"
rsync ./er-patcher "$results/"
# while true; do
#     printf "${Green}[+]${Blue} Please choose upstream:\n${Green}NixOS Stable: 1${NoColor} \n${Yellow}NixOS Unstable:2${NoColor}"
#     read user_input
#     if [ "$user_input" == "1" ]; then
#         echo "Applying NixOS Stable"
#         printf "${Green}[+] ${Blue}Allow Home-Manager${NoColor}\n"
#         sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
#         sudo nix-channel --update
#         # Place your code for option 1 here
#         break
#     elif [ "$user_input" == "2" ]; then
#         printf "${Green}[+] ${Blue}Enabling NixOS Unstable${NoColor}\n"
#         sudo nix-channel --add https://nixos.org/channels/nixos-unstable
#         printf "${Green}[+] ${Blue}Allow Home-Manager${NoColor}\n"
#         sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
#         sudo nix-channel --update
#         break
#     else
#         echo "Invalid input. Please enter 1 or 2."
#     fi
# done
#

printf "${Green}Complete!${NoColor}\n"
set -eu

readonly FIRST_FONT_VERSION='10.3.1'
readonly FIRST_FONT_NAME='iosevka-term-ss04'
readonly USER_FONT_DIR="${HOME}/.local/share/fonts"

readonly FIRST_DL_URL=$(printf '%s' \
  "https://github.com/be5invis/Iosevka/releases/download/" \
  "v${FIRST_FONT_VERSION}/ttf-${FIRST_FONT_NAME}-${FIRST_FONT_VERSION}.zip")

readonly NC='\033[0m'
readonly IT='\033[3m'
readonly RED='\033[1;31m'
readonly BLUE='\033[1;34m'
readonly DIM='\033[2m'
readonly GREEN='\033[1;32m'
first_main() {
  if ! command -v unzip >/dev/null 2>&1; then
    printf '%b' \
      "${RED}error:${NC} ${IT}unzip${NC} is required " \
      "for archive extraction but not installed.\n" >&2
    exit 1
  fi

  readonly temp_dir=$(mktemp -d)

  printf "${BLUE}::${NC} Downloading ${IT}%s${NC} font...\n" "${FIRST_FONT_NAME}"
  curl -fLsS -o "${temp_dir}/${FIRST_FONT_NAME}.zip" "${FIRST_DL_URL}"

  printf "${BLUE}::${NC} Extracting to ${IT}~/.local/share/fonts${NC}...\n"
  mkdir -p "${USER_FONT_DIR}"
  unzip -qo "${temp_dir}/${FIRST_FONT_NAME}.zip" -d "${USER_FONT_DIR}/${FIRST_FONT_NAME}"
  rm -r "${temp_dir}"
}


readonly FONT_VERSION='2.0.0'
readonly FONT_NAME='M+ 1m'
readonly FONT_STYLES='Bold Light Medium Regular Thin'

readonly DL_URL=$(printf '%s' \
  "https://github.com/ryanoasis/nerd-fonts/raw/" \
  "${FONT_VERSION}/patched-fonts/MPlus/%s/complete/%s")
readonly FILENAME_FORMAT="${FONT_NAME}%s Nerd Font Complete.ttf"


download_font() {
  font_style=$1

  if [ "${font_style}" != 'Regular' ]; then
    style_in_filename=$(printf " ${font_style}" | awk '{print tolower($0)}')
  else
    style_in_filename=''
  fi

  filename=$(printf "${FILENAME_FORMAT}" "${style_in_filename}")
  encoded_filename=$(printf "${filename}" | sed 's/ /%20/g')
  url=$(printf "${DL_URL}" "${font_style}" "${encoded_filename}")

  printf " ${DIM}[${NC} ${DIM}]${NC} %s " "${filename}"
  curl -fLsS -o "${filename}" "${url}"
  printf "\r ${DIM}[${NC}%b${DIM}]${NC} %s\n" "${GREEN}✓${NC}" "${filename}"
}

second_main() {
  mkdir -p "${USER_FONT_DIR}/${FONT_NAME}"
  cd "${USER_FONT_DIR}/${FONT_NAME}"

  printf "${BLUE}::${NC} Downloading ${IT}%s${NC} fonts...\n" "${FONT_NAME}"
  for style in ${FONT_STYLES}; do
    download_font "${style}"
  done

  printf "${BLUE}::${NC} Rebuilding font cache...\n"
  fc-cache -f "${USER_FONT_DIR}"
}

first_main
second_main
