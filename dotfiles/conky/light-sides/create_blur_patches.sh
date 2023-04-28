#!/usr/bin/env bash
#Script takes a screenshot of the desktop before starting conky (using scrot),
#cuts, blurs and darkens the image and saves (using ImageMagick)
#for use as conky background

#Required settings:
# conky alignment top_left
# conky border_inner_margin 0
# conky text example: ${image ~/.conky/conky-bg.png -p -1,-1}


## Clock
# Metrics
#scrot region width = conky maximum_size width
#scrot region height = conky maximum_size height + 2x border_outer_margin
#scrot position x = conky gap_x - border_outer_margin
#scrot position y = conky gap_y - border_outer_margin

WKDIR=$HOME/.create-blur-patch-tmp/
mkdir -p $WKDIR

OFFSET_X=$(xrandr --query | grep primary | cut -d ' ' -f 4 | cut -d '+' -f 2)
OFFSET_Y=$(xrandr --query | grep primary | cut -d ' ' -f 4 | cut -d '+' -f 3)

BOM=1
SRW=300
MS=400
SRH=$(( $MS + 2*$BOM + 30))
GAPX=$((60 + $OFFSET_X))
GAPY=$((80 + $OFFSET_Y))
SPX=$(( $GAPX - $BOM ))
SPY=$(( $GAPY - $BOM ))
AREA=$(echo "$SRW""x""$SRH""+"$SPX"+""$SPY")

rm -rf $WKDIR/scrot.png
scrot $WKDIR/scrot.png

rm -rf $WKDIR/clock_crop.png
convert $WKDIR/scrot.png -crop $AREA $WKDIR/clock_crop.png

rm -rf $WKDIR/clock_dark.png
convert -brightness-contrast -5x0 $WKDIR/clock_crop.png $WKDIR/clock_dark.png

rm -f $WKDIR/clock-final-patch.png
convert $WKDIR/clock_dark.png -blur 0x10 $WKDIR/clock-final-patch.png

## Infos + Music
# Metrics
# To be filled

BOM=1
SRW=450
MS=850
SRH=$(( $MS + 2*$BOM + 30))
GAPX=$((2560 - $SRW - 100 + $OFFSET_X))
GAPY=$((1440 - $MS - 50 + $OFFSET_Y))
SPX=$(( $GAPX - $BOM ))
SPY=$(( $GAPY - $BOM ))
AREA=$(echo "$SRW""x""$SRH""+"$SPX"+""$SPY")

rm -rf $WKDIR/info_crop.png
convert $WKDIR/scrot.png -crop $AREA $WKDIR/info_crop.png

rm -rf $WKDIR/info_dark.png
convert -brightness-contrast -5x0 $WKDIR/info_crop.png $WKDIR/info_dark.png

rm -f $WKDIR/info-final-patch.png
convert $WKDIR/info_dark.png -blur 0x10 $WKDIR/info-final-patch.png

# Launch conky scripts
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
conky -c $SCRIPT_DIR/qclocktwo -d
conky -c $SCRIPT_DIR/Zavijava-v1.6/Zavijava/Zavijava.conf ./ -d

exit
