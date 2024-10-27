{ playerctl,  writeShellScript }:

writeShellScript "playerctl-polybar.sh" ''
    playerctl=${playerctl}/bin/playerctl

    status=$($playerctl status 2> /dev/null)
    title=$($playerctl metadata xesam:title 2> /dev/null)
    artist=$($playerctl metadata xesam:artist 2> /dev/null) 
    note=
    previous=
    next=
    play=
    pause=
    stop=

    button_previous="%{A1:player-ctl-restart-or-previous:}  $previous  %{A}"
    button_next="%{A1:$playerctl next:}  $next  %{A}"
    button_play="%{A1:$playerctl play:}  $play  %{A}"
    button_pause="%{A1:$playerctl pause:}  $pause  %{A}"
    button_stop="%{A1:$playerctl -a stop:}  $stop  %{A}"

    if [[ $artist = "" ]]; then
        title_display=$title
    else
        title_display="$artist - $title"
    fi

    if [[ $status == "Playing" ]]; then
        button_status=$button_pause
    else
        button_status=$button_play
    fi

    command_bar="$button_previous$button_stop$button_status$button_next"

    echo "$note   $title_display   $command_bar"
  # ''
