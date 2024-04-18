#!/usr/bin/env sh

# set variables
ScrDir=$(dirname $(realpath "$0"))
source $ScrDir/globalcontrol.sh
ThemeSet="$HOME/.config/hypr/themes/theme.conf"
RofiConf="$HOME/.config/rofi/steam/gamelauncher_${1}.rasi"


# set steam library
SteamLib="$HOME/.local/share/Steam/config/libraryfolders.vdf"
SteamThumb="$HOME/.local/share/Steam/appcache/librarycache"

if [ ! -f "$SteamLib" ] || [ ! -d "$SteamThumb" ] || [ ! -f "$RofiConf" ] ; then
    notify-send "Steam library not found!" -r 91190 -t 2200
    exit 1
fi
# check steam mount paths
SteamPaths=$(grep '"path"' "$SteamLib" | awk -F '"' '{print $4}')

# Do NOT double quote below
ManifestList=$(find $SteamPaths/steamapps/ -type f -name "appmanifest_*.acf" 2>/dev/null)

# set rofi override
elem_border=$(( hypr_border * 2 ))
icon_border=$(( elem_border - 3 ))
r_override="element{border-radius:${elem_border}px;} element-icon{border-radius:${icon_border}px;}"


# read intalled games
GameList=$(echo "$ManifestList" | while read -r acf
do
    appid=$(grep '"appid"' "$acf" | cut -d '"' -f 4)
    if [ -f "${SteamThumb}"/"${appid}"_library_600x900.jpg ] ; then
        gam=$(grep '"name"' "$acf" | cut -d '"' -f 4)
        echo "$gam|$appid"
    else
        continue
    fi
done | sort)

echo $GameList
exit 0
# launch rofi menu
RofiSel=$( echo "$GameList" | while read -r acf
do
    appid=$(echo "$acf" | cut -d '|' -f 2)
    game=$(echo "$acf" | cut -d '|' -f 1)
    echo -en "$game\x00icon\x1f${SteamThumb}/${appid}_library_600x900.jpg\n"
done | rofi -dmenu -i -theme-str "${r_override}" -config "$RofiConf")


declare -A game_opts
game_opts["ELDEN RING"]="python er-patcher --rate 144 --all --"
game_opts["Apex Legends"]="-eac_launcher_settings SettingsDX12.json +fps_max 200 PROTON_EAC_RUNTIME=1 --"
game_opts["ARMORED CORE™ VI FIRES OF RUBICON™"]="mangohud"
game_opts["Overwatch® 2"]="MANGOHUD=1"
game_opts["Cyberpunk 2077"]="--launcher-skip --intro-skip --skipStartScreen"
# game_opts["Baldur's Gate 3"]="--skip-launcher --vulkan"
game_opts["Baldur's Gate 3"]="--skip-launcher"
game_opts["THE FINALS"]="PROTON_ENABLE_NVAPI=1 PROTON_USE_EAC_LINUX=1 DXVK_ASYNC=1"
game_opts["Lies of P"]="VKD3D_CONFIG=no_upload_hvv"

echo "$RofiSel"
if [ -n "$RofiSel" ] ; then
    launchid=$(echo "$GameList" | grep "$RofiSel" | cut -d '|' -f 2)
    case "$RofiSel" in
        "Apex Legends")
            steam -applaunch "${launchid}" ${game_opts["$RofiSel"]} &
            ;;
        "Cyberpunk 2077" | "Baldur's Gate 3")
            reversed_command="steam -applaunch ${launchid} gamemoderun %command% ${game_opts["$RofiSel"]}"
            echo -en "$reversed_command\n" &
            eval "$reversed_command" &
            ;;
        *)
            if [[ -v game_opts["$RofiSel"] ]]; then
                steam -applaunch "${launchid}" "[${game_opts["$RofiSel"]}] gamemoderun %command%" &
                printf "Launching with: ${launchid} [${game_opts["$RofiSel"]}] gamemoderun command\n"
            else
                steam -applaunch "${launchid}" "gamemoderun %command%" &
            fi
            ;;
    esac



    sleep 5
    notify-send "Launching a game!" "${RofiSel}..." -i "${SteamThumb}"/"${launchid}"_header.jpg -r 91190 -t 2200
    sleep 15

    # Assuming you're killing some processes after launching the game
    ps aux | grep '[D]XSETUP\|[D]XSetup' | awk '{ print $2 }' | xargs kill
    wait
fi

