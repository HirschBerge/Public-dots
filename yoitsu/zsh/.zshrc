# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#   ________   ______   __    __  _______    ______
#  /        | /      \ /  |  /  |/       \  /      \
#  $$$$$$$$/ /$$$$$$  |$$ |  $$ |$$$$$$$  |/$$$$$$  |
#      /$$/  $$ \__$$/ $$ |__$$ |$$ |__$$ |$$ |  $$/
#     /$$/   $$      \ $$    $$ |$$    $$< $$ |
#    /$$/     $$$$$$  |$$$$$$$$ |$$$$$$$  |$$ |   __
#   /$$/____ /  \__$$ |$$ |  $$ |$$ |  $$ |$$ \__/  |
#  /$$      |$$    $$/ $$ |  $$ |$$ |  $$ |$$    $$/
#  $$$$$$$$/  $$$$$$/  $$/   $$/ $$/   $$/  $$$$$$//mpv


# Load aliases and shortcuts if existent.
#~/.scripts/corona.sh
/usr/local/bin/weather_app --forecast --location "Pittsburgh"
[ -f "$HOME/.config/shortcutrc" ] && source "/home/hirschy/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "/home/hirschy/.config/aliasrc"
[ -f "$HOME/.config/colorsrc" ] && source "/home/hirschy/.config/colorsrc"
# If you come from bash you might have to change your $PATH.
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/hirschy/.oh-my-zsh"
Red="\033[1;31m"
Green="\033[1;32m"
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
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="starship"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
    archlinux
    git
    history-substring-search
    colored-man-pages
    zsh-autosuggestions
    sudo
    zsh-syntax-highlighting
    autojump
    npm
    brew
    git-flow-completion
)
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"
# You may need to manually set your language environment
# export LANG=en_US.UTF-8

#History setup
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000


alias history='history 50'
setopt nonomatch
setopt appendhistory
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances of the shell
setopt auto_cd # cd by typing directory name if it's not a command
setopt correct_all # autocorrect commands
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
setopt    incappendhistory  #Immediately append to the history file, not just when a term is killed
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

autoload -Uz compinit;compinit -i
#             __  __
#            /  |/  |
#    ______  $$ |$$/   ______    _______   ______    _______
#   /      \ $$ |/  | /      \  /       | /      \  /       |
#   $$$$$$  |$$ |$$ | $$$$$$  |/$$$$$$$/ /$$$$$$  |/$$$$$$$/
#   /    $$ |$$ |$$ | /    $$ |$$      \ $$    $$ |$$      \
#  /$$$$$$$ |$$ |$$ |/$$$$$$$ | $$$$$$  |$$$$$$$$/  $$$$$$  |
#  $$    $$ |$$ |$$ |$$    $$ |/     $$/ $$       |/     $$/
#   $$$$$$$/ $$/ $$/  $$$$$$$/ $$$$$$$/   $$$$$$$/ $$$$$$$/



