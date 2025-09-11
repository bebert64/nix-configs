{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.by-db;
  inherit (cfg) setHeadphonesCommand setSpeakerCommand;
  modifier = config.xsession.windowManager.i3.config.modifier;
  rofi = config.rofi.defaultCmd;
  music_mode = "Music";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  open-dir = "${pkgs.writeScriptBin "open-dir" ''
    base_dir=$HOME/mnt/NAS/Musique
    selection=$(
      ${pkgs.fd}/bin/fd . --type dir --base-directory $base_dir 2>/dev/null | \
      grep -v "@eaDir"| \
      sort -u | \
      ${rofi} -l 30 -theme-str 'window {width: 20%;}'
    )

    if [[ ! $selection ]]; then
        exit 0
    fi
    playlist_title=$(echo $selection | sed 's/.$//' | sed 's/\// - /g')

    strawberry -c "$playlist_title" "$base_dir/$selection" &
    sleep 2
    strawberry --play-playlist "$playlist_title" &
  ''}/bin/open-dir";
  inherit (import ./scripts.nix { inherit pkgs; })
    playerctl-move
    playerctl-restart-or-previous
    ;
in
{
  imports = [ ./choose-radios.nix ];

  home.packages = with pkgs; [
    strawberry
    pulseaudio
  ];

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
        {
          name = "Piano Zen";
          url = "https://stream.radiofrance.fr/francemusiquepianozen/francemusiquepianozen.m3u8?id=radiofranceBose";
        }
      ];
    };
  };

  xsession.windowManager.i3.config = {
    assigns = {
      "$ws10" = [ { class = "Strawberry"; } ];
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
        "d" = "exec ${open-dir}, mode default";
        "${modifier}+m" = "mode default";
        "h" = "exec pactl ${setHeadphonesCommand}, mode default";
        "p" = "exec pactl ${setSpeakerCommand}, mode default";
        "Escape" = "mode default";
      };
    };
  };
}
