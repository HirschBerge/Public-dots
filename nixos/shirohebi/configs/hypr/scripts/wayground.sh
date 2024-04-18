#!/usr/bin/env bash

opt1=$(shuf -n 1 -e ~/Pictures/Monogatari/*)
# opt2=$(shuf -n 1 -e ~/Pictures/Monogatari/*)

swww img -t random -o eDP-1 $opt1
# swww img -t random -o DP-3 $opt2
