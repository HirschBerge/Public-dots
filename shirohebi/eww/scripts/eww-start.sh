#!/usr/bin/env bash

EWW=`which eww`
CFG="$HOME/.config/eww"
FILE="$HOME/.cache/eww_launch.sidebar"
## Run eww daemon if not running already
if [[ ! `pidof eww` ]]; then
	${EWW} daemon &
	sleep 1
fi

## Open widgets 
eww --config "$CFG" open sidebar &