alias restartpipewire='systemctl --user restart wireplumber pipewire pipewire-pulse'
alias rmv='rsync -rahvz --info=progress --remove-source-files'
alias tree='exa -lah --tree --icons'
alias publicip='curl api.ipify.org'
alias -g sorts='sort | uniq -c | sort -n'
alias netumount='sudo umount -f -l /mnt/Raid_Storage ~/Videos ~/Music/ /mnt/GAMESTORAGE && filesys'
alias du='~/.scripts/dudu.sh'
alias mp4renm='~/.scripts/setname'
alias musicplay='~/.scripts/musicplay'
alias renames="~/.scripts/rename"
alias -g web='~/.scripts/yt'
alias lsblk='clear && lsblk'
alias r='ranger'
alias hydra='sudo hydra -e nsr'
alias hdparm='sudo hdparm'
alias -g G='| grep -i --color=auto'
alias -s {txt,list,log}='vim'
alias -s {mp4,mkv,mp3}='mpv'
alias -s {jpg,png,gif}='sxiv -a'
alias pacman='pacman'
alias -s {pdf,epub}='zathura'
alias -s {doc,docx}='wps'
alias mpv='mpv -fs=yes'
alias ifc='sudo ifconfig'
alias speedtest='speedtest-cli'
alias dload='python3 /home/$USER/downloader-cli/download.py'
alias yt-dl='yt-dlp --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" --merge-output-format mp4'
alias nas='cd ~/NAS/Anime'
alias manga='cd /mnt/U32/Manga && exa --group-directories-first -l'
alias pacup='~/.scripts/pacUpdate.sh'
alias zshrc='editZsh'
alias dtop='cd ~/Desktop && exa --group-directories-first -l'
alias dloads='cd ~/Downloads'
alias vi='vim'
alias pac='yes | sudo pacman'
alias x='exit'
alias c='clear'
alias ssh="kitty +kitten ssh"
alias etrash='sudo rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 777='chmod -R 777'
alias 755='chmod -R 755'
alias 775='chmod -R 775'
alias 600='chmod -R 600'
alias dd='dd status=progress'
alias ll='clear && exa --group-directories-first -l --icons'
alias la="clear && exa --group-directories-first -la --icons"
alias ls="clear && exa --icons"
alias rscp='rsync -rah --progress --ignore-existing'
alias nmap='grc nmap --open -v'
alias intensemap='grc nmap --open -n -A -T4 -v'
alias manga='exa --group-directories-first -lah --icons /mnt/NAS/Manga'
alias ..='cd ..'
alias ...='cd ..; cd ..'
alias ....='cd ..; cd ..; cd ..'
alias c='clear'
alias find='time find'
alias hibernate='i3lock-fancy-rapid 5 3 && systemctl suspend'
alias grep='rg'
alias mv='mv -i'
alias cp='pycp -i'
alias hi='echo "Hello there $USER"| lolcat'
alias python="python3"
alias pip="pip3"
alias scripts='cd ~/.scripts/'
alias ytplaylist='yt-dlp -i -f mp3 --yes-playlist --add-metadata'
alias cat='bat --paging=never'
alias bat='bat --paging=never'
#alias yt="yt-dlp --add-metadata -i"
alias yta="yt -x -f bestaudio/best"
alias diff="diff --color=auto"
alias ccat="highlight --out-format=ansi"
alias ka="killall"
alias g="git"
alias trem="transmission-remote"
alias YT="youtube-viewer"
alias shutdown='umount -R /mnt/ ; sudo shutdown -h now'
alias sdn="sudo shutdown -h now"
alias f="$FILE"
alias e="nvim"
alias v="nvim"
alias reboot='reboot'

alias p="sudo pacman"
alias xr="sudo xbps-remove -R"
alias xq="xbps-query"
alias magit="nvim -c MagitOnly"
alias ref="shortcuts >/dev/null; source ~/.config/shortcutrc"
alias weath="less -S ~/.local/share/weatherreport"
alias h="cd ~/ && exa -a"
alias d="cd ~/Documents && exa -a"
alias D="cd ~/Downloads && exa -a"
alias m="cd ~/Music && exa -a"
alias pp="cd ~/Pictures && exa -a"
alias vv="cd ~/Videos && exa -a"
alias cf="cd ~/.config && exa -a"
alias sc="cd ~/.local/bin && exa -a"
alias bf="nvim ~/.config/files"
alias bd="nvim ~/.config/directories"
alias bw="nvim ~/.config/bookmarks"
alias cfa="nvim ~/.config/aliasrc"
alias cfz="nvim $ZDTDIR/.zshrc"
alias cfv="nvim ~/.config/nvim/init.vim"
alias cfm="nvim ~/.config/mutt/muttrc"
alias cfd="nvim ~/.Xdefaults"
alias cfu="nvim ~/.config/newsboat/urls"
alias cfn="nvim ~/.config/newsboat/config"
alias cfmb="nvim ~/.config/ncmpcpp/bindings"
alias cfmc="nvim ~/.config/ncmpcpp/config"
alias cfk="nvim ~/.config/sxhkd/sxhkdrc"
alias cfi="nvim ~/.config/i3/config"
alias cfb="nvim ~/.config/i3blocks/config"
alias mp3convert='sh ~/.scripts/mp3convert'

# Git aliases
alias gi="git init"
alias gs="git status -sbu"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gp="git push"
alias gm="gi merge"
alias ga="git add ."
alias gcm="git commit -m"
alias gpl="git pull"
alias gst="git stash"
alias gstl="git stash list"
alias glg='git log --graph --oneline --decorate --all'
alias nrs='sudo npm run serve'
alias awg='animewget'



# key bindings





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

filesys(){
	clear
#	echo -n "Drive:\t\t     FileSystem:   Size: Used: Avl:  Use:  Mount Point\n"
  sudo df -hT |grep FileSystem |tac |tac
	sudo df -hT |grep -v tmp | grep "ext4\|btrfs"| sort -nrk 6
}

