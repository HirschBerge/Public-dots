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
meta="$(yt-dlp --print "%(channel)s - %(duration>%H:%M:%S)s - %(title)s" "$clip")"
channel="$(echo "$meta" |awk -F" - " '{ print $1 }')"
length="$(echo "$meta" |awk -F" - " '{ print $2 }')"
title="$(echo "$meta" |awk -F" - " '{ print $3 }')"
mpv --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='bestvideo[ext=mp4][height<=?1080]+bestaudio[ext=m4a]' --msg-level=all=no,ytdl_hook=trace --fs=yes $url >/dev/null 2>&1 &
notify-send "Watching a Video from *$channel.*" "$length - $title" -a "YouTube" --icon ~/.cache/youtube.svg
clear
exit
