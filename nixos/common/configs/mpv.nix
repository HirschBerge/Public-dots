{
  pkgs,
  config,
  ...
}:
let
  custom-font = pkgs.callPackage ./fonts-deriviation.nix {};
in
{
  programs.mpv = {
    enable = true;
    config = {
      osc = "no";
      pause = "no";
      # Terminal
      msg-color= "yes";
      msg-module = "yes";
      osd-bar = "no";
      profile = "gpu-hq";
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
      "CTRL+1" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
      "CTRL+2" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
      "CTRL+3" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
      "CTRL+4" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
      "CTRL+5" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
      "CTRL+6" = ''
        no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
      "CTRL+0" = ''
        no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
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
