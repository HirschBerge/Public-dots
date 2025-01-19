{
  pkgs,
  username,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.${username} = {
      name = "${username}";
      settings = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
      };
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        lastpass-password-manager
        ublock-origin
        sponsorblock
        enhancer-for-youtube
        return-youtube-dislikes
        behind-the-overlay-revival
        betterttv
        nighttab
        sidebery
      ];
      search = {
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "NixOS Wiki" = {
            urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@nw"];
          };
          "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        };
        default = "Google";
      };
      bookmarks = [
        {
          toolbar = true;
          bookmarks = [
            {
              name = "Nix sites";
              bookmarks = [
                {
                  name = "homepage";
                  url = "https://nixos.org/";
                }
                {
                  name = "wiki";
                  tags = ["wiki" "nix"];
                  url = "https://nixos.wiki/";
                }
              ];
            }
            {
              name = "Homelab";
              bookmarks = [
                {
                  name = "Plex";
                  url = "https://plex-prod.example.com/web/index.html#!/";
                }
                {
                  name = "Proxmox";
                  url = "https://cluster-pve.example.com/#v1:0:18:4:::::::";
                }
                {
                  name = "Home Assistant";
                  url = "http://hac-prod.example.com/lovelace/HPCA";
                }
                {
                  name = "Router";
                  url = "https://router-infra.example.com/network/default/dashboard";
                }
                {
                  name = "Docker";
                  url = "https://portainer-prod.example.com/#!/auth";
                }
                {
                  name = "NAS";
                  url = "https://nas-prod.example.com/ui/dashboard";
                }
                {
                  name = "";
                  url = "";
                }
              ];
            }
            {
              name = "Learn Rust";
              bookmarks = [
                {
                  name = "Comprehensive Rust";
                  url = "https://google.github.io/comprehensive-rust";
                }
                {
                  name = "The Book";
                  url = "https://doc.rust-lang.org/book/";
                }
              ];
            }
            {
              name = "Github Links";
              bookmarks = [
                {
                  name = "Home";
                  example.com/";
                }
                {
                  name = "Advent of Code";
                  url = "https://github.com/HirschBerge/AdventOfCode";
                }
                {
                  name = "Anilyzer";
                  url = "https://github.com/HirschBerge/anilyzer";
                }
                {
                  name = "Dots";
                  url = "https://github.com/HirschBerge/.dotfiles";
                }
                {
                  name = "Scripts";
                  url = "https://github.com/HirschBerge/Scripts";
                }
              ];
            }
            {
              name = "Pathfinder";
              bookmarks = [
                {
                  name = "Dominion";
                  url = "https://docs.google.com/spreadsheets/d/1nNXydoOHAUUW18FTjk4O5QZnyipzyVkQ5rm2V-5bUaE/edit?pli=1";
                }
                {
                  name = "Pathbuilder2E";
                  # toolbar = true;
                  url = "https://pathbuilder2e.com/app.html?v=71a";
                }
                {
                  name = "Roll20";
                  url = "https://app.roll20.net/campaigns/search/";
                }
                {
                  name = "Mark's Books";
                  url = "https://drive.google.com/drive/folders/1uce9hs9MrRcIZebNvdQbvYLi-6vbkV9m";
                }
              ];
            }
            {
              name = "All Anime";
              # toolbar = true;
              url = "https://allmanga.to/search-anime?tr=sub&cty=ALL";
            }
            {
              name = "YouTube";
              url = "https://youtube.com";
            }
            {
              name = "AniWave";
              # toolbar = true;
              url = "https://aniwave.to/home";
            }
            {
              name = "ProtonDB";
              url = "https://www.protondb.com/";
            }
          ];
        }
      ];
      # userChrome = ''
      #   :root {
      #     --toolbar-field-focus-border-color: transparent !important;
      #     --urlbar-background-color: #201929;
      #
      #   }
      #
      #   :root[privatebrowsingmode="temporary"] {
      #     --urlbar-background-color: #25003E;
      #   }
      #
      #
      #   /* Clean Urlbar */
      #
      #   #urlbar,
      #   #searchbar {
      #     font-size: 13px !important;
      #     margin-top: 1px !important;
      #   }
      #
      #   #urlbar-background,
      #   #searchbar {
      #     border: none !important;
      #     background-color: var(--urlbar-background-color) !important;
      #     animation-name: none !important;
      #     box-shadow: none !important;
      #   }
      #
      #   #urlbar[breakout][breakout-extend]>#urlbar-background {
      #     background-color: var(--urlbar-background-color) !important;
      #     background-image: var(--lwt-additional-images) !important;
      #     background-repeat: var(--lwt-background-tiling) !important;
      #     background-position: var(--lwt-background-alignment) !important;
      #   }
      #
      #   #urlbar[open]>.urlbarView>.urlbarView-body-outer>.urlbarView-body-inner {
      #     border: none !important;
      #   }
      #
      #   .urlbarView-row[selected]>.urlbarView-row-inner,
      #   .urlbarView-row-inner[selected] {
      #     background: #3A3941 !important;
      #   }
      #
      #   #nav-bar:not([tabs-hidden="true"]) {
      #     box-shadow: none !important;
      #   }
      #
      #   #navigator-toolbox {
      #     border-bottom: none !important;
      #   }
      #
      #
      #   toolbar .toolbarbutton-1:not([disabled="true"], [checked], [open], :active)>.toolbarbutton-icon {
      #     transition: background linear 0.5s;
      #   }
      #
      #   /* Hiding Tabs Toolbar */
      #
      #   #main-window[tabsintitlebar="false"]:not([extradragspace="true"]) #TabsToolbar>.toolbar-items {
      #     opacity: 0;
      #     pointer-events: none;
      #   }
      #
      #   #main-window:not([tabsintitlebar="false"]) #TabsToolbar {
      #     visibility: collapse !important;
      #   }
      #
      #   #main-window[tabsintitlebar="false"]:not([extradragspace="true"]) #TabsToolbar .titlebar-spacer {
      #     border-inline-end: none;
      #   }
      #
      #   /* Moving Windows Control */
      #
      #   #nav-bar {
      #     margin-left: 0px !important;
      #     border-top: 0px !important;
      #     margin-top: 0px;
      #     padding-left: 65px !important
      #   }
      #
      #   #titlebar {
      #     appearance: none !important;
      #     height: 0px;
      #   }
      #
      #
      #
      #   #TabsToolbar {
      #     background: #2B2A34 !important;
      #     background-color: #2B2A34 ! important;
      #     color: #2B2A34 !important;
      #   }
      #   /* Remove close button*/ .titlebar-buttonbox-container{ display:none }
      #   /* Page Actions Hide and Show on Hover */
      #
      #   #page-action-buttons:not(:hover) .urlbar-page-action,
      #   #page-action-buttons:not(:hover) #star-button {
      #     width: 0px !important;
      #     min-width: 0px !important;
      #     padding-left: 0px !important;
      #     padding-right: 10px !important;
      #     margin-right: -15px !important;
      #     transition: all 250ms ease-in-out;
      #   }
      #
      #   #page-action-buttons:not(:hover) #userContext-indicator {
      #     margin-right: 37px !important;
      #     transition: all 250ms ease-in-out;
      #   }
      #
      #   #page-action-buttons:hover .urlbar-page-action,
      #   #page-action-buttons:hover #star-button {
      #     visibility: visible;
      #     min-width: unset !important;
      #   }
      #
      #   #page-action-buttons:hover #userContext-indicator {
      #     margin-right: 0px !important;
      #   }
      #
      #   #page-action-buttons::after {
      #     content: "•••";
      #     position: absolute;
      #     margin-top: 0px;
      #     font-size: 0.7em;
      #     opacity: 0.5;
      #     right: 6px;
      #     transition: all 50ms ease-in-out;
      #   }
      #
      #
      #
      #   #page-action-buttons:hover::after {
      #     display: none !important;
      #     width: 0px !important;
      #     margin-left: 0px !important;
      #     transition: all 50ms ease-in-out;
      #   }
      #
      #
      #
      #   /* Move findbar to top right */
      #   .browserContainer>findbar {
      #     position: absolute;
      #     top: -1px;
      #     right: 0px;
      #     contain: content;
      #     border-radius: 0 0 var(--toolbarbutton-border-radius) var(--toolbarbutton-border-radius);
      #   }
      #
      #   /* Hide status */
      #   findbar .findbar-find-status {
      #     display: none;
      #   }
      #
      #   /* Replace checkboxes with buttons */
      #   findbar .checkbox-check {
      #     display: none !important;
      #   }
      #
      #   findbar checkbox {
      #     border: 1px solid var(--input-border-color);
      #     border-radius: var(--toolbarbutton-border-radius);
      #     padding: 2px 4px;
      #     margin: -2px 4px !important;
      #     transition: 0.1s ease-in-out;
      #   }
      #
      #   findbar checkbox[checked="true"] {
      #     background: var(--button-active-bgcolor);
      #     transition: 0.1s ease-in-out;
      #   }
      #   :root {
      #     --wide-tab-width: 300px;
      #     --thin-tab-width: 35px;
      #     --sidebar-background: #2b2a33;
      #   }
      #
      #   #sidebar-box>#browser,
      #   #webextpanels-window {
      #     background: var(--sidebar-background) !important;
      #
      #   }
      #
      #   /*Collapse in default state and add transition*/
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] {
      #     border-right: none !important;
      #     z-index: 2;
      #     border-right: none !important;
      #     width: 100% !important;
      #     background: var(--sidebar-background);
      #
      #     /* lock sidebar to height by doing the inverse margin of the toolbar element */
      #     z-index: 1000 !important;
      #     position: relative !important;
      #     margin-top: 0px !important;
      #     border-right: none;
      #     transition: all 200ms !important;
      #
      #     /* lock sidebar to specified width */
      #     ;
      #     min-width: var(--thin-tab-width) !important;
      #     max-width: var(--thin-tab-width) !important;
      #     overflow: hidden !important;
      #     transition-property: width;
      #     transition-duration: 0.3s;
      #     transition-delay: 0.3s;
      #     transition-timing-function: ease-in;
      #   }
      #
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]::after {
      #     background: var(--sidebar-background) !important;
      #     margin-left: 207px;
      #     z-index: 9999999;
      #     position: absolute;
      #     content: " ";
      #     width: 1px;
      #     height: 100%;
      #     top: 0;
      #     right: 0px;
      #   }
      #
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]:hover:after {
      #     top: 42px;
      #   }
      #
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]:hover,
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] #sidebar:hover {
      #     min-width: var(--wide-tab-width) !important;
      #     max-width: var(--wide-tab-width) !important;
      #     margin-right: calc((var(--wide-tab-width) - var(--thin-tab-width)) * -1) !important;
      #     transition: all 200ms !important;
      #   }
      #
      #   #sidebar-header {
      #     border: none !important;
      #     border-right: 1px solid var(--sidebar-border-color);
      #     background: var(--sidebar-background) !important;
      #   }
      #
      #   #sidebar-close,
      #   #sidebar-title,
      #   #sidebar-switcher-arrow {
      #     display: none;
      #     border: none;
      #   }
      #
      #   #sidebar-switcher-target {
      #     border: none !important;
      #     margin-left: 4.5px !important;
      #     padding-top: 4px !important;
      #     padding-bottom: 6px !important;
      #   }
      #
      #   #sidebar-switcher-target:focus-visible:not(:hover, [open]),
      #   #sidebar-close:focus-visible:not(:hover, [open]) {
      #     outline: none !important;
      #   }
      #
      #   .sidebar-splitter {
      #     opacity: 0 !important;
      #     width: 0px !important;
      #     border: none !important;
      #     --avatar-image-url: none !important;
      #   }
      #
      #   #sidebarMenu-popup .subviewbutton {
      #     min-width: 0px;
      #     padding: 0;
      #     margin: 0 !important;
      #   }
      #
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"]+#sidebar-splitter {
      #     display: none !important;
      #   }
      #
      #   #sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"] #sidebar-header {
      #     visibility: collapse;
      #   }
      #
      #   /* Auto Hide Tree Style Tab
      #
      #   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]+#sidebar-splitter {
      #     display: none !important;
      #   }
      #
      #   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
      #     visibility: collapse;
      #   }
      #
      #   sidebar-box:not([sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]) {
      #     min-width: var(--wide-tab-width) !important;
      #     max-width: none !important;
      #   }
      #
      #   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] {
      #     overflow: hidden !important;
      #     position: relative !important;
      #     transition: all 200ms !important;
      #     min-width: var(--thin-tab-width) !important;
      #     max-width: var(--thin-tab-width) !important;
      #     z-index: 1;
      #   }
      #
      #   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]:hover,
      #   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar {
      #     transition: all 200ms !important;
      #     min-width: var(--wide-tab-width) !important;
      #     max-width: var(--wide-tab-width) !important;
      #     margin-right: calc((var(--wide-tab-width) - var(--thin-tab-width)) * -1) !important;
      #     z-index: 1;
      #   }*/
      # '';
      extraConfig =
        /*
        css
        */
        ''

          /*color schemes*/
          user_pref("user.theme.dark.a", false); /*default dark mode*/
          user_pref("user.theme.light.a", false); /*default light mode*/
          user_pref("user.theme.adaptive", false); /*adaptive, wip*/
          user_pref("user.theme.dark.catppuccin", false);
          user_pref("user.theme.dark.catppuccin-frappe", false);
          user_pref("user.theme.dark.catppuccin-mocha", true); /*by Draff*/
          user_pref("user.theme.dark.gruvbox", false);
          user_pref("user.theme.light.gruvbox", false);
          user_pref("user.theme.dark.midnight", false);

          /*titlebar and tabs*/
          user_pref("ultima.disable.alltabs.button", true);
          user_pref("ultima.disable.contextmenu.collapsing", true);
          user_pref("ultima.disable.windowcontrols.button", false);
          user_pref("ultima.disable.verticaltab.bar", true);
          user_pref("ultima.disable.verticaltab.bar.withindicator", true);
          user_pref("ultima.tabs.autohide", true);
          user_pref("ultima.tabs.belowURLbar", true);
          user_pref("ultima.tabs.width.small", false);
          user_pref("ultima.tabs.width.medium", true);
          user_pref("ultima.tabs.width.large", false);
          user_pref("ultima.tabs.width.huge", false);
          user_pref("ultima.spacing.compact.tabs", false);

          /*sidebar*/
          user_pref("ultima.sidebar.autohide", true);
          user_pref("ultima.sidebery.autohide", true);
          user_pref("ultima.sidebar.hidden", false);
          user_pref("ultima.sidebar.longer", false);

          /*extra theming*/
          user_pref("ultima.theme.extensions", true);
          user_pref("ultima.theme.icons", true);
          user_pref("ultima.theme.menubar", true);
          user_pref("ultima.theme.color.swap", false);

          /*url bar*/
          user_pref("ultima.navbar.autohide", false);
          user_pref("ultima.urlbar.suggestions", true);
          user_pref("ultima.urlbar.centered", true);
          user_pref("ultima.urlbar.hidebuttons", false);
          user_pref("ultima.xstyle.urlbar", false);

          /*alternate styles*/
          user_pref("ultima.spacing.compact", false);
          user_pref("ultima.xstyle.tabgroups.i", true);
          user_pref("ultima.xstyle.tabgroups.ii", false);
          user_pref("ultima.xstyle.containertabs.i", false);
          user_pref("ultima.xstyle.containertabs.ii", false);
          user_pref("ultima.xstyle.containertabs.iii", true);
          user_pref("ultima.xstyle.pinnedtabs.i", false);
          user_pref("ultima.xstyle.private", false);
          user_pref("ultima.xstyle.bookmarks.fading", false);
          user_pref("ultima.xstyle.newtab.rounded", false);

          /*override wallpapers*/
          user_pref("user.theme.wallpaper.catppuccin", false);
          user_pref("user.theme.wallpaper.catppuccin-mocha", true);
          user_pref("user.theme.wallpaper.catppuccin-frappe", false);
          user_pref("user.theme.wallpaper.dusky", false);
          user_pref("user.theme.wallpaper.fullmoon", false);
          user_pref("user.theme.wallpaper.green", false);
          user_pref("user.theme.wallpaper.gruvbox", false);
          user_pref("user.theme.wallpaper.gruvbox.flowers", false);
          user_pref("user.theme.wallpaper.gruvbox.light", false);
          user_pref("user.theme.wallpaper.midnight", false);
          user_pref("user.theme.wallpaper.midnight2", false);
          user_pref("user.theme.wallpaper.seasonal", false);
          user_pref("user.theme.wallpaper.seasonal2", false);

          /*other*/
          user_pref("ultima.enable.nightly.config", false);
          user_pref("ultima.enable.js.config", false);

          /*other other*/
          user_pref("browser.aboutConfig.showWarning", false);
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("devtools.debugger.remote-enabled", true);
          user_pref("devtools.chrome.enabled", true);
          user_pref("devtools.debugger.prompt-connection", false);
          user_pref("svg.context-properties.content.enabled", true);
          user_pref("layout.css.has-selector.enabled", true);
          user_pref("toolkit.tabbox.switchByScrolling", false);
          user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
          user_pref("widget.gtk.rounded-bottom-corners.enabled", true);
          user_pref("widget.gtk.native-context-menus", false);
          user_pref("sidebar.revamp", true);
          user_pref("sidebar.verticalTabs", true);
          user_pref("browser.tabs.groups.enabled", true);
          user_pref("browser.tabs.hoverPreview.enabled", true);
          user_pref("browser.newtabpage.activity-stream.newtabWallpapers.v2.enabled", false);
          user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", false);
          user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);

          /*accessibility*/
          user_pref("findbar.highlightAll", true);
          user_pref("browser.tabs.insertAfterCurrent", true);
          user_pref("browser.search.context.loadInBackground", true);
          user_pref("browser.bookmarks.openInTabClosesMenu", false);
          user_pref("full-screen-api.transition-duration.enter", "0 0");
          user_pref("full-screen-api.transition-duration.leave", "0 0");
          user_pref("full-screen-api.warning.timeout", 0);
          user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
          user_pref("network.http.max-connections", 300);
          user_pref("browser.urlbar.suggest.calculator", false);
          user_pref("apz.overscroll.enabled", true);
          user_pref("general.smoothScroll", true);
          user_pref("general.smoothScroll.msdPhysics.enabled", true);

          /*privacy*/
          user_pref("browser.send_pings", false);
          user_pref("dom.event.clipboardevents.enabled", false); /* clipboard telemetry */
          user_pref("dom.battery.enabled", false); /* battery telemetry.. why???*/
          user_pref("extensions.pocket.enabled", false);
          user_pref("datareporting.healthreport.uploadEnabled", false);
        '';
      userChrome =
        /*
        css
        */
        ''
          @import url(theme/all-global-positioning.css);
          @import url(theme/all-color-schemes.css);
          @import url(theme/function-sidebar-autohide.css);
          @import url(theme/function-sidebery-autohide.css);
          @import url(theme/function-privatemode.css); /* sourced from MOG */
          @import url(theme/function-urlbar.css);
          @import url(theme/function-extensions-menu.css);
          /*@import url(theme/function-safeguard.css);*/
          @import url(theme/theme-xstyle.css);
          @import url(theme/theme-context-menu.css);
          @import url(theme/theme-statuspanel.css);
          @import url(theme/theme-findbar.css);
          @import url(theme/theme-PIP.css);
          @import url(theme/theme-tab-audio-indicator.css);
          @import url(theme/nightly-override.css);
        '';
      userContent =
        /*
        css
        */
        ''
          /*
          - To remove a certain websites style, just delete its line below.
          - Then open the website in new tab, no restart needed.
          */
          @import url(theme/website-styles.css); /*styling for multiple websites*/
          @import url(theme/website-newtab.css); /*new tab page*/
          @import url(theme/website-newtab-wallpapers.css); /*new tab page wallpapers*/
          @import url(theme/website-reddit.css); /*reddit*/
          @import url(theme/website-yt.css); /*youtube*/
          @import url(theme/website-private.css); /*private new tab page */
        '';
    };
  };
  # HACK: Using `home.file` prevents the theming from properly applying. just run
  #`cp ./theme ~/.mozilla/firefox/USER_NAME/chrome/`
  # and it should work perfectly

  # home.file."${config.home.homeDirectory}/.mozilla/firefox/USER_NAME/theme" = {
  #   source = ./theme;
  #   recursive = true;
  # };
}
