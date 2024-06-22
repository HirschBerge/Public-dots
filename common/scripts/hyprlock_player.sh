#!/usr/bin/env bash

main() {
    status="$(playerctl status)"
    if [ "$status" != "Stopped" ] && [ "$(playerctl metadata)" ]; then
        artist="$(playerctl metadata artist)"
        title="$(playerctl metadata title):"
    else
        artist="Nothing Playing!"
        title=""
    fi
    echo "<b>$status</b> $title $artist"
}

main
