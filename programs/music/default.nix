{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.byDb) setHeadphonesCommand setSpeakerCommand;
  paths = config.byDb.paths;
  modifier = config.xsession.windowManager.i3.config.modifier;
  rofi = config.rofi.defaultCmd;
  music_mode = "Music: [r]adio [d]ir [l]aunch r[e]set";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  openDir = "${pkgs.writeScriptBin "open-dir" ''
    base_dir=${paths.nasBase}/Musique
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
    playerctlMove
    playerctlRestartOrPrevious
    ;
in
{
  imports = [ ./choose-radios.nix ];

  home.packages = with pkgs; [
    strawberry
    pulseaudio
    spotify
  ];

  byDbPkgs = {
    strawberry-radios = {
      activationScript.enable = true;
      db = "${paths.homeLocalShare}/strawberry/strawberry/strawberry.db";
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
      "$ws10" = [ { class = "Strawberry|Spotify"; } ];
    };

    keybindings = lib.mkOptionDefault {
      XF86AudioRaiseVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
      XF86AudioLowerVolume = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
      XF86AudioMute = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
      XF86AudioMicMute = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";
      "${modifier}+m" = "mode \"${music_mode}\"";
    };

    modes =
      let
        # We define small scripts because if the command contains commas, i3-msg doesn't parse it correctly
        pactl_cmd =
          cmd: cmdName:
          "${pkgs.writeScriptBin "${cmdName}" ''
            pactl ${cmd}
          ''}/bin/${cmdName}";
      in
      {
        ${music_mode} = {
          "${modifier}+Left" = " exec ${playerctlRestartOrPrevious}";
          "${modifier}+Right" = "exec ${playerctl} next";
          "Left" = "exec ${playerctlMove} - 10";
          "Right" = "exec ${playerctlMove} + 10";
          "Up" = "exec ${playerctl} volume 0.1+";
          "Down" = "exec ${playerctl} volume 0.1-";
          "space" = "exec ${playerctl} play-pause, mode default";
          "s" = "exec ${playerctl} stop, mode default";
          "${modifier}+s" = "exec ${playerctl} -a stop, mode default";
          "l" = "workspace $ws10, exec strawberry, mode default";
          "o" = "workspace $ws10, exec spotify, mode default";
          "r" = "exec choose-radios, mode default";
          "d" = "exec ${openDir}, mode default";
          # Allows to restart strawberry after it has crashed
          "e" = "workspace $ws10, exec rm /tmp/kdsingleapp-*-strawberry*, mode default";
          "${modifier}+m" = "mode default";
          "h" = "exec ${pactl_cmd setHeadphonesCommand "set-headphones-command"}, mode default";
          "p" = "exec ${pactl_cmd setSpeakerCommand "set-speaker-command"}, mode default";
          "Escape" = "mode default";
        };
      };
  };
}
