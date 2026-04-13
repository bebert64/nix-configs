{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.byDb) setHeadphonesCommand setSpeakerCommand;
  homeDir = config.home.homeDirectory;
  inherit (config.byDb) modifier;
  inherit (config.byDb) ws;
  rofi = config.rofi.defaultCmd;
  music_mode = "Music: [r]adio [d]ir [l]aunch [g]irl r[e]set";
  openDir = "${pkgs.writeScriptBin "open-dir" ''
    base_dir=${config.byDb.paths.nasBase}/Musique
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
    playerctlPlayPause
    playerctlStop
    playerctlStopAll
    playerctlRestartOrPrevious
    playerctlNext
    playerctlVolumeUp
    playerctlVolumeDown
    ;
in
{
  imports = [
    ./choose-radios.nix
    ./choose-lofi-girl-playlists.nix
  ];

  home.packages = with pkgs; [
    strawberry
    pulseaudio
    spotify
  ];

  byDbPkgs = {
    strawberry-radios = {
      activationScript.enable = true;
      db = "${homeDir}/.local/share/strawberry/strawberry/strawberry.db";
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

  wayland.windowManager.sway.config = {
    assigns = {
      "\"${ws."10"}\"" = [ { class = "Strawberry|Spotify"; } ];
    };

    keybindings = lib.mkOptionDefault {
      XF86AudioRaiseVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
      XF86AudioLowerVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
      XF86AudioMute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      XF86AudioMicMute = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "${modifier}+m" = "mode \"${music_mode}\"";
    };

    modes =
      let
        # We define small scripts because if the command contains commas, swaymsg doesn't parse it correctly
        pactl_cmd =
          cmd: cmdName:
          "${pkgs.writeScriptBin "${cmdName}" ''
            pactl ${cmd}
          ''}/bin/${cmdName}";
      in
      {
        ${music_mode} = {
          "${modifier}+Left" = " exec ${playerctlRestartOrPrevious}";
          "${modifier}+Right" = "exec ${playerctlNext}";
          "Left" = "exec ${playerctlMove} - 10";
          "Right" = "exec ${playerctlMove} + 10";
          "Up" = "exec ${playerctlVolumeUp}";
          "Down" = "exec ${playerctlVolumeDown}";
          "space" = "exec ${playerctlPlayPause}, mode default";
          "s" = "exec ${playerctlStop}, mode default";
          "${modifier}+s" = "exec ${playerctlStopAll}, mode default";
          "l" = "workspace \"${ws."10"}\", exec strawberry, mode default";
          "o" = "workspace \"${ws."10"}\", exec spotify, mode default";
          "r" = "exec choose-radios, mode default";
          "g" = "exec choose-lofi-girl-playlists, mode default";
          "d" = "exec ${openDir}, mode default";
          # Allows to restart strawberry after it has crashed
          "e" = "workspace \"${ws."10"}\", exec rm /tmp/kdsingleapp-*-strawberry*, mode default";
          "${modifier}+m" = "mode default";
          "h" = "exec ${pactl_cmd setHeadphonesCommand "set-headphones-command"}, mode default";
          "p" = "exec ${pactl_cmd setSpeakerCommand "set-speaker-command"}, mode default";
          "Escape" = "mode default";
        };
      };
  };
}
