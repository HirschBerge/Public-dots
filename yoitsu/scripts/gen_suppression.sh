#!/usr/bin/env sh

NoColor="\033[0m"
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

file_path="/home/hirschy/.config/pipewire/pipewire.conf.d/"
[ -d "$file_path" ] || mkdir -p $file_path
[ -f "$file_path/99-input-denoising" ] || touch "$file_path/99-input-denoising.conf"
pkg_path="$(nix-store --query --requisites /run/current-system |grep -m 1 rnnoise)/lib/ladspa/librnnoise_ladspa.so"
echo -en "
context.modules = [
{   name = libpipewire-module-filter-chain
    args = {
        node.description =  \"Noise Canceling source\"
        media.name =  \"Noise Canceling source\"
        filter.graph = {
            nodes = [
                {
                    type = ladspa
                    name = rnnoise
                    plugin = \"$pkg_path\"
                    label = noise_suppressor_mono
                    control = {
                        \"VAD Threshold (%)\" = 40.0
                        \"VAD Grace Period (ms)\" = 100
                        \"Retroactive VAD Grace (ms)\" = 0
                    }
                }
            ]
        }
        capture.props = {
            node.name =  \"capture.rnnoise_source\"
            node.passive = true
            audio.rate = 48000
        }
        playback.props = {
            node.name =  \"rnnoise_source\"
            media.class = Audio/Source
            audio.rate = 48000
        }
    }
}
]
" > "$file_path/99-input-denoising.conf"


printf "${Green}[+]${NoColor} Completed generating ${Purple} ~/.config/pipewire/pipewire.config.d/99-input-denoising.conf${NoColor}"
