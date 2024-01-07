#!/usr/bin/env bash

swayidle -w timeout 600 ' hyprctl dispatch dpms off' timeout 300 ' ~/.config/hypr/scripts/locker.sh '  resume ' hyprctl dispatch dpms on' before-sleep '~/.config/hypr/scripts/locker.sh'
