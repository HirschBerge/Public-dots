{
    pkgs,
    username,
    ...}:
    let
    # editor = "${pkgs.helix}/bin/hx";
    editor = "v";
    aliases = {

            "ping" = "grc ping";
            "netstat" = "grc netstat";
            "cd" ="z";
            "dots" = "cd ~/.dotfiles";
            ".." = "cd ..";
            "..." = "cd ..; cd ..";
            "600" = "chmod -R 600";
            "644" = "chmod -R 644";
            "666" = "chmod -R 666";
            "755" = "chmod -R 755";
            "775" = "chmod -R 775";
            "777" = "chmod -R 777";
            "time" = "${pkgs.hyperfine}/bin/hyperfine --runs 1";
            "benchmark" = "${pkgs.hyperfine}/bin/hyperfine";
            "htop" = "btop";
            D = "cd ~/Downloads && eza --no-quotes -l -a";
            "rustinit" = "nix flake init --template github:HirschBerge/dev-templates#rust";
            "brg" = "${pkgs.bat-extras.batgrep}/bin/batgrep";
            bd = "${editor} ~/.config/directories";
            bf="${editor} ~/.config/files";
            neofetch="${pkgs.fastfetch}/bin/fastfetch --colors-block-range-start 9 --colors-block-width 3";
            filesys="${pkgs.duf}/bin/duf";
            c="clear";
            cat="bat";
            pcat = "${pkgs.bat-extras.prettybat}/bin/prettybat";
            zrust="${pkgs.zellij}/bin/zellij delete-session rusty ;${pkgs.zellij}/bin/zellij -s rusty --layout=$HOME/.config/zellij/layouts/rust.kdl";
            zel="${pkgs.zellij}/bin/zellij";
            traceroute="grc traceroute";
            cp="rsync -rah --info=progress2";
            d="cd ~/Documents && eza --no-quotes -a";
            dd="dd status=progress";
            diff="diff --color=auto";
            dload="python3 /home/$USER/downloader-cli/download.py";
            dloads="cd ~/Downloads";
            e="${editor}";
            etrash="sudo rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*";
            g="git";
            ga="git add";
            gaa="git add --all";
            gam="git am";
            gama="git am --abort";
            gamc="git am --continue";
            gams="git am --skip";
            gamscp="git am --show-current-patch";
            gap="git apply";
            gapa="git add --patch";
            gapt="git apply --3way";
            gau="git add --update";
            gav="git add --verbose";
            gb="git branch";
            gbD="git branch --delete --force";
            gba="git branch --all";
            gbd="git branch --delete";
            gbda="git branch --no-color --merged | command grep -vE \"^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)\" | command xargs git branch --delete 2>/dev/null";
            man = "${pkgs.bat-extras.batman}/bin/batman";
            gbg="git branch -vv | grep \": gone\]\"";
            gbgD="git branch --no-color -vv | grep \": gone\]\" | awk \"\"\"{print $1}\"\"\" | xargs git branch -D";
            gbgd="git branch --no-color -vv | grep \": gone\]\" | awk \"\"\"{print $1}\"\"\" | xargs git branch -d";
            gbl="git blame -b -w";
            gbnm="git branch --no-merged";
            gbr="git branch --remote";
            gbs="git bisect";
            gbsb="git bisect bad";
            gbsg="git bisect good";
            gbsr="git bisect reset";
            gbss="git bisect start";
            gc="git commit --verbose";
            "gc!"="git commit --verbose --amend";
            gca="git commit --verbose --all";
            "gca!"="git commit --verbose --all --amend";
            gcam="git commit --all --message";
            "gcan!"="git commit --verbose --all --no-edit --amend";
            "gcans!"="git commit --verbose --all --signoff --no-edit --amend";
            gcas="git commit --all --signoff";
            gcasm="git commit --all --signoff --message";
            gcb="git checkout -b";
            gcd="git checkout $(git_develop_branch)";
            gcf="git config --list";
            gcl="git clone --recurse-submodules";
            gclean="git clean --interactive -d";
            gcm="git commit -m";
            gcmsg="git commit --message";
            "gcn!"="git commit --verbose --no-edit --amend";
            gco="git checkout";
            gcob="git checkout -b";
            gcor="git checkout --recurse-submodules";
            gcount="git shortlog --summary --numbered";
            gcp="git cherry-pick";
            gcpa="git cherry-pick --abort";
            gcpc="git cherry-pick --continue";
            gcs="git commit --gpg-sign";
            gcsm="git commit --signoff --message";
            gcss="git commit --gpg-sign --signoff";
            gcssm="git commit --gpg-sign --signoff --message";
            gd="git diff";
            gdca="git diff --cached";
            gdct="git describe --tags $(git rev-list --tags --max-count=1)";
            gdcw="git diff --cached --word-diff";
            gds="git diff --staged";
            gdt="git diff-tree --no-commit-id --name-only -r";
            gdup="git diff @{upstream}";
            gdw="git diff --word-diff";
            gf="git fetch";
            gfa="git fetch --all --prune --jobs=10";
            gfg="git ls-files | grep";
            gfo="git fetch origin";
            gg="git gui citool";
            gga="git gui citool --amend";
            ggsup="git branch --set-upstream-to=origin/$(git_current_branch)";
            ghh="git help";
            gi="git init";
            gignore="git update-index --assume-unchanged";
            git-svn-dcommit-push="git svn dcommit && git push github $(git_main_branch):svntrunk";
            gl="git pull";
            glg="git log --graph --oneline --decorate --all";
            glgg="git log --graph";
            glgga="git log --graph --decorate --all";
            glgm="git log --graph --max-count=10";
            glgp="git log --stat --patch";
            glo="git log --oneline --decorate";
            globurl="noglob urlglobber ";
            lp="_git_log_prettily";
            gluc="git pull upstream $(git_current_branch)";
            glum="git pull upstream $(git_main_branch)";
            gma="git merge --abort";
            gs="git status";
            gmom="git merge origin/$(git_main_branch)";
            gms="git merge --squash";
            gmum="git merge upstream/$(git_main_branch)";
            gp="git push";
            gpd="git push --dry-run";
            gpf="git push --force-with-lease --force-if-includes";
            "gpf!"="git push --force";
            gpl="git pull";
            gpu="git push upstream";
            gpv="git push --verbose";
            history="history 50";
            hydra="sudo hydra -e nsr";
            intensemap="grc nmap --open -n -A -T4 -v";
            l="lazygit";
            ls = "eza";
            ll = "eza -l";
            la = "eza -a";
            lt = "eza --tree";
            lla = "eza -la";
            move_ani="cd \"$(fd -td . /mnt/NAS/Anime |fzf)\"";
            lsblk="clear && lsblk";
            manga="eza --no-quotes --group-directories-first -lah --icons /mnt/NAS/Manga";
            md="mkdir -p";
            mv="mv -i";
            nas="cd ~/NAS/Anime";
            nmap="grc nmap --open -v";
            pip="pip3";
            pp="cd ~/Pictures && eza --no-quotes -a";
            publicip="curl api.ipify.org";
            python="python3";
            r="${pkgs.lf}/bin/lf";
            # NOTE: Someone pointed this out and now i can't get rid of it
            reboot="reboot";
            restartpipewire="systemctl --user restart wireplumber pipewire pipewire-pulse";
            rmv="rsync -rahvz --info=progress2 --remove-source-files";
            rscp="rsync -rah --info=progress2 --ignore-existing";
            run-help="man";
            scripts="cd ~/.scripts/";
            sdn="sudo shutdown -h now";
            shutdown="umount -R /mnt/ ; sudo shutdown -h now";
            vim="${editor}";
            vimdiff="${editor} -d";
            vv="cd ~/Videos && eza --no-quotes -a";
            x="exit";
            yt-dl="yt-dlp --format \"bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best\" --merge-output-format mp4";
            ytplaylist="yt-dlp -i -f mp3 --yes-playlist --add-metadata";
    };
    in
{
    programs.nushell = { 
        enable = true;
        shellAliases = aliases;
        extraConfig = ''
            let carapace_completer = {|spans|
                carapace $spans.0 nushell $spans | from json
            }
        $env.config = {
show_banner: false,
             completions: {
case_sensitive: false # case-sensitive completions
                    quick: true    # set to false to prevent auto-selecting completions
                    partial: true    # set to false to prevent partial filling of the prompt
                    algorithm: "fuzzy"    # prefix or fuzzy
                    external: {
# set to false to prevent nushell looking into $env.PATH to find more suggestions
enable: true 
# set to lower can improve completion performance at the cost of omitting some options
            max_results: 100 
            completer: $carapace_completer # check 'carapace_completer' 
                    }
             }
        } 
        $env.PATH = ($env.PATH | 
                split row (char esep) |
                prepend /home/myuser/.apps |
                append /usr/bin/env
                )
            '';
# shellAliases = {
# vi = "hx";
# vim = "hx";
# nano = "hx";
# };
    };  
    programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
    };
    programs.zsh = {
        enable = true;
        prezto.caseSensitive = false;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
            # source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        initExtra = ''
	# Don't just blindly install people's configs. They're not always nice people.
	 notify-send "I could have installed a backdoor. Be better."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
            setopt autocd # auto cd when only path is entered
            setopt nomatch # throw an error on glob matching nothing
            setopt nonomatch
            setopt appendhistory
            setopt hist_ignore_all_dups # remove older duplicate entries from history
            setopt hist_reduce_blanks # remove superfluous blanks from history items
            setopt inc_append_history # save history entries as soon as they are entered
            setopt share_history # share history between different instances of the shell
            setopt auto_cd # cd by typing directory name if it's not a command
            unsetopt correct_all
            setopt auto_list # automatically list choices on ambiguous completion
            setopt auto_menu # automatically use menu completion
            setopt always_to_end # move cursor to end if word had one match
            setopt incappendhistory  #Immediately append to the history file, not just when a term is killed
            zstyle ':completion:*' menu select # select completions with arrow keys
            zstyle ':completion:*' group-name \'\' # group results by category
            zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion
# source /home/${username}/.scripts/.venv/bin/activate
#source /home/${username}/.local/bin/.venv/bin/activate
            export PATH=$PATH:/home/${username}/.local/bin:/home/${username}/.cargo/bin:/home/${username}/.spicetify
            export NIX_PAGER=cat
            export PROMPT_EOL_MARK=" "
            [ -f "$HOME/.config/zsh/colors_and_functions.zsh" ] && source $HOME/.config/zsh/colors_and_functions.zsh
            eval "$(zoxide init zsh)"
            eval "$(batpipe)"
            source ${pkgs.autojump}/share/zsh/site-functions/autojump.zsh
            alias -s {pdf,epub}='zathura'
            alias -s {jpg,png,jpeg}='satty --filename'
            alias -s {mp4,mkv,mp3,gif}='mpv'
            alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
            alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
                '';
        shellAliases = aliases;
        oh-my-zsh = {
            enable = true;
            plugins = [
                "docker-compose"
                    "docker"
                    "sudo"
                    "npm"
                    "brew"
                    "history-substring-search"
                    "git"
                    "web-search"
                    "vi-mode"
                    
            ];
        };
    };
}
