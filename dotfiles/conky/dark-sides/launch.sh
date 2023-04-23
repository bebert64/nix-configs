#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WALLPAPER=$(ls $SCRIPT_DIR/wallpapers | sort -R | tail -1)

echo  $SCRIPT_DIR/wallpapers/$WALLPAPER

pkill conky  
feh --no-fehbg --bg-fill "$SCRIPT_DIR/wallpapers/$WALLPAPER"
conky -c $SCRIPT_DIR/qclocktwo -d
conky -c $SCRIPT_DIR/Zavijava-v1.6/Zavijava/Zavijava.conf ./ -d
