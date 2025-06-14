{
  pkgs,
  config,
  ...
}: let
  custom-font = pkgs.callPackage ./fonts-deriviation.nix {};
in {
  programs.mpv = {
    enable = true;
    config = {
      osc = "no";
      pause = "no";
      # Terminal
      msg-color = "yes";
      ytdl-raw-options = "cookies-from-browser=firefox";
      msg-module = "yes";
      osd-bar = "no";
      profile = "high-quality";
      vo = "gpu-next";
      # loop-file = "inf";
      hwdec = "vaapi";
      gpu-context = "wayland";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      save-position-on-quit = "yes";
      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "oversample";
      slang = "en,eng";
      alang = "ja,jp,jpn,en,eng";
      image-display-duration = "inf";
      osd-font = "${custom-font.dank-mono}";
      cache = "yes";
      volume = 80;
      demuxer-max-bytes = "650MiB";
      demuxer-max-back-bytes = "50MiB";
      demuxer-readahead-secs = "60";
      border = "no";
      keepaspect-window = "no";
    };
    bindings = {
      "l" = "seek 5";
      "h" = "seek -5";
      "a" = "add chapter -1";
      "Alt+n" = "playlist-next";
      "Alt+p" = "playlist-prev";
      "d" = "add chapter 1";
      "k" = "seek 60";
      "j" = "seek -60";
      "]" = "add speed 0.1";
      "[" = "add speed -0.1";
      "CTRL+f" = "script-binding memo-history";
      "tab" = "script-binding uosc/toggle-ui";
      "c" = "script-binding uosc/chapters";
      "r" = "script-binding uosc/stream-quality";
      "t" = "script-binding uosc/audio";
      "shift+f" = "script-binding uosc/keybinds";
      "shift+p" = "script-binding uosc/items";
      "s" = "script-binding uosc/subtitles";
      "u" = "script-message-to youtube_upnext menu";
      "shift+s" = "async screenshot";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      autoload
      mpv-cheatsheet
      youtube-upnext
      memo
      reload
      uosc
      thumbfast
      sponsorblock
    ];
  };
  home.file."${config.xdg.configHome}/mpv/script-opts" = {
    source = ../../.. + "/common/mpv" + /script-opts;
    recursive = true;
  };
}
