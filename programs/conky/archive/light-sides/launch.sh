#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WALLPAPER=$(ls $SCRIPT_DIR/wallpapers | sort -R | tail -1)

echo  $SCRIPT_DIR/wallpapers/$WALLPAPER

i3-msg "workspace \" \"; workspace \"  \""
pkill conky  
feh --no-fehbg --bg-fill "$SCRIPT_DIR/wallpapers/$WALLPAPER"

$SCRIPT_DIR/create_blur_patches.sh &
