#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WALLPAPER_NUM=$(shuf -i 1-4 -n 1)

echo "launching"
pkill conky  
feh --no-fehbg --bg-fill $SCRIPT_DIR/conky_bg$WALLPAPER_NUM.jpg
conky -c $SCRIPT_DIR/qclocktwo -d
echo "clock done"
conky -c $SCRIPT_DIR/Zavijava-v1.6/Zavijava/Zavijava.conf ./ -d
echo "done"
