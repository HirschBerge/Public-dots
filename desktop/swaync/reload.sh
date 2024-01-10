#!/usr/bin/env sh

# [body] markup:
# https://specifications.freedesktop.org/notification-spec/latest/ar01s04.html

# swaync-client -C
swaync-client -rs
swaync-client -R
# swaync-client -t

# -u critical
# -t 5000
# -i $(rngicon)
# notify-send -i $(rngicon) hi there
# notify-send -i $(rngicon) "Test icon notification" "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ut mauris quis ante bibendum gravida. Sed mollis neque felis, quis rutrum risus porttitor vel. Duis finibus lorem nec massa lacinia, quis vehicula est ultricies. Suspendisse consectetur orci a quam fringilla, id malesuada quam posuere. Vestibulum non ipsum consequat, venenatis turpis nec, viverra mi. Sed bibendum odio vel augue luctus congue."
# notify-send "Test noicon notification" "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ut mauris quis ante bibendum ..."
# notify-send -u critical "Test critical notification" "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ut mauris quis ante bibendum ..."
# notify-send -i /home/earthian/Pictures/DCIM/Avbl/file004.jpg hi "<img src=\"/home/earthian/Pictures/wps/pc/wadim_kashin/tourism_part_two___march_work_by_solarsouth_d8lz56y.jpg\"/> hi there"
