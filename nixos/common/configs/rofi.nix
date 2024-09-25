{
  config,
  pkgs,
  ...
}: {
  programs.rofi = {
    enable = true;
    cycle = true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [
      # HACK: temporary fix until ABI update
      rofi-emoji-wayland
      (rofi-calc.override {
        rofi-unwrapped = rofi-wayland-unwrapped;
      })
    ];
    extraConfig = {
      modi = "drun,calc,window,emoji,run";
      sidebar-mode = true;
      terminal = "kitty";
      show-icons = true;
      kb-remove-char-back = "BackSpace";
      kb-accept-entry = "Control+m,Return,KP_Enter";
      kb-mode-next = "Control+l";
      kb-mode-previous = "Control+h";
      kb-row-up = "Control+k,Up";
      kb-row-down = "Control+j,Down";
      kb-row-left = "Control+u";
      kb-row-right = "Control+d";
      kb-remove-char-forward = "";
      kb-remove-to-sol = "";
      kb-remove-to-eol = "";
      kb-mode-complete = "";
      display-drun = "";
      display-run = "";
      display-emoji = "󰞅";
      display-calc = "󰃬";
      display-window = "";
      display-filebrowser = "";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      window-format = "{w} · {c} · {t}";
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" =  {
          font = "Dank Mono";
          background = mkLiteral "#181825";       # base01
          border = mkLiteral "#1E1E2E";           # base00
          background-alt = mkLiteral "#1E1E2E";   # base00
          foreground = mkLiteral "#D9E0EE";       # base06
          foreground-alt = mkLiteral "#45475A";   # base02
          selected = mkLiteral "#B5E8E0";         # base0C
          active = mkLiteral "#ABE9B3";           # base0B
          urgent = mkLiteral "#96CDFB";           # base0D
      };
      "window" = {
        transparency = "real";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        fullscreen = mkLiteral "false";
        width = mkLiteral "900px";
        x-offset = mkLiteral "0px";
        y-offset = mkLiteral "0px";
        enabled = mkLiteral "true";
        border-radius = mkLiteral "10px";
        border = mkLiteral "2px solid";
        border-color = mkLiteral "@border";
        cursor = "default";
        background-color = mkLiteral "@background";
      };
      "mainbox" = {
        enabled = true;
        spacing = mkLiteral "0px";
        margin = mkLiteral "0px";
        padding = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "0px 0px 0px 0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "transparent";
        children = mkLiteral "[inputbar,message,listview]";
      };
      "inputbar" = {
        enabled = true;
        spacing = mkLiteral "0px";
        margin = mkLiteral "0px";
        padding = mkLiteral "0px";
        border = mkLiteral "0px 0px 1px 0px";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "@background";
        text-color = mkLiteral "@foreground";
        children = mkLiteral "[prompt,entry]";
      };
      "prompt" = {
        enabled = true;
        padding = mkLiteral "15px";
        border = mkLiteral "0px 1px 0px 0px";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@background-alt";
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      "textbox-prompt-colon" = {
        enabled = true;
        expand = false;
        str = "::";
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      "entry" = {
        enabled = true;
        padding = mkLiteral "15px";
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "text";
        placeholder-color = mkLiteral "inherit";
      };
      "mode-switcher" = {
        enabled = true;
        spacing = mkLiteral "10px";
        margin = mkLiteral "0px";
        padding = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-radious = mkLiteral "0px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
      };
      "button" = {
        padding = mkLiteral "10px";
        border-radius = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "@background-alt";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "pointer";
      };
      "button selected" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@foreground";
      };
      "listview" = {
        enabled = true;
        columns = 1;
        lines = 12;
        cycle = true;
        dynamic = true;
        scrollbar = false;
        layout = mkLiteral "vertical";
        reverse = false;
        fixed-height = true;
        fixed-columns = true;
        spacing = mkLiteral "0px";
        margin = mkLiteral "0px";
        padding = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = mkLiteral "default";
      };
      "element" = {
        enabled = true;
        spacing = mkLiteral "10px";
        margin = mkLiteral "0px";
        padding = mkLiteral "8px 15px";
        border = mkLiteral "0px 0px 1px 0px";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = mkLiteral "pointer";
      };
      "element normal.normal" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
      "element normal.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@active";
      };
      "element normal.active" = {
        background-color = mkLiteral "@background";
        text-color = mkLiteral "@active";
      };
      "element selected.normal" = {
        background-color = mkLiteral "@selected";
        text-color = mkLiteral "@background";
      };
      "element selected.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@foreground";
      };
      "element selected.active" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@background-alt";
      };
      "element-icon" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        size = mkLiteral "32px";
        cursor = mkLiteral "inherit";
      };
      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        cursor = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };
      "message" = {
        enabled = true;
        margin = mkLiteral "0px";
        padding = mkLiteral "8px 15px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "0px 0px 0px 0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
      };
      "textbox" = {
        padding = mkLiteral "10px";
        border = mkLiteral "0px solid";
        border-radius = mkLiteral "0px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "@background-alt";
        text-color = mkLiteral "@foreground";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
        highlight = mkLiteral "none";
        placeholder-color = mkLiteral "@foreground-alt";
        blink = true;
        markup = true;
      };
      "error-message" = {
        padding = mkLiteral "0px";
        border = mkLiteral "0px solid";
        border-color = mkLiteral "@border";
        border-radius = mkLiteral "0px";
        background-color = mkLiteral "@background";
        text-color = mkLiteral "@foreground";
      };
    };
  };
  xdg.dataFile."rofi/themes/preview.rasi".text = ''
    @import "./custom.rasi"
    icon-current-entry {
      enabled: true;
      size: 50%;
      padding: 10px;
      background-color: inherit;
    }
    listview-split {
      background-color: transparent;
      border-radius: 0px;
      cycle: true;
      dynamic : true;
      orientation: horizontal;
      border: 0px solid;
      children: [listview,icon-current-entry];
    }
    listview {
      lines: 10;
    }
    mainbox {
      children: [inputbar,listview-split];
    }
  '';
}
