#!/usr/bin/env bash

playerctlstatus=$(playerctl -p strawberry status 2> /dev/null)
title=$(playerctl -p strawberry metadata xesam:title 2> /dev/null)
artist=$(playerctl -p strawberry metadata xesam:artist 2> /dev/null)
radio_title=`cat /home/romain/.config/polybar/.radio_title`
note=
previous=
next=
play=
pause=
stop=

button_previous="%{A1:playerctl -p strawberry previous:}  $previous  %{A}"
button_next="%{A1:playerctl -p strawberry next:}  $next  %{A}"
button_play="%{A1:playerctl -p strawberry play:}  $play  %{A}"
button_pause="%{A1:playerctl -p strawberry pause:}  $pause  %{A}"
button_stop="%{A1:playerctl -p strawberry stop:}  $stop  %{A}"

if [[ $title = http* ]]; then
    if [ -z "$radio_title" ]; then
        title_display="Radio youtube"
    else
        title_display=$radio_title
    fi
elif [[ $artist = "" ]]; then
    title_display=$title
else
    title_display="$artist - $title"
fi

if [[ $playerctlstatus == "Playing" ]]; then
    button_status=$button_pause
else
    button_status=$button_play
fi

command_bar="$button_previous$button_stop$button_status$button_next"

echo "$note   $title_display   $command_bar"
