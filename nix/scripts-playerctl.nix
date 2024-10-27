{lib, pkgs, ... }: 
rec {


  move = (pkgs.writeScriptBin "playerctl-move" ''
    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") playerctl position $2$1;;
      *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
    esac

  '');

  restart-or-previous = (pkgs.writeScriptBin "playerctl-restart-or-previous" ''
    PATH=${lib.makeBinPath [ pkgs.playerctl pkgs.coreutils pkgs.strawberry]}

    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry")
        strawberry --restart-or-previous;;
      *)
        if (($(playerctl position | cut -d . -f 1) < 10)); then
          playerctl previous;
        else
          playerctl position 1;
        fi;;
    esac
  '');

  polybar = (pkgs.writeScriptBin "playerctl-polybar" ''
    playerctl=${pkgs.playerctl}/bin/playerctl

    status=$($playerctl status 2> /dev/null)
    title=$($playerctl metadata xesam:title 2> /dev/null)
    artist=$($playerctl metadata xesam:artist 2> /dev/null) 
    note=
    previous=
    next=
    play=
    pause=
    stop=

    button_previous="%{A1:${restart-or-previous}/bin/playerctl-restart-or-previous:}  $previous  %{A}"
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
  # '');
}
