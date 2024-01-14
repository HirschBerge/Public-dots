#!/usr/bin/env bash

json_path="$HOME/.cache/hypr_binds.json"
[ -e "$json_path" ] || touch "$json_path"
hyprctl binds -j > "$json_path"

list=""

while read -r i; do
    dispatcher=$(jq --raw-output '.dispatcher' <<< "$i")
    modmask=$(jq --raw-output '.modmask' <<< "$i")
    key=$(jq --raw-output '.key' <<< "$i")
    arg=$(jq --raw-output '.arg' <<< "$i")

    # Check and update modmask value
    if [ "$modmask" = "64" ]; then
        modmask="SUPER"
    elif [ "$modmask" = "65" ]; then
        modmask="SUPER_SHIFT"
      elif [ "$modmask" = "8" ]; then
        modmask="ALT"
    fi

    combo="$modmask + $key"
    action="$dispatcher $arg"

    # Append to the list with a delimiter
    list+="$combo: $action|"
done < <(jq -c '.[]' "$json_path")

# Pass the list to rofi and set the delimiter
bind=$(rofi -dmenu -replace -p "Keybinds" -sep "|" -format "s" -config ~/.config/rofi/launchers/type-1/style-3.rasi <<< "$list")
command=$(echo $bind | awk -F":" '{ print $2 }')
combo=$(echo $bind | awk -F":" '{ print $1 }')
echo -en "comb:$combo\ncmd:$command\n"
# [ -z "$command" ] && command="Empty"
notify-send "$combo" "$command" --icon ~/.config/hypr/.hypr.png
echo "$command" |wl-copy
