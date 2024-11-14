{ cfg
, pkgs
, lib
,
}:
let
  inherit (cfg)
    setHeadphonesCommand
    setSpeakerCommand
    ;
  inherit (lib) makeBinPath;
  inherit (pkgs)
    coreutils
    playerctl
    pulseaudio
    strawberry
    writeScriptBin
    ;
in
{
  playerctl-move = "${writeScriptBin "playerctl-move" ''
    CURRENT_PLAYER=$(playerctl --list-all | head -n 1)

    case $CURRENT_PLAYER in
      "strawberry") playerctl position $2$1;;
      *) playerctl position $(expr $(playerctl position | cut -d . -f 1) $1 $2);;
    esac
  ''}/bin/playerctl-move";

  playerctl-restart-or-previous = "${writeScriptBin "playerctl-restart-or-previous" ''
    PATH=${
      makeBinPath [
        playerctl
        coreutils
        strawberry
      ]
    }

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
  ''}/bin/playerctl-restart-or-previous";

  set-headphones = "${writeScriptBin "set-headphones" ''
    PATH=${makeBinPath [ pulseaudio ]}
    pactl ${setHeadphonesCommand}
  ''}/bin/set-headphones";

  set-speaker = "${writeScriptBin "set-speaker" ''
    PATH=${makeBinPath [ pulseaudio ]}
    pactl ${setSpeakerCommand}
  ''}/bin/set-speaker";
}
