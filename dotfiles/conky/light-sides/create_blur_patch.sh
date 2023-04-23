#!/usr/bin/env bash
#Script takes a screenshot of the desktop before starting conky (using scrot),
#cuts, blurs and darkens the image and saves (using ImageMagick)
#for use as conky background

#Required settings:
# conky alignment top_left
# conky border_inner_margin 0
# conky text example: ${image ~/.conky/conky-bg.png -p -1,-1}
#Metrics
#scrot region width = conky maximum_size width
#scrot region height = conky maximum_size height + 2x border_outer_margin
#scrot position x = conky gap_x - border_outer_margin
#scrot position y = conky gap_y - border_outer_margin

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo $SCRIPT_DIR/blur-patch.png
CONKYCONF="$SCRIPT_DIR/qclocktwo"

BOM=0
SRW=300
MS=400
SRH=$(( $MS + 2*$BOM + 30))
GAPX=60
GAPY=80
SPX=$(( $GAPX - $BOM ))
SPY=$(( $GAPY - $BOM ))
AREA=$(echo "$SRW""x""$SRH""+"$SPX"+""$SPY")

#notify-send "Conky Metrics Test:" "$AREA"

scrot $SCRIPT_DIR/temp1.png
convert $SCRIPT_DIR/temp1.png -region $AREA -blur 0x10 +region $SCRIPT_DIR/temp2.png
convert -brightness-contrast -10x0 $SCRIPT_DIR/temp2.png $SCRIPT_DIR/temp3.png
convert $SCRIPT_DIR/temp3.png -crop $AREA $SCRIPT_DIR/blur-patch.png

rm $SCRIPT_DIR/temp1.png
rm $SCRIPT_DIR/temp2.png
rm $SCRIPT_DIR/temp3.png

exit
