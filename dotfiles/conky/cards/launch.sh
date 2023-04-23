#!/usr/bin/env bash

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_DIR=/home/romain/configs/dotfiles/conky/cards
WALLPAPER=$(ls $SCRIPT_DIR/wallpapers | sort -R | tail -1)

pkill conky  
feh --no-fehbg --bg-fill "$SCRIPT_DIR/wallpapers/$WALLPAPER"

conky -c $SCRIPT_DIR/filesystem_rc -d
conky -c $SCRIPT_DIR/processes_rc -d
conky -c $SCRIPT_DIR/music_rc -d
conky -c $SCRIPT_DIR/qclocktwo -d
