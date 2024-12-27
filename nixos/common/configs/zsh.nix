{
  pkgs,
  username,
  ...
}: let
  # editor = "${pkgs.helix}/bin/hx";
  editor = "v";
  aliases = {
    "ping" = "grc ping";
    "netstat" = "grc netstat";
    "cd" = "z";
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
    bf = "${editor} ~/.config/files";
    neofetch = "${pkgs.fastfetch}/bin/fastfetch --colors-block-range-start 9 --colors-block-width 3";
    filesys = "${pkgs.duf}/bin/duf";
    c = "clear";
    cat = "bat";
    pcat = "${pkgs.bat-extras.prettybat}/bin/prettybat";
    zrust = "${pkgs.zellij}/bin/zellij delete-session rusty ;${pkgs.zellij}/bin/zellij -s rusty --layout=$HOME/.config/zellij/layouts/rust.kdl";
    zel = "${pkgs.zellij}/bin/zellij";
    traceroute = "grc traceroute";
    cp = "rsync -rah --info=progress2";
    d = "cd ~/Documents && eza --no-quotes -a";
    dd = "dd status=progress";
    diff = "diff --color=auto";
    dload = "python3 /home/$USER/downloader-cli/download.py";
    dloads = "cd ~/Downloads";
    e = "${editor}";
    etrash = "sudo rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/*";
    g = "git";
    ga = "git add";
    gr = "git restore";
    gaa = "git add --all";
    gam = "git am";
    gama = "git am --abort";
    gamc = "git am --continue";
    gams = "git am --skip";
    gamscp = "git am --show-current-patch";
    gap = "git apply";
    gapa = "git add --patch";
    gapt = "git apply --3way";
    gau = "git add --update";
    gav = "git add --verbose";
    man = "${pkgs.bat-extras.batman}/bin/batman";
    gbl = "git blame -b -w";
    gbs = "git bisect";
    gbsb = "git bisect bad";
    gbsg = "git bisect good";
    gbsr = "git bisect reset";
    gbss = "git bisect start";
    gc = "git commit --verbose";
    "gc!" = "git commit --verbose --amend";
    gca = "git commit --verbose --all";
    "gca!" = "git commit --verbose --all --amend";
    gcam = "git commit --all --message";
    "gcan!" = "git commit --verbose --all --no-edit --amend";
    "gcans!" = "git commit --verbose --all --signoff --no-edit --amend";
    gcas = "git commit --all --signoff";
    gcasm = "git commit --all --signoff --message";
    gcb = "git checkout -b";
    gcd = "git checkout $(git_develop_branch)";
    gcf = "git config --list";
    gcl = "git clone --recurse-submodules";
    gclean = "git clean --interactive -d";
    gcm = "git commit -m";
    gcmsg = "git commit --message";
    "gcn!" = "git commit --verbose --no-edit --amend";
    gco = "git checkout";
    gcob = "git checkout -b";
    gcor = "git checkout --recurse-submodules";
    gcount = "git shortlog --summary --numbered";
    gcp = "git cherry-pick";
    gcpa = "git cherry-pick --abort";
    gcpc = "git cherry-pick --continue";
    gcs = "git commit --gpg-sign";
    gcsm = "git commit --signoff --message";
    gcss = "git commit --gpg-sign --signoff";
    gcssm = "git commit --gpg-sign --signoff --message";
    gd = "git diff";
    gdca = "git diff --cached";
    gdct = "git describe --tags $(git rev-list --tags --max-count=1)";
    gdcw = "git diff --cached --word-diff";
    gds = "git diff --staged";
    gdt = "git diff-tree --no-commit-id --name-only -r";
    gdup = "git diff @{upstream}";
    gdw = "git diff --word-diff";
    gf = "git fetch";
    gfa = "git fetch --all --prune --jobs=10";
    gfg = "git ls-files | grep";
    gfo = "git fetch origin";
    ggsup = "git branch --set-upstream-to=origin/$(git_current_branch)";
    gignore = "git update-index --assume-unchanged";
    git-svn-dcommit-push = "git svn dcommit && git push github $(git_main_branch):svntrunk";
    gl = "git pull";
    glg = "git log --graph --oneline --decorate --all";
    glgg = "git log --graph";
    glgga = "git log --graph --decorate --all";
    glgm = "git log --graph --max-count=10";
    glgp = "git log --stat --patch";
    glo = "git log --oneline --decorate";
    globurl = "noglob urlglobber ";
    lp = "_git_log_prettily";
    gluc = "git pull upstream $(git_current_branch)";
    glum = "git pull upstream $(git_main_branch)";
    gma = "git merge --abort";
    gs = "git status";
    gmom = "git merge origin/$(git_main_branch)";
    gms = "git merge --squash";
    gmum = "git merge upstream/$(git_main_branch)";
    gp = "git push";
    gpd = "git push --dry-run";
    gpf = "git push --force-with-lease --force-if-includes";
    "gpf!" = "git push --force";
    gpl = "git pull";
    gpu = "git push upstream";
    gpv = "git push --verbose";
    history = "history 50";
    hydra = "sudo hydra -e nsr";
    intensemap = "grc nmap --open -n -A -T4 -v";
    l = "lazygit";
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza --tree";
    lla = "eza -la";
    move_ani = "cd \"$(fd -td . /mnt/NAS/Anime |fzf)\"";
    lsblk = "clear && lsblk";
    manga = "eza --no-quotes --group-directories-first -lah --icons /mnt/NAS/Manga";
    md = "mkdir -p";
    mv = "mv -i";
    nas = "cd ~/NAS/Anime";
    nmap = "grc nmap --open -v";
    pip = "pip3";
    pp = "cd ~/Pictures && eza --no-quotes -a";
    publicip = "curl api.ipify.org";
    python = "python3";
    r = "${pkgs.lf}/bin/lf";
    # NOTE: Someone pointed this out and now i can't get rid of it
    reboot = "reboot";
    restartpipewire = "systemctl --user restart wireplumber pipewire pipewire-pulse";
    rmv = "rsync -rahvz --info=progress2 --remove-source-files";
    rscp = "rsync -rah --info=progress2 --ignore-existing";
    run-help = "man";
    scripts = "cd ~/.scripts/";
    sdn = "sudo shutdown -h now";
    shutdown = "umount -R /mnt/ ; sudo shutdown -h now";
    vim = "${editor}";
    vimdiff = "${editor} -d";
    vv = "cd ~/Videos && eza --no-quotes -a";
    x = "exit";
    yt-dl = "yt-dlp --format \"bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best\" --merge-output-format mp4";
    ytplaylist = "yt-dlp -i -f mp3 --yes-playlist --add-metadata";
  };
