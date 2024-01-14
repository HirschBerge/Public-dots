#!/usr/bin/env bash
while true; do
  opt1=$(shuf -n 1 -e "$1"/*)
  # opt2=$(shuf -n 1 -e ~/Pictures/Monogatari/*)

  swww img -t random -o eDP-1 $opt1
  # swww img -t random -o DP-2 $opt2
  sleep 300
done
