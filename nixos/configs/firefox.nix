{ inputs, pkgs, system, username, config, ... }:
{
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
        lastpass-password-manager
        ublock-origin
        sponsorblock
        enhancer-for-youtube
        return-youtube-dislikes
        behind-the-overlay-revival
        betterttv
        nighttab
      ];
      search = {
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
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
                  tags = [ "wiki" "nix" ];
                  url = "https://nixos.wiki/";
                }
            ];
            }
            {
              name = "Homelab";
              bookmarks = [
              {
                name = "Plex";
                url = "http://srv-prod-nas.home.USER_NAMEkiss.net:32400/web/index.html#!";
              }
              {
                name = "Proxmox";
                url = "https://srv-prod-proxmox.home.USER_NAMEkiss.net:8006/#v1:0:18:4:::::::";
              }
              {
                name = "Home Assistant";
                url = "http://srv-prod-hac.home.USER_NAMEkiss.net:8123/lovelace/HPCA";
              }
              {
                name = "Router";
                url = "https://router.home.USER_NAMEkiss.net/network/default/dashboard";
              }
               {
                name = "Docker";
                url = "http://srv-prod-docker.home.USER_NAMEkiss.net:9000";
              }
             {
                name = "NAS";
                url = "https://srv-prod-nas.home.USER_NAMEkiss.net/ui/dashboard";
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
                url = "https://github.USER_NAMEkiss.net/";
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
                url = "https://github.com/HirschBerge/my-dotfiles";
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
              url = "https://allanime.to/search-anime?tr=sub&cty=ALL";
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
            {
              name = "CMU Workday";
              url = "https://wd5.myworkday.com/cmu/d/home.htmld";
            }
          ];
        }
      ];
    };
  };
}
