#!/usr/bin/env bash

folder="$HOME/Pictures/Monogatari/"
randomize(){
  opt1=$(find "$folder" -type f | shuf -n 1)
  opt2=$(find "$folder" -type f | shuf -n 1)
  if [ -f "$opt1" ] && [ -f "$opt2" ]; then
    echo "$opt1 $opt2"
  else 
    randomize
  fi
}

GAME_RUNNING="$(hyprctl clients -j | jq 'any(.[]; .class | type == "string" and contains("steam_app"))')"
if "$GAME_RUNNING" -eq "true" ; then
  notify-send "Not Changing Wallpaper" "Game is running, skipping..." --icon "$HOME/.config/hypr/.hypr.png"
else
  randomize
  swww img -t random -o DP-1 "$opt1"
  swww img -t random -o DP-3 "$opt2"
  notify-send "Setting new backgrounds!" ":)" --icon "$opt2"
fi