ips(){
	ip a |grep "inet" G "enp" | awk '{ print "Your IP Address is: " $2 }'
	[[ `ip a | grep "tun\|nord"` ]] && ip a G "inet" G "tun\|nord" | awk '{ print "You are connected to VPN and your Alternate ip is: " $2 }'
}

redo () {
	history | sort -n | sed -e 's/^\s[[:digit:]]*\s*//g' -e 's/^\*\s*//g' -e 's/^[[:digit:]]*\s//g' -e 's/[[:digit:]]*\*\s//g' | fzf | zsh
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

vpn_swap(){
  printf "${Green}[+]${NoColor} Checking for NFS mounts...\n"
  sleep 1
  mount > ~/.cache/mounts
  grep hirschykiss ~/.cache/mounts >/dev/null&& printf "${Red}[+]${NoColor} NFS mount found. Please unmount first.\n"
  grep hirschykiss ~/.cache/mounts >/dev/null&& return|| printf "${Green}[+]${NoColor} No NFS mount found.\n"
  printf "${Green}[+]${NoColor} Checking devices....\n"
  sleep 1
  up=$(nmcli device status | grep "enp" | grep -v dis | awk '{ print $1 }') >/dev/null
  down=$(nmcli device status | grep "enp" | grep dis | awk '{ print $1 }') >/dev/null
  printf "${Green}[+]${NoColor} Switching to/from a VPN connection.\n"
  sleep 1
  printf "${Green}[+]${NoColor} Remounting your NFS share.\n"
  sh ~/.scripts/mounting.sh
  nmcli device disconnect $up >/dev/null; nmcli device connect $down>/dev/null
  newup=$(nmcli device status | grep "enp" | grep -v dis | awk '{ print $1 }')
  LOCAL=$(ip -f inet addr show $newup | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
  public=$(curl -s api.ipify.org)
  printf "${Green}[+]${NoColor} Switching complete. Your new local IP is ${Green}$LOCAL${NoColor}  and new public IP is ${Green}$public${NoColor} \n"
}

dotfileBUp(){
	for j in zsh-syntax-highlighting/ zsh-git-prompt/ zsh-autosuggestions/ powerlevel10k/ .config/ .zsh_history .fonts.conf
	do
		yes | cp -r /home/$USER/$j /home/$USER/my-dotfiles/$j
	done
#	for i in  zsh-syntax-highlighting/ zsh-git-prompt/ zsh-autosuggestions/ powerlevel10k/
#	do
#		mkdir /home/$USER/my-dotfiles/testy$i/
#		mv /home/$USER/my-dotfiles/$i /home/$USER/my-dotfiles/testy$i
#		mv /home/$USER/my-dotfiles/testy$i /home/$USER/my-dotfiles/$i
#	done
	mkdir /home/$USER/my-dotfiles/config/
	yes|mv /home/$USER/my-dotfiles/.config/ /home/$USER/my-dotfiles/config
	git add ~/my-dotfiles/*
	dotfileCommit
}

pdftalking(){
	pdfgrep -oP "\[(.*?)\]" $1|grep ":"
	pdfgrep -oP "\[(.*?)\]" $1|grep ":"| awk -F":" '{ print $1 }' |sed 's/\[//g' | sorts
}
sourceZsh(){
    source ~/.config/zsh/.zshrc
#    backupToGitHub ~/.zshrc
    echo "New .zshrc sourced."
}

editZsh(){
    nvim ~/.config/zsh/.zshrc
    source ~/.config/zsh/.zshrc
#    backupToGitHub ~/.zshrc
    echo "New .zshrc sourced."
}


mn(){
	man -k . | dmenu -fn "MeslosLGS NF" -l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



#   ________   ______   ________
#  /        | /      \ /        |
#  $$$$$$$$/ /$$$$$$  |$$$$$$$$/
#  $$ |__    $$ |  $$ |$$ |__
#  $$    |   $$ |  $$ |$$    |
#  $$$$$/    $$ |  $$ |$$$$$/
#  $$ |_____ $$ \__$$ |$$ |
#  $$       |$$    $$/ $$ |
#  $$$$$$$$/  $$$$$$/  $$/t

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
#[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
#source ~/powerlevel10k/powerlevel10k.zsh-theme
#source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
eval "$(starship init zsh)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#source ~/powerlevel10k/powerlevel10k.zsh-theme
export PATH=$PATH:/home/hirschy/.local/bin:/home/hirschy/.cargo/bin:/home/hirschy/.spicetify
export NIX_PAGER=cat
export PROMPT_EOL_MARK=" " 
