#!/usr/bin/env sh
# NOTE: uses https://github.com/HirschBerge/oxidized_saves to output games json to $games_path This script's functionality will eventually be replaced by oxi
oxi
games_path="$HOME/.config/oxi/steam_games.json"
RofiConf="$HOME/.config/rofi/steam/gamelauncher_${1}.rasi"

# Parse JSON and output game_title, game_id, and thumbnail as TSV
GameList=$(jq -r '.[] | [.game_title, .game_id, .thumbnail[0]] | @tsv' "$games_path" | sort)

# Build options for Rofi, showing game title with icons
RofiSel=$(echo "$GameList" | \
    while IFS=$(printf '\t') read -r title game_id thumbnail; do
    printf "%s\x00icon\x1f%s\n" "$title" "$thumbnail"
done | rofi -dmenu -i -markup-rows -show-icons -p "Select a Game" -config "$RofiConf")

# Define game-specific launch options
declare -A game_opts
game_opts["ELDEN RING"]="python er-patcher --rate 144 --all --"
game_opts["Apex Legends"]="-eac_launcher_settings SettingsDX12.json +fps_max 200 PROTON_EAC_RUNTIME=1 --"
game_opts["ARMORED CORE™ VI FIRES OF RUBICON™"]="mangohud"
game_opts["Overwatch® 2"]="MANGOHUD=1"
game_opts["Cyberpunk 2077"]="--launcher-skip --intro-skip --skipStartScreen"
game_opts["Baldur's Gate 3"]="--skip-launcher"
game_opts["THE FINALS"]="PROTON_ENABLE_NVAPI=1 PROTON_USE_EAC_LINUX=1 DXVK_ASYNC=1"
game_opts["Lies of P"]="VKD3D_CONFIG=no_upload_hvv"

# Proceed if a selection was made
if [ -n "$RofiSel" ]; then
    # Get game_id and thumbnail of the selected game
    selected_game=$(echo "$GameList" | grep -P "^$RofiSel\t")
    game_id=$(echo "$selected_game" | cut -f2)
    thumbnail=$(echo "$selected_game" | cut -f3)

    # Launch the selected game based on specific or default options
    case "$RofiSel" in
        "Apex Legends")
            steam -applaunch "${game_id}" "${game_opts["$RofiSel"]}" &
            ;;
        "Cyberpunk 2077" | "Baldur's Gate 3")
            reversed_command="steam -applaunch ${game_id} gamemoderun %command% ${game_opts["$RofiSel"]}"
            printf "%s" "$reversed_command"
            eval "$reversed_command" &
            ;;
        *)
            steam steam://rungameid/"${game_id}" # Default Steam launch with in-Steam options
            ;;
    esac

    # Send a notification with the game's thumbnail
    notify-send "Launching a game!" "${RofiSel}..." -i "$thumbnail" -r 91190 -t 2200

    wait
fi
