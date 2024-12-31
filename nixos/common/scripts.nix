{pkgs, ...}: {
  home.packages = [
    (pkgs.writeScriptBin "setbg"
      /*
      bash
      */
      ''
         #!/usr/bin/env bash
         # Checks to make sure that an argument is passed and if it does, it sends a notification and changes the bg
        [ -n "$1" ] && notify-send -i "$1" "Wallpaper changed." && swww img "$1"
      '')
    (pkgs.writeScriptBin "fzf_previewer"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        function file_info() {
          local path="$1"

          # Check if the provided argument is a valid path
          if [[ ! -e "$path" ]]; then
            echo ""
            return
          fi

          # Get file type using 'file' command
          local file_type
          file_type=$(file "$path")

          if [[ "$file_type" == *"image"* ]] || [[ "$file_type" == *"Media"* ]] || [[ "$file_type" == *"JPEG"* ]] || [[ "$file_type" == *"Matroska"* ]] || [[ "$file_type" == *"Audio"* ]] ; then
            ${pkgs.mediainfo}/bin/mediainfo "$path"
          elif [[ "$file_type" == *"directory"* ]]; then
            eza --icons always --git --group-directories-first --header -o --no-permissions --hyperlink -l --color always "$path"
          elif [[ "$file_type" == *"text"* ]]; then
            bat --style=header-filename,header-filesize --theme=OneHalfDark --color=always --paging=never "$path"
          else
            echo ""
          fi
        }
        file_info "$1"
      '')
    (pkgs.writeScriptBin "gitstatus"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        if [ ! -d .git ]; then
            cd ~/.dotfiles || { echo "Failed to change directory to ~/.dotfiles"; exit 1; }
        fi
        case $1 in
          --files)
            result=$(git diff --shortstat | awk -F',' '{ print $1 }' | awk '{ print $1 }')
            [ -z "$result" ] && echo 0 || echo $result
            ;;
          --add)
            result=$(git diff --shortstat | rg -oP '(?<=,\s)[^,]+?(?=\sinsert)')
            [ -z "$result" ] && echo 0 || echo $result
            ;;
          --sub)
            result=$(git diff --shortstat | rg -oP '(?<=,\s)[^,]+?(?=\sdeletions)')

            [ -z "$result" ] && echo 0 || echo $result
            ;;
          --name)
          result=$(git config --get remote.origin.url |xargs basename -s .git)
            [ -z "$result" ] && echo "Not a repo" || echo $result
            ;;
          --branch)
          result=$(git rev-parse --abbrev-ref HEAD)
            [ -z "$result" ] && echo "Not a repo" || echo $result
          ;;
          *)
            echo "Invalid option. Please provide --files,--branch, --add, --name, or --sub."
            ;;
        esac
      '')
    (pkgs.writeScriptBin "yt"
      /*
      bash
      */
      ''
        #!/usr/bin/env sh
        clip=$(wl-paste)
        if [[ $1 == *"http"* ]]; then
          url=$1
        elif [[ $clip == *"http"* ]]; then
          url=$clip
        else
          echo "No URL found"
          echo "your clipboard contained: $clip"
          notify-send "No URL found" "your clipboard contained: $clip"
          exit
        fi
        meta="$(yt-dlp --cookies-from-browser firefox --print "%(channel)s - %(duration>%H:%M:%S)s - %(title)s" "$clip")"
        channel="$(echo "$meta" |awk -F" - " '{ print $1 }')"
        length="$(echo "$meta" |awk -F" - " '{ print $2 }')"
        title="$(echo "$meta" |awk -F" - " '{ print $3 }')"

        no_vid() {
          echo "Watching a Video from *$channel.*" "$length - $title"
          mpv $url >/dev/null --input-ipc-server=/tmp/mpvsocket 2>&1 &
          notify-send "Watching a Video from *$channel.*" "$length - $title" -a "YouTube"
          host="$(hostname)"
          if [ "shirohebi" = "$host" ];
          then
            hyprctl dispatch workspace 8
          else
            hyprctl dispatch workspace 9
          fi
        }

        yes_vid() {
          echo '{ "command": [ "loadfile", "'$url'", "append-play" ] }' | ${pkgs.socat}/bin/socat - /tmp/mpvsocket > /dev/null 2>&1 &
          echo "Added a video from *$channel.* to the queue" "$length - $title"
          notify-send "Added a video from $channel." "$length - $title" -a "YouTube"
        }

        if pgrep -x "mpv" > /dev/null; then
          yes_vid
        else
          no_vid
        fi
        # clear
        # exit
      '')
    (
      pkgs.writeScriptBin "hyprland_bindings"
      #nushell
      /*
      nu
      */
      ''
        #!/usr/bin/env nu
        def run_hyprctl_binds [] {
             let bind_map = [[modmask, name]; [64, "Super"] [65, "Super Shift"] [8, "Alt"]]
             let updated_binds = hyprctl binds -j |from json |where has_description == true |select modmask key description dispatcher arg | each {|bind| $bind | update modmask ($bind_map | where modmask == ($bind |get modmask)|get name|to text)}|to json
             let choice = $updated_binds | from json | select description | to text | cut -d ' ' -f 2- | rofi -dmenu -i -p "Select Bind"
             if $choice != "" {
                 let selected = ($updated_binds | from json | where description == $choice | first)
                 $selected | print
                 hyprctl dispatch $selected.dispatcher $selected.arg ; notify-send -a nixos-logo "Binding is:" $"($selected.modmask) + ($selected.key)"
             }
         }
         run_hyprctl_binds
      ''
    )
    (pkgs.writeScriptBin "find_window"
      /*
      nu
      */
      ''
        #!/usr/bin/env nu
        def focus_window [] {
             let window_list = hyprctl clients -j | from json | sort-by focusHistoryID| each {|client|
                 if $client.title != "" {
                     # Use client title and address for selection
                     {title: $client.title, address: $"address:($client.address)"}
                 }
             } | where $it.title != "" | to json

             # Get the user's selection from rofi
             let choice = $window_list | from json | select title | to text | cut -d ' ' -f 2- | rofi -dmenu -i -p "Select Window"
             # Check if a choice was made
             if $choice != "" {
                 let selected = ($window_list | from json | where title == $choice |first)
         $selected |print
                 # Focus the selected window
                 if $selected != null {
                     echo "Focusing on window: $selected.title"
                     hyprctl dispatch focuswindow $selected.address
                 }
             }
         }
        focus_window
      '')
    (pkgs.writeScriptBin "implant_metadata"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        # NOTE: Script that takes metadata in .nfo format (like generated from `tvdb` script) and implants it into the files of the actual file.
        for nfo in *.nfo; do
            # Extract the episode number from the .nfo file name (e.g., S13E01)
            episode=$(echo "$nfo" | grep -o 'S[0-9]\+E[0-9]\+')

            # Find the corresponding video file (e.g., S13E01 Ougi Formula.mp4)
            video=$(ls "$episode"*.mp4 2>/dev/null)

            if [[ -z "$video" ]]; then
                echo "No corresponding video found for $nfo"
                continue
            fi
            # ffmpeg -i $video 2>&1 | rg -q "(title|comment|date|desc)" && echo "There is already Metadata present for $video."; continue || echo "Starting with $nfo"

            # Parse metadata from the .nfo file
            title=$(grep -oP '(?<=<title>).*?(?=</title>)' "$nfo")
            plot=$(grep -oP '(?<=<plot>).*?(?=</plot>)' "$nfo")
            director=$(grep -oP '(?<=<director>).*?(?=</director>)' "$nfo")
            credits=$(grep -oP '(?<=<credits>).*?(?=</credits>)' "$nfo")
            aired=$(grep -oP '(?<=<aired>).*?(?=</aired>)' "$nfo")
            thumb=$(grep -oP '(?<=<thumb>).*?(?=</thumb>)' "$nfo")

            # If any of the metadata is missing, skip processing this file
            if [[ -z "$title" && -z "$plot" ]]; then
                echo "Missing metadata in $nfo, skipping."
                continue
            fi

            # Embed metadata into the video file using ffmpeg for mp4 files
            # echo -en "\n$title\n$plot\n$director\n$credits\n$aired\n$thumb\n"
            echo "Processing $video with metadata from $nfo"

            ffmpeg -i "$video" -metadata title="$title" -metadata description="$plot" \
                -metadata director="$director" -metadata writer="$credits" \
                -metadata date="$aired" -metadata comment="$thumb" \
                -codec copy "temp_$video"> /dev/null 2>&1

            mv "temp_$video" "$video"

            echo "Finished embedding metadata for $video"
        done
      '')
    (pkgs.writeScriptBin "tvdb"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        # Define your variables
        if [[ "$1" == "season" ]];then
          input_file="./szn.list"
          # Loop over each line in the file
          while IFS=: read -r episode_name episode_id; do
              # Run tvdb command and redirect output to a .nfo file
              tvdb "$episode_id" > "$episode_name.nfo"
          done < "$input_file"
          exit 0
        fi
        API_KEY="9919b6c7-c697-4cc6-9f5d-bc9f5b5a92e5"  # Example dummy key. Replace with your own. It's free
        check_bearer() {
            if [ -z "$BEARER" ]; then
                echo "Creds not set To set it run:
                    curl -X 'POST' 'https://api4.thetvdb.com/v4/login' \
                        -H 'accept: application/json' \
                        -H 'Authorization: Bearer $API_KEY' \
                        -H 'Content-Type: application/json' \
                        -d '{\"apikey\": \"$API_KEY\", \"pin\": \"1234\"}' | jq -r .data.token > \"$HOME/.cache/tvdb.creds\"
                    or in NuShell:
                    curl -X 'POST' 'https://api4.thetvdb.com/v4/login' -H 'accept: application/json' -H 'Authorization: Bearer $API_KEY' -H 'Content-Type: application/json' -d '{
                    \"apikey\": \"$API_KEY\",
                    \"pin\": \"1234\"
                    }' |from json |get data.token |save -f $HOME/.cache/tvdb.creds
                    "
                    exit
            elif  [ -n "$1" ]; then
                echo "Update TVDB_BEARER by running:
                    curl -X 'POST' 'https://api4.thetvdb.com/v4/login' \
                        -H 'accept: application/json' \
                        -H 'Authorization: Bearer $API_KEY' \
                        -H 'Content-Type: application/json' \
                        -d '{\"apikey\": \"$API_KEY\", \"pin\": \"1234\"}' | jq -r .data.token > \"$HOME/.cache/tvdb.creds\"
                    or in NuShell:
                    curl -X 'POST' 'https://api4.thetvdb.com/v4/login' -H 'accept: application/json' -H 'Authorization: Bearer $API_KEY' -H 'Content-Type: application/json' -d '{
                    \"apikey\": \"$API_KEY\",
                    \"pin\": \"1234\"
                    }' |from json |get data.token |save -f $HOME/.cache/tvdb.creds
                    "
            else
              echo ""
            fi

            exit
        }
        BEARER="$(<"$HOME/.cache/tvdb.creds")"
        # SHOW_ID="SHOW_ID"        # Replace with the ID of the show
        if [ -n "$1" ]; then
            # If $1 exists, set the variable
            EPISODE_ID="$1"
        else
            # If $1 doesn't exist, prompt for it
            read -rp "Please enter a value: " EPISODE_ID
        fi

        # Fetch episode data from TheTVDB API
        eng=$(curl -s -H "Authorization: Bearer $BEARER" "https://api4.thetvdb.com/v4/episodes/$EPISODE_ID/translations/eng")
        if [[ ! "$eng" =~ [Ss]uccess ]]; then
            echo "Your bearer might have expired, please refresh it:"
            check_bearer tacos
        fi
        sleep 0.5
        jp=$(curl -s -H "Authorization: Bearer $BEARER" "https://api4.thetvdb.com/v4/episodes/$EPISODE_ID")
        # printf "%s" "$response" |jq
        # Extract the required information using jq
        title=$(echo "$eng" | jq -r '.data.name')                    # Episode title
        plot=$(echo "$eng" | jq -r '.data.overview')                 # Episode description
        aired=$(echo "$jp" | jq -r '.data.aired')                   # Air date
        image=$(echo "$jp" | jq -r '.data.image')                   # Thumbnail URL
         if [ "$plot" = "null" ]; then
           plot=""
         fi
         if [ "$aired" = "null" ]; then
           aired=""
         fi
         if [ "$image" = "null" ]; then
           image=""
         fi
         if [ "$image" = "null" ]; then
          title=$(echo "$jp" | jq -r '.data.name')                    # Episode title
         fi
        # Optionally extract director and credits if available; adjust as necessary
        # Since this data isn't present in the given JSON, we'll leave those empty
        director=""    # Set to empty or fetch from another API if necessary
        credits=""     # Set to empty or fetch from another API if necessary

        # Generate XML
        xml_output="<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\n"
        xml_output+="<episodedetails>\n"
        xml_output+="  <plot>$plot</plot>\n"
        xml_output+="  <title>$title</title>\n"
        xml_output+="  <director>$director</director>\n"
        xml_output+="  <credits>$credits</credits>\n"
        xml_output+="  <aired>$aired</aired>\n"
        xml_output+="  <thumb>$image</thumb>\n"  # Use the image URL
        xml_output+="</episodedetails>"

        # Print the XML output
        echo -e "$xml_output" |bat --language=xml
      '')
    (pkgs.writeScriptBin "ex"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        if [ -f "$1" ] ; then
           case "$1" in
             *.tar.bz2)   ${pkgs.gnutar}/bin/tar xjf "$1"   ;;
             *.tar.gz)    ${pkgs.gnutar}/bin/tar xzf "$1"   ;;
             *.bz2)       ${pkgs.bzip2}/bin/bunzip2 "$1"   ;;
             *.rar)       ${pkgs.unrar}/bin/unrar x "$1"     ;;
             *.gz)        ${pkgs.gzip}/bin/gunzip "$1"    ;;
             *.tar)       ${pkgs.gnutar}/bin/tar xf "$1"    ;;
             *.tbz2)      ${pkgs.gnutar}/bin/tar xjf "$1"   ;;
             *.tgz)       ${pkgs.gnutar}/bin/tar xzf "$1"   ;;
             *.zip)       ${pkgs.unzip}/bin/unzip "$1"     ;;
             *.Z)         uncompress "$1";;
             *.7z)        ${pkgs.p7zip}/bin/7z x "$1"      ;;
             *.tar.xz)    ${pkgs.gnutar}/bin/tar -xf "$1"   ;;
             *)           printf "\033[1;31m[✗] \033[1;33m'$1' \033[0mcannot be extracted via ex()\033[0m" ;;
           esac
             else
               echo "'$1' is not a valid file"
        fi
      '')
    (pkgs.writeScriptBin "rustbuild"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        init="$(pwd)"
        option=build
        # Loop through each directory in ~/projects
        for dir in ~/projects/*; do
            # Check if it is a directory
            if [ -d "$dir" ]; then
                # Check if Cargo.toml exists in the directory
                if [ -f "$dir/Cargo.toml" ]; then
                    dir_name=$(basename "$dir")
                    # Change to the project directory
                    cd "$dir" || return
                    printf "\033[32m[+]\033[0m Building \033[34m%s\033[0m\n" "$dir_name"
                    sleep 1
                    # Develop and build the project, redirecting stdout to /dev/null but keeping stderr intact
                    if [ "$option" = run ]; then
                        nix develop -c cargo build --release
                    elif [ "$option" = build ]; then
                        nix develop -c cargo build --release >/dev/null 2>&1
                    else
                        printf "\033[31m[✗]\033[0m Bad option\n"
                        break
                    fi
                fi
            fi
        done
        cd "$init"
      '')
    (pkgs.writeScriptBin "rustupdate"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        init="$(pwd)"
        option=build
        # Loop through each directory in ~/projects
        for dir in ~/projects/*; do
            # Check if it is a directory
            if [ -d "$dir" ]; then
                # Check if Cargo.toml exists in the directory
                if [ -f "$dir/Cargo.toml" ]; then
                    dir_name=$(basename "$dir")
                    # Change to the project directory
                    cd "$dir" || return
                    # Git pull, redirecting all output to /dev/null
                    if git remote -v >/dev/null 2>&1; then
                      if git pull >/dev/null 2>&1; then
                          printf "\033[32m[+]\033[0m Git pull successful for \033[34m%s\033[0m\n" "$dir_name"
                      else
                          printf "\033[31m[✗]\033[0m Git pull failed for \033[34m%s\033[0m\n" "$dir_name"
                      fi
                    fi
                    sleep 1
                    # Update the flake, redirecting stdout to /dev/null but keeping stderr intact
                    printf "\033[32m[+]\033[0m Updating \033[34m%s\033[0m\n" "$dir_name"
                    nix flake update >/dev/null 2>&1
                    git commit -am "Automated flake update." >/dev/null 2>&1
                    if git remote -v >/dev/null 2>&1; then
                      if git push >/dev/null 2>&1; then
                          printf "\033[32m[+]\033[0m Git push successful for \033[34m%s\033[0m\n" "$dir_name"
                      else
                          printf "\033[31m[✗]\033[0m Git push failed for \033[34m%s\033[0m\n" "$dir_name"
                      fi
                    fi
                    printf "\033[32m[+]\033[0m Building \033[34m%s\033[0m\n" "$dir_name"
                    sleep 1
                    # Develop and build the project, redirecting stdout to /dev/null but keeping stderr intact
                    if [ "$option" = run ]; then
                        nix develop -c cargo build --release
                    elif [ "$option" = build ]; then
                        nix develop -c cargo build --release >/dev/null 2>&1
                    else
                        printf "\033[31m[✗]\033[0m Bad option\n"
                        break
                    fi
                fi
            fi
        done
        cd "$init"
      '')
    (pkgs.writeScriptBin "nhhome"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        rm_path="$HOME/.mozilla/firefox/USER_NAME/search.json.mozlz4"
        rm -f "$rm_path"
        nh home switch
      '')
    (pkgs.writeScriptBin "nhupdate"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash

        rm_path="$HOME/.mozilla/firefox/USER_NAME/search.json.mozlz4"
        icon_path="$HOME/.config/notification_icons/nixos-logo.svg"
        dotfiles_path="$HOME/.dotfiles"
        message="Update complete"

        update_flake() {
          cd "$dotfiles_path" || { echo "Failed to change directory to $dotfiles_path"; exit 1; }
          git add flake.lock
          git commit -S -m "Updated flake."
        }

        revert_flake() {
          cd "$dotfiles_path" || { echo "Failed to change directory to $dotfiles_path"; exit 1; }
          git restore flake.lock
          echo "Update failed, flake.lock has been reverted."
        }

        run_updates() {
          nh os boot --update && rm -f "$rm_path" && nh home switch && update_flake || revert_flake
        }

        send_notification() {
          response=$(timeout 10 notify-send -u normal -e -A "Reboot" -A "Nothing" "NH Update Helper" "$message" -i "$icon_path")
          echo "$response"
        }

        handle_response() {
          case "$response" in
              0)
                  reboot
                  ;;
              1)
                  # Do nothing
                  ;;
              *)
                  echo "Invalid response: $response"
                  ;;
          esac
        }

        # Run updates
        run_updates

        # Send notification and handle response
        response=$(send_notification)
        # handle_response
      '')
    (pkgs.writeScriptBin "nhfull"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        rm_path="$HOME/.mozilla/firefox/USER_NAME/search.json.mozlz4"
        nh os switch
        rm -f "$rm_path"
        nh home switch
      '')
    (pkgs.writeScriptBin "rust4zellij"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        nix develop -c v src/main.rs
      '')
    (
      pkgs.writeScriptBin "pr_tracker"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        cache_path="$HOME/.cache/pr_tracker.log"
        PR=$(<"$HOME/.cache/PR_tracker.txt")
        IS_COMPLETED=$(<"$HOME/.cache/pr_tracker_finished.txt")
        data=$(timeout 45 curl -sLf "https://nixpk.gs/pr-tracker.html?pr=$PR")

        title=$(echo "$data" |
            rg title |
            rg -oP '(?<=\().+?(?=\))' |
            sd "\-&gt;" "  " |
            sd '"' "" |
            tr '[:lower:]' '[:upper:]' |
            sed 's/\([[:alpha:]]\)\([[:alpha:]]*\)/\u\1\L\2/g'
        )

        statuses=$(echo "$data" |
            rg -v li |
            rg "state" -A2 |
            rg -oP '(?<=>).+?(?=<)' |
            awk 'NR%2{emoji=$0; next} {print $0 ":" emoji}' |
            sd "⚪" " " |
            sd "✅" " "
        )

        master=$(echo "$statuses" | rg "master" | awk -F':' '{ print $2 }')
        small=$(echo "$statuses" | rg "small" | awk -F':' '{ print $2 }')
        nix_pkgs=$(echo "$statuses" | rg "nixpkgs" | awk -F':' '{ print $2 }')
        unstable=$(echo "$statuses" | rg -v "small" | rg "nixos" | awk -F':' '{ print $2 }')

        url="https://github.com/NixOS/nixpkgs/pull/$PR"

        json_output=$(printf '{"title": "%s", "master": "%s", "small": "%s", "nix_pkgs": "%s", "unstable": "%s", "url": "%s"}' \
            "$title" "$master" "$small" "$nix_pkgs" "$unstable" "$url")
        if [ -z "$title" ]; then
          cat "$cache_path" | jq
        else
          echo "$json_output" | tee $cache_path | jq
        fi
        if [[ "$IS_COMPLETED" != "$PR" ]]; then
            #NOTE: Only sends the notification ifthe computer is actively being used.
            if ! echo "$unstable" | grep -q '' && [ "$(hyprctl monitors -j | jq 'any(.[]; .dpmsStatus == true)')" = "true" ]; then
                echo "$PR" > ~/.cache/pr_tracker_finished.txt
                notify-send -a 'nixos-logo' "$title" "PR $PR has hit unstable."
            fi
        fi
      ''
    )
    (
      pkgs.writeScriptBin "pings"
      #nushell
      /*
      nu
      */
      ''
        #!/usr/bin/env nu
        let hosts = [
            {name: "ProxNode0", ip: "10.10.10.3"},
            {name: "ProxNode1", ip: "10.10.10.4"},
            {name: "ProxNode2", ip: "10.10.10.5"},
            {name: "TrueNas", ip: "10.10.10.10"},
            {name: "Docker", ip: "10.10.10.53"},
            {name: "KumaProd", ip: "10.10.10.51"},
            {name: "KumaBack", ip: "10.10.10.83"},
            {name: "PiHole", ip: "10.10.10.54"},
            {name: "HACS", ip: "10.10.10.19"}
        ]

        let dns_output = (try { nix-shell -p dnsutils --run 'dig +short nas-prod-dir.home.USER_NAMEkiss.net' } catch { echo "Failed" })

        let dns_result = if ($dns_output | lines | first | default "" | str length) > 0 {
            let ip = ($dns_output | lines | first)
            {name: "DNS Test", ip: $ip, status: (if $ip == "10.10.10.10" { "Resolved Correctly" } else { "Resolved Incorrectly" })}
        } else {
            {name: "DNS Test", ip: "none", status: "Unresolved"}
        }


        let results = ($hosts | each {|host|
            let ping_output = (try { ping $host.ip -c 1 } catch { echo "Failed" })
            let status = (if ($ping_output | str contains "1 received") { "Reachable" } else { "Unreachable" })
            {name: $host.name, ip: $host.ip, status: $status}
        })

        ($results | append $dns_result) | table
      ''
    )
    (pkgs.writeScriptBin "toradd"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        if ! pgrep -x rqbit > /dev/null; then
          rqbit server start ~/.rtorrent/download/ &
          sleep 3
          xdg-open http://localhost:3030/web/
        fi
        rqbit download "$1"

        # watch_folder=~/.rtorrent/watch/start/
        #  cd $watch_folder || exit
        #  [[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit;
        #  echo "d10:magnet-uri$(echo -n "$1" | wc -c):$1e"> "meta-''${BASH_REMATCH[1]^^}.torrent"
        notify-send -u normal "Torrent Added!" "Adding to rqbit" -a "Rtorrent"
      '')
    (pkgs.writeScriptBin "dmenupass"
      /*
      bash
      */
      ''
        #!/usr/bin/env sh

        # This script is the SUDO_ASKPASS variable, meaning that it will be used as a
        # password prompt if needed.

        rofi -dmenu -config ~/.config/rofi/launchers/type-1/style-3.rasi -display "enter password" -p "$1" <&- && echo
      '')
    (pkgs.writeScriptBin "toggle_desk"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        token="$(echo 'ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKaE9UZ3daRFkwTlRsak1qWTBNak01T1RN
        eE4yRXlNamxoWldKa09EQmtPQ0lzSW1saGRDSTZNVGN5TVRNME5UTXpNU3dpWlhod0lqb3lNRE0yTnpBMU16TXhmUS40dV9tVFM5RUVWcXZab3R
        QbC1vWEZmTnFMQjFWLWFCVWt4bnZLWEY2Wi1jCg=='|base64 -d)"
        desk_lite(){
          curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "light.desk_rope_lite"}' http://10.10.10.19:8123/api/services/light/toggle
        }
        all_off(){
          curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "scene.all_off"}' http://10.10.10.19:8123/api/services/scene/turn_on
        }
        dim_house(){
          curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "scene.new_scene"}' http://10.10.10.19:8123/api/services/scene/turn_on
        }
        dryer(){
              curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "script.1678671948073"}' http://10.10.10.19:8123/api/services/script/toggle
        }
        washing(){
              curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "script.laundry_washing_machine"}' http://10.10.10.19:8123/api/services/script/toggle
        }
        pizza(){
              curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{"entity_id": "script.pizza_23_minutes"}' http://10.10.10.19:8123/api/services/script/toggle
        }
        usage() {
          echo "Usage: $0 [-d | --desk_lite] [-a | --all_off] [-h | --dim_house] [-D | --dryer] [-w | --washing] [ -p | --pizza ]"
          exit 1
        }

        # Check if no arguments were provided
        if [ $# -eq 0 ]; then
          usage
        fi

        # Parse the command-line arguments
        while [[ "$#" -gt 0 ]]; do
          case $1 in
            -d|--desk_lite)
              desk_lite |jq
              shift
              ;;
            -a|--all_off)
              all_off |jq
              shift
              ;;
            -h|--dim_house)
              dim_house |jq
              shift
              ;;
            -w|--washing)
              washing |jq
              shift
              ;;
            -D|--dryer)
              dryer |jq
              shift
              ;;
            -p|--pizza)
              pizza |jq
              shift
              ;;
            *)
              echo "Unknown option: $1"
              usage
              ;;
          esac
        done
      '')
    (pkgs.writeScriptBin "network-toggle"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        interface="enp7s0"

        # Get the current status of the interface
        status=$(nmcli device status | grep "$interface" | awk '{print $3}')

        # Toggle the interface status and send a notification
        if [ "$status" = "connected" ]; then
            echo "Disconnecting $interface..."
            nmcli device disconnect "$interface"
            notify-send -i $HOME/.dotfiles/streamdeck_icons/network.png "Network Status" "$interface disconnected"
        elif [ "$status" = "disconnected" ]; then
            echo "Connecting $interface..."
            nmcli device connect "$interface"
            notify-send -i $HOME/.dotfiles/streamdeck_icons/network.png "Network Status" "$interface connected"
        else
            echo "Unknown status for $interface: $status"
            notify-send -i dialog-warning "Network Status" "Unknown status for $interface: $status"
        fi
      '')
    (pkgs.writeScriptBin "net_toggle"
      #nushell
      /*
      nu
      */
      ''
        #!/usr/bin/env nu

         $"Interface,IP,MAC\n(ip a | rg -A3 'enp|wlo'|rg -v altname | rg -B1 'inet ' | sed 's,/24.*noprefixroute,,' | awk ' /link\/ether/ {mac=$2} /inet/ {ip=$2; iface=$NF; print iface "," ip "," mac} ')"|from csv |print
        let interface = (ip a |awk "/[0-9]: / { print $2 }" |sd ":" "" |sd "lo" iface |from csv |input list ).iface
        # Check the current status of the interface
        let status = (nmcli device status | grep $"($interface)" | awk '{print $3}')
        # Toggle the interface status and send a notification
        if $status == "connected" {
            echo $"Disconnecting ($interface)..."
            nmcli device disconnect $interface
            notify-send -a 'network' "Network Status" $"($interface) disconnected"
        } else if $status == "disconnected" {
            echo $"Connecting ($interface)..."
            nmcli device connect $interface
            notify-send -a 'network' "Network Status" $"($interface) connected"
        } else {
            echo $"Unknown status for ($interface): ($status)"
            notify-send -a "error" "Network Status" $"Unknown status for ($interface): ($status)"
        }
      '')
    (pkgs.writeScriptBin "locktoggle"
      /*
      bash
      */
      ''
        #!/usr/bin/env bash
        status=$(hyprctl monitors -j | jq 'any(.[]; .dpmsStatus == false)')
        if [ "false" = "$status" ]; then
          hyprlock &
          hyprctl dispatch dpms off
        else
          hyprctl dispatch dpms on
        fi
      '')
    (pkgs.writeScriptBin "dmenuumount"
      /*
      bash
      */
      ''
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
    (pkgs.writeScriptBin "dmenuunicode"
      /*
      bash
      */
      ''
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
    (pkgs.writeScriptBin "eww_launch"
      #nushell
      /*
      nu
      */
      ''
        #!/usr/bin/env nu
        sleep 1sec

        # Attempt to kill existing eww-wrapped processes
        ps -l | where name =~ "eww-wrapped" | each {|instance|
            try {
               kill $instance.pid
            } catch {
                echo $"Could not kill ($instance.pid)"
            }
        }

        # Start the eww daemon
        eww daemon

        # Open eww widgets
        if (hostname ) == "yoitsu" {
          ${pkgs.eww}/bin/eww open notifications
          ${pkgs.eww}/bin/eww open sidebar
          ${pkgs.eww}/bin/eww -c ~/.config/eww/bar open bar
        } else {
          ${pkgs.eww}/bin/eww open notifications
          ${pkgs.eww}/bin/eww open bar
         }

        # Sleep to allow eww to start up
        sleep 3sec

        # Send a notification
        notify-send -a 'nixos-logo' "Eww Restarted" "Enjoy your day."
      '')
    (pkgs.writeScriptBin "tordone"
      /*
      bash
      */
      ''
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
        response=$(timeout 10 notify-send -u normal -e -A "Open in Thunar" -A "Open in Ranger" -A "Dismiss" "Torrent Completed" "$tor_name" -a Rtorrent )

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
    (pkgs.writeScriptBin "dmenumount"
      /*
      bash
      */
      ''
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
