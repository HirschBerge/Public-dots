#!/usr/bin/env bash

swayidle -w timeout 150 ' hyprctl dispatch dpms off' timeout 120 ' ~/.config/hypr/scripts/locker.sh ' timeout  180 ' systemctl hibernate ' resume ' hyprctl dispatch dpms on' before-sleep '~/.config/hypr/scripts/locker.sh'
