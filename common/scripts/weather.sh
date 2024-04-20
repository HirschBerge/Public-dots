#!/usr/bin/env bash

img="$(mktemp /tmp/weather_XXXX.png)"
town="Pittsburgh"
~/.local/bin/textimg --background 26,1,60,255 -i "$(curl --silent "wttr.in/$town?u")" -f /nix/store/z4rkp7cxd7p8p0a3rwxwasmv5zrkf89z-nerdfonts-3.0.2/share/fonts/truetype/NerdFonts/JetBrainsMonoNLNerdFont-ExtraBoldItalic.ttf -o "$img"
sxiv -baZ -g 1250x854 $img
