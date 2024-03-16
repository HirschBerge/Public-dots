#!/usr/bin/env sh

clip=$(wl-paste)
echo $clip
if [[ $1 == *"http"* ]]; then
  url=$1
elif [[ $clip == *"http"* ]]; then
  url=$clip
else
  echo "No URL found"
fi
mpv --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='bestvideo[ext=mp4][height<=?1080]+bestaudio[ext=m4a]' --msg-level=all=no,ytdl_hook=trace --fs=yes $url >/dev/null 2>&1 &
notify-send "Watching a YouTube video." "$url"
clear
exit