in {
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.nushell = {
    enable = true;
    extraConfig =
      /*
      nu
      */
      ''
        $env.config = { edit_mode: vi, show_banner: false,}
        $env.PROMPT_INDICATOR_VI_INSERT = " "
        $env.PROMPT_INDICATOR_VI_NORMAL = "❮ "
        export-env { $env.FZF_DEFAULT_OPTS = " --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8  --color=selected-bg:#45475a  --multi --preview 'fzf_previewer {}' --ansi"}
        export-env { $env.FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix --exclude"}
        source ~/.zoxide.nu
        source ~/.config/nushell/satty.nu
        def fo [ ] {
          fd -tf | fzf --exit-0 --height 100% --layout reverse --info inline --border --preview-window right,1,border,50% --bind 'ctrl-g:change-preview-window(25%|hidden|)'
          | if ($in != "" ) { xargs v $in } else {print "exiting early "}
        }
        def man [...args: string ] {
            ^man -k . | fzf --ansi --reverse --preview="echo {1,2}| sed 's/\\w+-//'|xargs man | bat --language=help --color=always" |sed 's/\\w+-//'|xargs man | bat --language=help --color=always
        }
        def bat_remain [] {
            acpi -b | split column ", " |select column2 column3 |rename percent remaining
        }
        def offset_rename [pattern:string, amount:int, subtract:bool] {
            ls |find $"($pattern)" | where type == "video/mp4" | each {|file|
                let old_name = $file.name
                let ep_num = ($old_name | split column "Episode " | select column2 |get 0.column2| split column '.' |get column1.0| into int)
                let new_ep_num = if $subtract == true {
                    $ep_num - $amount
                } else {
                    $ep_num + $amount
                }
                let new_name = ($old_name | str replace -r 'Episode.*' $"Episode ($new_ep_num).mp4")
                echo $"($old_name) moved to ($new_name)"
                mv $old_name $new_name
            }
        }

        def offset_test [pattern:string, amount:int, subtract:bool] {
            ls |find $"($pattern)" | where type == "video/mp4" | each {|file|
                let old_name = $file.name
                let ep_num = ($old_name | split column "Episode " | select column2 |get 0.column2| split column '.' |get column1.0| into int)
                let new_ep_num = if $subtract == true {
                    $ep_num - $amount
                } else {
                    $ep_num + $amount
                }
                let new_name = ($old_name | str replace -r 'Episode.*' $"Episode ($new_ep_num).mp4")
                echo $"($old_name) simulated moved to ($new_name)"
            }
        }
        def versions [] {
            let kernel = (uname).kernel-release
            let driver_version = (rocm-smi --showdriverversion | rg Driver | awk '{print $3}')
            let hyprland_version = $"((hyprctl version -j |from json).tag) on ((hyprctl version -j |from json).commit_date)"
            echo $"Type,Version\nGPU,($driver_version)\nKernel,($kernel)\nHyprland,($hyprland_version)"|from csv
        }
        def traefik_log [] {
            rsync -rah  bind9:/root/traefik/data/access.log ~/.cache/access.log
            echo $"[(sed ':a;N;$!ba;s/\n/ /g' ~/.cache/access.log)]" |from json | select ClientHost ClientPort RequestAddr RequestMethod RouterName StartLocal entryPointName RequestPath |
            each {|row|
                let time = ($row.StartLocal  | into datetime); $row | update StartLocal $time
            } |where ClientHost != "10.10.10.51"
        }
        def inhibitors [] {
            hyprctl clients -j | from json |
            each { |row|
                let monitor_map = {
                    "0": "Top",
                    "1": "Bottom"
                }
                let row = $row | update monitor ($monitor_map | get ($row.monitor | to text))
                if (("title" in $row) and ($row.title =~ "YouTube" or ($row.title =~ "steam_app" and $row.title =~ "yuzu") or $row.title =~ "Google Meet" or $row.title =~ "S[0-9].*E[0-9]")) or (("class" in $row) and ($row.class =~ "YouTube" or ($row.class =~ "steam_app" or $row.class =~ "yuzu") or $row.class =~ "S[0-9].*E[0-9]")) {
                    $row |select monitor title xwayland fullscreen fullscreenClient pid
                }
            }
        }
        def animeAiring [] {
            anilist_cli | from json | each {|row|
                let updated = if $row.data.Media.nextAiringEpisode == null {
                    "never"
                } else if $row.data.Media.nextAiringEpisode.airingAt == null {
                    "null"
                } else {
                    $row.data.Media.nextAiringEpisode.airingAt | into datetime
                };
                if $row.data.Media.nextAiringEpisode != null {
                    $row | update data.Media.nextAiringEpisode.airingAt $updated
                } else {
                    $row
                }
            }| get data.media
        }
        def --env yy [...args] {
            let tmp = (mktemp -t "yazi-cwd.XXXXXX")
            yazi ...$args --cwd-file $tmp
            let cwd = (open $tmp)
            if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
            }
            rm -fp $tmp
        }
        def wc_table [file] {
            let line_count = (open $file | lines | length)
            let word_count = (open $file | split words | length)
            let char_count = (open $file | str length)
            [
                { "Lines": $line_count "Words": $word_count "Chars": $char_count }
            ] | table
        }
        def ips [] {
            $"Interface,IP,MAC\n(ip a | rg -A3 'enp|wlo'|rg -v altname | rg -B1 'inet ' | sed 's,/24.*noprefixroute,,' | awk ' /link\/ether/ {mac=$2} /inet/ {ip=$2; iface=$NF; print iface "," ip "," mac} ')"|from csv
        }
        def anime_today [] {
            open ~/.cache/animes.csv |where Day == (date now | format date "%A")
        }
        def choose_anime [] {
            let choice = anime_today | try {input list "Pick an anime"} catch {echo "Could not find any anime releasing today. Please try again tomorrow" |print ; return 69 }
            try {
                let anime_title = $"($choice |get Anime)"
                let season = $'($choice |get Season |split row " " | get 1)'
                let path = $"(fd -1 $"($anime_title)" /mnt/NAS/Anime -i)"
                let full_path = $"(fd -1 -td $"($season)" -i ($path))"
                if ($"($full_path)" | path exists ) {
                } else {
                    echo $full_path does not exist
                    let full_path = $"($path)/($choice |get Season)"
                    mkdir $"($path)/($choice |get Season)"
                }
                let episodes = $"(try {(ls -m $full_path |where type =~ video |sort-by name |last |get name |split row "E" |last |split row '.' |get 0 | into int) + 1 } catch {1})"
                echo $"Title,Season,Episode,Path\n($anime_title),($season),($episodes),($full_path)"|from csv
            } catch {
                print "Nothing chosen"
            }
        }
        def download_anime [] {
            let anime_data = choose_anime
            if $anime_data == 69 {
                return
            }
            $anime_data | print
            cd ($anime_data |first).Path
            ani-cli -d ($anime_data |first).Title -e ($anime_data |first).Episode
            clear
            autorenamer -s ($anime_data| first).Season
            ls -lm  |reject target readonly num_links inode group created
            notify-send -a anime "Download complete" $"(($anime_data|first).Title) Episode (($anime_data |first).Episode)"
        }
        def games_by_platform [platform] {
            open /mnt/NAS/Files/game_backlog.json | each {|game|
                if ( $game.Platform | any {|plat| $plat =~ $platform }) {
                    $game
                }
            }
        }
        def games_by_genre [genre] {
            open /mnt/NAS/Files/game_backlog.json | each {|game|
                if ( $game.Genre | any {|genres| $genres =~ $genre }) {
                    $game
                }
            }
        }
      '';

    shellAliases = {
      "time" = "${pkgs.hyperfine}/bin/hyperfine --runs 1";
      "dig" = "${pkgs.grc}/bin/grc ${pkgs.dnsutils}/bin/dig";
      "benchmark" = "${pkgs.hyperfine}/bin/hyperfine";
      "x" = "exit";
      "ll" = "ls -lmd";
      "ls" = "ls -m";
      "lll" = "eza -l";
      "ping" = "grc ping";
      "nmap" = "grc nmap --open";
      "traceroute" = "grc traceroute";
      "netstat" = "grc netstat";
      "gpl" = "git pull";
      "gcam" = "git commit --all --verbose --message";
      "gcm" = "git commit --verbose --message";
      "gc" = "git commit --verbose";
      "ga" = "git add";
      "gp" = "git push";
      "gd" = "git diff";
      "gr" = "git restore";
      "gs" = "git status";
      "cat" = "bat";
      "dots" = "cd $env.FLAKE";
      "cp" = "rsync -rah --info=progress2";
      "mkd" = "mkdir";
    };
  };
  programs.bash = {
    enable = true;
    shellAliases = aliases;
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
                  alias -s {pdf,epub}='zathura'
                  alias -s {jpg,png,jpeg}='satty --filename'
                  alias -s {mp4,mkv,mp3,gif}='mpv'
                  alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
                  alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
      if [[ -z "$ZELLIJ" ]] && [[ -z "$SSH_CONNECTION"  ]]  ; then
          if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
              zellij attach -c
          else
              zellij -l welcome
          fi

          if [[ "$ZELLIJ_AUTO_EXIT" == "TRUE" ]]; then
              exit
          fi
      fi
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
