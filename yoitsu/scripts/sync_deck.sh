#!/usr/bin/env bash
DECK_PATH="oled:/run/media/mmcblk0p1/Emulation/storage/yuzu/nand/user/save/0000000000000000/0F22DD4F9448B1A9580F6ED574AA71E7/0100A6301214E000"
DESK_PATH="/home/hirschy/.local/share/yuzu/nand/user/save/0000000000000000/E31DD8924A3F540D1B6ED876399DBEDF/0100A6301214E000"

copy_to_deck() {
 rsync -rah --info=progress2 "$DESK_PATH/"  "$DECK_PATH/"

}
copy_to_desktop() {
 rsync -rah --info=progress2 "$DECK_PATH/" "$DESK_PATH/"
}
# Check command-line arguments
case "$1" in
    --to-deck)
        copy_to_deck
        ;;
    --to-desktop)
        copy_to_desktop
        ;;
    *)
        echo "Warning: Invalid option. Use --to-deck or --to-desktop."
        exit 1
        ;;
esac
