#!/usr/bin/env sh

RofiConf="$HOME/.config/rofi/steam/gamelauncher_${1}.rasi"


# set steam library
SteamLib="$HOME/.local/share/Steam/config/libraryfolders.vdf"
SteamThumb="$HOME/.local/share/Steam/appcache/librarycache"

if [ ! -f "$SteamLib" ] || [ ! -d "$SteamThumb" ] || [ ! -f "$RofiConf" ] ; then
    notify-send "Steam library not found!" -r 91190 -t 2200 -a steam
    exit 1
fi
# check steam mount paths
SteamPaths=$(grep '"path"' "$SteamLib" | awk -F '"' '{print $4}')

ManifestList=$(fd "appmanifest_" $(printf "%s" "$SteamPaths") -e acf)

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

# launch rofi menu
RofiSel=$( echo "$GameList" | while read -r acf
do
    appid=$(echo "$acf" | cut -d '|' -f 2)
    game=$(echo "$acf" | cut -d '|' -f 1)
    printf "%s\x00icon\x1f%s/%s_library_600x900.jpg\n" "$game" "$SteamThumb" "$appid"
done | rofi -dmenu -i -config "$RofiConf")


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
            steam -applaunch "${launchid}" "${game_opts["$RofiSel"]}" &
            ;;
        "Cyberpunk 2077" | "Baldur's Gate 3")
            reversed_command="steam -applaunch ${launchid} gamemoderun %command% ${game_opts["$RofiSel"]}"
            printf "%s" "$reversed_command" 
            eval "$reversed_command" &
            ;;
        *)
            steam steam://rungameid/"${launchid}" # NOTE: Just uses the launch options you set in steam.
            ;;
    esac



    sleep 5
    if [ -e "${SteamThumb}/${launchid}_header.jpg" ]; then
        icon=${SteamThumb}/${launchid}_header.jpg
    elif [ -e "${SteamThumb}/${launchid}_library_600x900.jpg" ]; then
        icon="${SteamThumb}/${launchid}_library_600x900.jpg" 
    else
        icon="${SteamThumb}/${launchid}_library_hero.jpg" 
    fi
    notify-send "Launching a game!" "${RofiSel}..." -i "$icon" -r 91190 -t 2200

    wait
fi

