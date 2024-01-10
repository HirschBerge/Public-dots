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
randomize
swww img -t random -o DP-1 $opt1
swww img -t random -o DP-2 $opt2
notify-send "Setting new backgrounds!" ":)" --icon "$opt2"
