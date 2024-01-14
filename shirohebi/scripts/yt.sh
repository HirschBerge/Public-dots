#!/bin/sh

clip=$(wl-paste)
echo $clip
if [[ $1 == *"http"* ]]; then
  url=$1
elif [[ $clip == *"http"* ]]; then
  url=$clip
else
  echo "No URL found"
fi

mpv --ao=pulse --script-opts=ytdl_hook-ytdl_path=yt-dlp --msg-level=all=no,ytdl_hook=trace --fs=yes $url >/dev/null 2>&1 &
clear
exit
