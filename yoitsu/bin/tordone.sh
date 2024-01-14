#!/usr/bin/env bash
tor_name="$1"
torrent_path="$HOME/.rtorrent/download/"
log_path="$HOME/.rtorrent/tor.log"
time=$(date)

function rename(){
  OLD=$1
  NEW=$2
  while IFS= read -r old <&3 && IFS= read -r new <&4; do
    echo -en "$(date): renamed: $old to $new\n" >> $log_path
	 mv -i -- "$old" "$new"
  done 3< $OLD 4< $NEW
  rm -f $OLD $NEW
}

touch $log_path
echo -en "$time: Completed: $tor_name.\n" >> $log_path
response=$(timeout 10 notify-send -u normal -e -A "Open in Thunar" -A "Open in Ranger" -A "Dismiss" "Torrent Completed" "$tor_name" -i $HOME/.config/swaync/tor.png)

case "$response" in
    0)
        # If $response is 0, run thunar $torrent_path
        thunar "$torrent_path" &
        ;;
    1) 
      kitty ranger "$torrent_path" &
        # If $response is 1 or null, do nothing (continue)
        ;;
    *)
        # Handle other cases if needed
        echo "Invalid response: $response"
        ;;
esac

cdto=$(fd -td --fixed-strings "$tor_name" ~/.rtorrent)
cd "$cdto"

ls |rg "mkv|mp4" > OLD
if rg "p\." OLD; then
  cat OLD | sed 's/[0-9][0-9][0-9][0-9]p\..*\.\(..\)\([^\.]*\)$/p.\1\2/' |tr '.' ' '| sed 's/ p /\./g'  > NEW
else
  cat OLD | sed 's/[0-9][0-9][0-9][0-9]p .*\.\(..\)\([^\.]*\)$/p.\1\2/' |tr '.' ' '| sed 's/ p /\./g'  > NEW
fi
rename OLD NEW
eza --no-quotes --group-directories-first -l --icons=always

