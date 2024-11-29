{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.by-db;
  modifier = config.xsession.windowManager.i3.config.modifier;
  music_mode = "Music";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  inherit (import ./scripts.nix { inherit cfg pkgs; })
    playerctl-move
    playerctl-restart-or-previous
    set-headphones
    set-speaker
    ;
in
{
  imports = [ ./choose-radios.nix ];

  home.packages = [ pkgs.strawberry ];

  by-db-pkgs = {
    strawberry-radios = {
      activationScript.enable = true;
      radios = [
        {
          name = "FIP";
          url = "http://direct.fipradio.fr/live/fip-midfi.mp3";
        }
        {
          name = "FIP Jazz";
          url = "http://direct.fipradio.fr/live/fipjazz-midfi.mp3";
        }
        {
          name = "FIP Rock";
          url = "http://direct.fipradio.fr/live/fiprock-midfi.mp3";
        }
        {
          name = "FIP Groove";
          url = "http://direct.fipradio.fr/live/fipgroove-midfi.mp3";
        }
        {
          name = "FIP Reggae";
          url = "http://direct.fipradio.fr/live/fipreggae-midfi.mp3";
        }
        {
          name = "FIP Pop";
          url = "http://direct.fipradio.fr/live/fippop-midfi.mp3";
        }
        {
          name = "FIP Monde";
          url = "http://direct.fipradio.fr/live/fipworld-midfi.mp3";
        }
        {
          name = "FIP Nouveautés";
          url = "http://direct.fipradio.fr/live/fipnouveautes-midfi.mp3";
        }
        {
          name = "Radio Nova";
          url = "http://broadcast.infomaniak.ch/radionova-high.mp3";
        }
        {
          name = "Radio Swiss Classic";
          url = "http://stream.srg-ssr.ch/m/rsc_fr/mp3_128";
        }
        {
          name = "Chillhop Music";
          url = "https://streams.fluxfm.de/Chillhop/mp3-128/streams.fluxfm.de/";
        }
      ];
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws10" = [ { class = "strawberry"; } ];
    };

    keybindings = lib.mkOptionDefault {
      XF86AudioRaiseVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
      XF86AudioLowerVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
      XF86AudioMute = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
      XF86AudioMicMute = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";
      "${modifier}+m" = "mode \"${music_mode}\"";
    };

    modes = {
      ${music_mode} = {
        "${modifier}+Left" = " exec ${playerctl-restart-or-previous}";
        "${modifier}+Right" = "exec ${playerctl} next";
        "Left" = "exec ${playerctl-move} - 10";
        "Right" = "exec ${playerctl-move} + 10";
        "Up" = "exec ${playerctl} volume 0.1+";
        "Down" = "exec ${playerctl} volume 0.1-";
        "space" = "exec ${playerctl} play-pause, mode default";
        "s" = "exec ${playerctl} stop, mode default";
        "${modifier}+s" = "exec ${playerctl} -a stop, mode default";
        "l" = "workspace $ws10, exec strawberry, mode default";
        "r" = "exec choose-radios, mode default";
        "${modifier}+m" = "mode default";
        "h" = "exec ${set-headphones}, mode default";
        "p" = "exec ${set-speaker}, mode default";
        "Escape" = "mode default";
      };
    };
  };
}
