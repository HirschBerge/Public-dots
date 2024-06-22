{
  pkgs,
  ...
}:
{
  home.packages = [
    (pkgs.writeScriptBin "setbg" /*bash*/ ''
      #!/usr/bin/env bash
      # Checks to make sure that an argument is passed and if it does, it sends a notification and changes the bg
     [ -n "$1" ] && notify-send -i "$1" "Wallpaper changed." && swww img "$1"
     '')
    (pkgs.writeScriptBin "yt" /*bash*/ ''
#!/usr/bin/env sh
clip=$(wl-paste)
if [[ $1 == *"http"* ]]; then
  url=$1
elif [[ $clip == *"http"* ]]; then
  url=$clip
else
  echo "No URL found"
  echo "your clipboard contained: $clip"
  exit
fi
meta="$(yt-dlp --print "%(channel)s - %(duration>%H:%M:%S)s - %(title)s" "$clip")"
channel="$(echo "$meta" |awk -F" - " '{ print $1 }')"
length="$(echo "$meta" |awk -F" - " '{ print $2 }')"
title="$(echo "$meta" |awk -F" - " '{ print $3 }')"
echo "Watching a Video from *$channel.*" "$length - $title"
mpv $url >/dev/null 2>&1 &
notify-send "Watching a Video from *$channel.*" "$length - $title" -a "YouTube" --icon ~/.cache/youtube.svg
host="$(hostname)"
if [ "shirohebi" = "$host" ];
then
    hyprctl dispatch workspace 8
else
    hyprctl dispatch workspace 9
fi
# clear
# exit
     '')
     ( pkgs.writeScriptBin "toradd" /*bash */ ''
#!/usr/bin/env bash
watch_folder=~/.rtorrent/watch/start/
 cd $watch_folder || exit
 [[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit;
 echo "d10:magnet-uri$(echo -n "$1" | wc -c):$1e"> "meta-''${BASH_REMATCH[1]^^}.torrent"
notify-send -u normal "Torrent Added!" "meta-''${BASH_REMATCH[1]^^}.torrent" -i ~/.config/swaync/tor.png -a "Rtorrent"
      '')
  (pkgs.writeScriptBin "dmenupass" /*bash*/ ''
#!/usr/bin/env sh

# This script is the SUDO_ASKPASS variable, meaning that it will be used as a
# password prompt if needed.

rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -display "enter password" -p "$1" <&- && echo
'')
  (pkgs.writeScriptBin "dmenuumount" /*bash*/ ''
#!/usr/bin/env sh
# A rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi  prompt to unmount drives.
# Provides you with mounted partitions, select one to unmount.
# Drives mounted at /, /boot and /home will not be options to unmount.

unmountusb() {
    [ -z "$drives" ] && exit
    chosen=$(echo "$drives" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi  -i -p "Unmount which drive?" | awk '{print $1}')
    [ -z "$chosen" ] && exit
    sudo -A umount -l "$chosen" && notify-send "💻 USB unmounting" "$chosen unmounted."
    }

unmountandroid() { \
    chosen=$(awk '/simple-mtpfs/ {print $2}' /etc/mtab | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi  -i -p "Unmount which device?")
    [ -z "$chosen" ] && exit
    sudo -A umount -l "$chosen" && notify-send "🤖 Android unmounting" "$chosen unmounted."
    }

asktype() { \
    case "$(printf "USB\\nAndroid" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi  -i -p "Unmount a USB drive or Android device?")" in
        USB) unmountusb ;;
        Android) unmountandroid ;;
    esac
    }

drives=$(lsblk -nrpo "name,type,size,mountpoint" | awk '$2=="part"&&$4!~/\/boot|\/home$|SWAP/&&length($4)>1{printf "%s (%s)\n",$4,$3}')

if ! grep simple-mtpfs /etc/mtab; then
    [ -z "$drives" ] && echo "No drives to unmount." &&  exit
    echo "Unmountable USB drive detected."
    unmountusb
else
    if [ -z "$drives" ]
    then
        echo "Unmountable Android device detected."
               unmountandroid
    else
        echo "Unmountable USB drive(s) and Android device(s) detected."
        asktype
    fi
fi
'')
  (pkgs.writeScriptBin "dmenuunicode" /*bash*/ ''
#!/usr/bin/env sh

# The famous "get a menu of emojis to copy" script.

# Must have xclip installed to even show menu.
wl-copy -h >/dev/null || exit

chosen=$(grep -v "#" ~/.local/share/emoji | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi ) #dmenu -fn "DejaVu Sans" -i -l 20 )

[ "$chosen" != "" ] || exit

c=$(echo "$chosen" | sed "s/ .*//")
echo "$c" | tr -d '\n' | wl-copy
# notify-send "'$c' copied to clipboard." &

s=$(echo "$chosen" | sed "s/.*; //" | awk '{print $1}')
echo "$s" | tr -d '\n' | wl-copy
# notify-send "'$s' copied to primary." &
        '')
  (pkgs.writeScriptBin "tordone" /*bash*/ ''
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
  done 3< "$OLD" 4< "$NEW"
  rm -f "$OLD" "$NEW"
}

touch "$log_path"
echo -en "$time: Completed: $tor_name.\n" >> "$log_path"
response=$(timeout 10 notify-send -u normal -e -A "Open in Thunar" -A "Open in Ranger" -A "Dismiss" "Torrent Completed" "$tor_name" -i "$HOME"/.config/swaync/tor.png)

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
cd "$cdto" || exit

fd . . -e "mkv" -e "mp4" > OLD
if rg "p\." OLD; then
  cat OLD | sed 's/[0-9][0-9][0-9][0-9]p\..*\.\(..\)\([^\.]*\)$/p.\1\2/' |tr '.' ' '| sed 's/ p /\./g'  > NEW
else
  cat OLD | sed 's/[0-9][0-9][0-9][0-9]p .*\.\(..\)\([^\.]*\)$/p.\1\2/' |tr '.' ' '| sed 's/ p /\./g'  > NEW
fi
rename OLD NEW
eza --no-quotes --group-directories-first -l --icons=always
   '')
      ( pkgs.writeScriptBin "dmenumount" /*bash*/''
#!/usr/bin/env sh

# Gives a dmenu prompt to mount unmounted drives and Android phones. If
# they're in /etc/fstab, they'll be mounted automatically. Otherwise, you'll
# be prompted to give a mountpoint from already existsing directories. If you
# input a novel directory, it will prompt you to create that directory.

getmount() { \
    [ -z "$chosen" ] && exit 1
    mp="$(fd . "$1" -td -te -d 1 2>/dev/null | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -i -p "Type in mount point.")"
    [ "$mp" = "" ] && exit 1
    if [ ! -d "$mp" ]; then
        mkdiryn=$(printf "No\\nYes" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -i -p "$mp does not exist. Create it?")
        [ "$mkdiryn" = "Yes" ] && (mkdir -p "$mp" || sudo -A mkdir -p "$mp")
    fi
    }

mountusb() { \
    chosen="$(echo "$usbdrives" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -i -p "Mount which drive?" | awk '{print $1}')"
    sudo -A mount "$chosen" 2>/dev/null && notify-send "💻 USB mounting" "$chosen mounted." && exit 0
    alreadymounted=$(lsblk -nrpo "name,type,mountpoint" | awk '$2=="part"&&$3!~/\/boot|\/home$|SWAP/&&length($3)>1{printf "-not \\( -path *%s -prune \\) \\ \n",$3}')
    getmount "$HOME/.cache"
    partitiontype="$(lsblk -no "fstype" "$chosen")"
    case "$partitiontype" in
        "vfat") sudo -A mount -t vfat "$chosen" "$mp" -o rw,umask=0000;;
        *) sudo -A mount "$chosen" "$mp"; user="$(whoami)"; ug="$(groups | awk '{print $1}')"; sudo -A chown "$user" "$mp";;
    esac
    notify-send "💻 USB mounting" "$chosen mounted to $mp."
    }

mountandroid() { \
    chosen=$(echo "$anddrives" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -i -p "Which Android device?" | cut -d : -f 1)
    getmount "$HOME -maxdepth 3 -type d"
    simple-mtpfs --device "$chosen" "$mp"
    notify-send "🤖 Android Mounting" "Android device mounted to $mp."
    }

asktype() { \
    case $(printf "USB\\nAndroid" | rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -i -p "Mount a USB drive or Android device?") in
        USB) mountusb ;;
        Android) mountandroid ;;
    esac
    }

anddrives=$(simple-mtpfs -l 2>/dev/null)
usbdrives="$(lsblk -rpo "name,type,size,mountpoint" | awk '$2=="part"&&$4==""{printf "%s (%s)\n",$1,$3}')"

if [ -z "$usbdrives" ]; then
    [ -z "$anddrives" ] && echo "No USB drive or Android device detected" && exit
    echo "Android device(s) detected."
    mountandroid
else
    if [ -z "$anddrives" ]; then
        echo "USB drive(s) detected."
        mountusb
    else
        echo "Mountable USB drive(s) and Android device(s) detected."
        asktype
    fi
fi
'')
  ];
}
