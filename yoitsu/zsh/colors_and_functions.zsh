            NoColor="\033[0m"
            Black='\033[0;30m'        # Black
            Red='\033[0;31m'          # Red
            Green='\033[0;32m'        # Green
            Yellow='\033[0;33m'       # Yellow
            Blue='\033[0;34m'         # Blue
            Purple='\033[0;35m'       # Purple
            Cyan='\033[0;36m'         # Cyan
            White='\033[0;37m'        # White

            # Bold
            BBlack='\033[1;30m'       # Black
            BRed='\033[1;31m'         # Red
            BGreen='\033[1;32m'       # Green
            BYellow='\033[1;33m'      # Yellow
            BBlue='\033[1;34m'        # Blue
            BPurple='\033[1;35m'      # Purple
            BCyan='\033[1;36m'        # Cyan
            BWhite='\033[1;37m'       # White

            # Underline
            UBlack='\033[4;30m'       # Black
            URed='\033[4;31m'         # Red
            UGreen='\033[4;32m'       # Green
            UYellow='\033[4;33m'      # Yellow
            UBlue='\033[4;34m'        # Blue
            UPurple='\033[4;35m'      # Purple
            UCyan='\033[4;36m'        # Cyan
            UWhite='\033[4;37m'       # White

            # Background
            On_Black='\033[40m'       # Black
            On_Red='\033[41m'         # Red
            On_Green='\033[42m'       # Green
            On_Yellow='\033[43m'      # Yellow
            On_Blue='\033[44m'        # Blue
            On_Purple='\033[45m'      # Purple
            On_Cyan='\033[46m'        # Cyan
            On_White='\033[47m'       # White

            # High Intensity
            IBlack='\033[0;90m'       # Black
            IRed='\033[0;91m'         # Red
            IGreen='\033[0;92m'       # Green
            IYellow='\033[0;93m'      # Yellow
            IBlue='\033[0;94m'        # Blue
            IPurple='\033[0;95m'      # Purple
            ICyan='\033[0;96m'        # Cyan
            IWhite='\033[0;97m'       # White

            # Bold High Intensity
            BIBlack='\033[1;90m'      # Black
            BIRed='\033[1;91m'        # Red
            BIGreen='\033[1;92m'      # Green
            BIYellow='\033[1;93m'     # Yellow
            BIBlue='\033[1;94m'       # Blue
            BIPurple='\033[1;95m'     # Purple
            BICyan='\033[1;96m'       # Cyan
            BIWhite='\033[1;97m'      # White

            # High Intensity backgrounds
            On_IBlack='\033[0;100m'   # Black
            On_IRed='\033[0;101m'     # Red
            On_IGreen='\033[0;102m'   # Green
            On_IYellow='\033[0;103m'  # Yellow
            On_IBlue='\033[0;104m'    # Blue
            On_IPurple='\033[0;105m'  # Purple
            On_ICyan='\033[0;106m'    # Cyan
            On_IWhite='\033[0;107m'   # White

            #  $$$$$$$$\ $$\   $$\ $$\   $$\  $$$$$$\$$$$$$$$\$$$$$$\  $$$$$$\  $$\   $$\  $$$$$$\
            #  $$  _____|$$ |  $$ |$$$\  $$ |$$  __$$\__$$  __\_$$  _|$$  __$$\ $$$\  $$ |$$  __$$\
            #  $$ |      $$ |  $$ |$$$$\ $$ |$$ /  \__| $$ |    $$ |  $$ /  $$ |$$$$\ $$ |$$ /  \__|
            #  $$$$$\    $$ |  $$ |$$ $$\$$ |$$ |       $$ |    $$ |  $$ |  $$ |$$ $$\$$ |\$$$$$$\
            #  $$  __|   $$ |  $$ |$$ \$$$$ |$$ |       $$ |    $$ |  $$ |  $$ |$$ \$$$$ | \____$$\
            #  $$ |      $$ |  $$ |$$ |\$$$ |$$ |  $$\  $$ |    $$ |  $$ |  $$ |$$ |\$$$ |$$\   $$ |
            #  $$ |      \$$$$$$  |$$ | \$$ |\$$$$$$  | $$ |  $$$$$$\  $$$$$$  |$$ | \$$ |\$$$$$$  |
            #  \__|       \______/ \__|  \__| \______/  \__|  \______| \______/ \__|  \__| \______/

            discon(){
              [[ $(nmcli device status | grep "enp7s0" |awk '{ print $3 }') == *"dis"* ]] || nmcli device disconnect enp7s0 
              [[ $(nmcli device status | grep "wlp5s0" |awk '{ print $3 }') == *"dis"* ]] || nmcli device disconnect wlp5s0 
            }

            aniEpisode(){
              animewget --type episode --season $1 --episode $2 -u $3
            }

            aniSeason(){
              animewget --type season --season $1 -f $2 --progress
            }

            mv_yuzu(){
              YUZU_LOCATION=$(find ~/ -name "yuzu-mainline*.AppImage")
              echo -en "Moving ${Green}$YUZU_LOCATION${NoColor} to .local/bin \n"
              mv $YUZU_LOCATION ~/.local/bin/yuzu.AppImage
              chmod +x ~/.local/bin/yuzu.*
            }

            mkd(){
              mkdir -pv $1
              cd $1
            }

            removeURLS(){
              find ~/NAS/Anime/ -name "urls"
              find ~/NAS/Anime/ -name "urls" -print -exec rm -rf {} \;
            }

            remove_empty(){
              echo -en "Removing empty folders in $1"
              find $1 -type d -empty -print -delete
            }

            ips(){
                ip a |grep enp |grep inet |sed 's,/24.*noprefixroute,,' |awk '{ print $3": " $2}'  
                [[ `ip a | grep "tun\|nord"` ]] && ip a | grep "inet" |grep "tun\|nord" | awk '{ print "You are connected to VPN and your Alternate ip is: " $2 }'
            }

            redo () {
                history | sort -n | sed -e 's/^\s[[:digit:]]*\s*//g' -e 's/^\*\s*//g' -e 's/^[[:digit:]]*\s//g' -e 's/[[:digit:]]*\*\s//g' | fzf | zsh
            }
            betterdiscord(){
              betterdiscordctl install
              betterdiscordctl reinstall
              ps aux | grep [d]iscord | awk '{ print $2 }' |xargs kill
            }
            open(){
                    opout $1
                    nvim $1
                rm *.bbl *.log *.run.xml *.blg *.bcf *.aux *.toc *.out
            }
            lat(){
                    pdflatex $1.tex ; biber $1 ; pdflatex $1.tex
            }

            checksumcheck(){
              [[ $(sha256sum $1 | cut -d' ' -f 1) == $(grep -Po '\b[a-zA-Z0-9]{64}\b' $2) ]] && printf "\033[0;32mGood" || printf "\033[0;31mBad"
            }

            fullcommit(){
              ga
              gcm $1
              gp
            }
            upgrade (){
              rm $HOME/.mozilla/firefox/USER_NAME/search.json.mozlz4.backup
              nix flake update $HOME/.dotfiles
              home-manager --flake $HOME/.dotfiles#$USER@yoitsu switch -b backup
              sleep 1
              sudo nixos-rebuild switch --flake $HOME/.dotfiles#yoitsu
              aplay $HOME/.config/swaync/notification.wav &
              response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "All built uppppp!" -A "Reboot")
              case "$response" in
                0) exit 0 ;;
                1) reboot ;;
                *) echo "Invalid response: $response";;
              esac
              read -p "Press any key to continue"
            }

            rebuild (){
              rm $HOME/.mozilla/firefox/USER_NAME/search.json.mozlz4.backup
              # nix flake update
              home-manager --flake $HOME/.dotfiles#$USER@yoitsu switch -b backup
              sleep 1
              sudo nixos-rebuild switch --flake $HOME/.dotfiles#yoitsu
              aplay $HOME/.config/swaync/notification.wav &
              response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "All built uppppp!" -A "Reboot")
              case "$response" in
                0) exit 0 ;;
                1) reboot ;;
                *) echo "Invalid response: $response";;
              esac
              read -p "Press any key to continue"
            }

            ex ()
            {
              if [ -f $1 ] ; then
                case $1 in
                  *.tar.bz2)   tar xjf $1   ;;
                  *.tar.gz)    tar xzf $1   ;;
                  *.bz2)       bunzip2 $1   ;;
                  *.rar)       unrar x $1     ;;
                  *.gz)        gunzip $1    ;;
                  *.tar)       tar xf $1    ;;
                  *.tbz2)      tar xjf $1   ;;
                  *.tgz)       tar xzf $1   ;;
                  *.zip)       unzip $1     ;;
                  *.Z)         uncompress $1;;
                  *.7z)        7z x $1      ;;
		  *.tar.xz)     tar -xf $1   ;;
                  *)           echo "${BRed}[*] '$1'${Yellow} cannot be extracted via ex()${NoColor}" ;;
                esac
              else
                echo "'$1' is not a valid file"
              fi
            }

            psshXD(){
                pssh -i -h $1 -A -l $2 $3
            }

            psshLOL(){
              pssh -i -H $1 -A -l $2 $3 
            }

            keyword_kill(){
              input_string="$1"
              first="${input_string[1,1]}"
              ending="${input_string[2,-1]}"
              ps aux |rg [$first]$ending |rg -v "vim" | awk '{ print $2 }'| xargs kill
            }
            dotfileBUp(){
                for j in zsh-syntax-highlighting/ zsh-git-prompt/ zsh-autosuggestions/ powerlevel10k/ .config/ .zsh_history .fonts.conf
                do
                    yes | cp -r /home/$USER/$j /home/$USER/.dotfiles/$j
                done
            #   for i in  zsh-syntax-highlighting/ zsh-git-prompt/ zsh-autosuggestions/ powerlevel10k/
            #   do
            #       mkdir /home/$USER/.dotfiles/testy$i/
            #       mv /home/$USER/.dotfiles/$i /home/$USER/.dotfiles/testy$i
            #       mv /home/$USER/.dotfiles/testy$i /home/$USER/.dotfiles/$i
            #   done
                mkdir /home/$USER/.dotfiles/config/
                yes|mv /home/$USER/.dotfiles/.config/ /home/$USER/.dotfiles/config
                git add ~/.dotfiles/*
                dotfileCommit
            }

            pdftalking(){
                pdfgrep -oP "\[(.*?)\]" $1|grep ":"
                pdfgrep -oP "\[(.*?)\]" $1|grep ":"| awk -F":" '{ print $1 }' |sed 's/\[//g' | sorts
            }
            sourceZsh(){
                source ~/.zshrc
            #    backupToGitHub ~/.zshrc
                echo "New .zshrc sourced."
            }


            mn(){
                man -k . | dmenu -fn "MeslosLGS NF" -l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -
            }
            versions(){
              kernel="$(uname -r)"
              echo -en "Kernel:   $kernel\n"
              nvidia-settings --version |grep version |awk -F"version " '{ print "NVIDIA:   " $2}'
              hyprctl version |awk '/Date/ {print "Hyprland built on: " $2 }'
            }
            Get-PubIP() {
              pubip=$(curl -s http://ifconfig.me/ip)
              request=$(curl -s "http://ip-api.com/json/$pubip")
              ip=$(echo "$request" | jq -r '.query')
              city=$(echo "$request" | jq -r '.city')
              country=$(echo "$request" | jq -r '.country')
              isp=$(echo "$request" | jq -r '.isp')
              printf "${BPurple}IP: $ip ${BGreen}City: $city ${BBlue}Country: $country ${BRed}ISP: $isp${NoColor}"
            }
            ping_mon() {
              while true;
              do
                if $(ping -c 1 "$1");
                then
                  notify-send - $HOME/.config/swaync/low.png "Sever Back up\!" "$1 is online."
                  exit 0
                else
                  sleep 30
                fi
              done
            }
            swap_files(){
              \mv "$1" "$1.old"
              \mv "$2" "$1"
              \mv "$1.old" "$2"
            }
            search_font(){
              fc-list | rg -o '[^/]*$[^:]*' | awk -F':' '{print $1}' |grep "$1"
            }
