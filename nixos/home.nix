host-specific: { pkgs, lib, ... }@inputs:

let
  monoFont = "DejaVu Sans Mono";
  args = ({ inherit monoFont; } // inputs);
in
{

  # Packages Home-Manager doesn't have specific handling for
  home.packages = with pkgs; 
  let
    polybar = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
  in
  [
    anydesk
    arandr # GUI to configure screens positions (need to kill autorandr)
    # autorandr
    avidemux
    btop
    caffeine-ng # to prevent going to sleep when watching videos
    dconf # used for setting/loading gnome applications' settings (eg : tilix)
    evince # pdf reader
    feh
    firefox-bin-unwrapped
    gnome.gnome-keyring
    grsync # check if rsync needed in addition
    i3lock-color
    ifuse # mount apple's file system (Ipad)
    inkscape
    (insomnia.overrideAttrs (oldAttrs: rec {
      pname = "insomnia-stockly";
      version = "2022.7.0";
      src = fetchurl {
        url = "https://stockly-public-assets.s3.eu-west-1.amazonaws.com/Insomnia.Core-2022.7.0-patched.deb";
        sha256 = "sha256-6abpLq1ykAfn7ag5hY2Y6e53kx7svkSb+7OdWSDRLbE=";
      };
    }))
    jetbrains.datagrip
    killall # for some reason, not included by default
    microcodeIntel # for increased microprocessor performance
    nodejs
    nodePackages.npm
    pavucontrol # pulse audio volume controle
    polybar
    qbittorrent
    rofi
    slack
    sqlite
    steam-run # needed to run custom binaries
    sshfs
    thunderbird-bin-unwrapped
    tilix # terminal
    udiskie # automount usb keys and drives
    unrar
    vlc
    vscode
    xss-lock
    yt-dlp

    # polkit is the utility used by vscode to save as sudo
    polkit
    polkit_gnome

    # Theme for QT applications (vlc, strawberry...)
    qt5ct
    libsForQt5.qtstyleplugins

    # Ranger
    ranger
    ffmpegthumbnailer # thumbnail for videos preview
    fontforge # thumbnail for fonts preview
    poppler_utils # thumbnail for pdf preview

    # Rust
    rustup
    pkg-config
    gcc

    # Strawberry
    strawberry
    playerctl # to send data and retrieve metadata for polybarF

    # Scripts
    (pkgs.writeScriptBin "run" ''
      #!/usr/bin/env bash
      set -euxo pipefail
      nix-shell -p "$1" --command "''${1##*.} ''${*:2}"
    '')

    (pkgs.writeScriptBin "mount-Ipad" ''
      #!/usr/bin/env bash
      
      mkdir -p /mnt/Ipad/SideBooks
      ifuse --documents jp.tatsumi-sys.sidebooks /mnt/Ipad/SideBooks
      mkdir -p /mnt/Ipad/Chunky
      ifuse --documents com.mike-ferenduros.Chunky-Comic-Reader /mnt/Ipad/Chunky
      mkdir -p /mnt/Ipad/MangaStorm
      ifuse --documents com.wayudaorerk.mangastormall /mnt/Ipad/MangaStorm
    '')

    (pkgs.writeScriptBin "umount-Ipad" ''
      #!/usr/bin/env bash

      fusermount -u /mnt/Ipad/SideBooks
      fusermount -u /mnt/Ipad/Chunky
      fusermount -u /mnt/Ipad/MangaStorm
    '')

    (pkgs.writeScriptBin "available-size-Ipad" ''
      #!/usr/bin/env bash
      df /mnt/Ipad-SideBooks | grep ifuse | tr -s ' ' | cut -d ' ' -f4m
    '')

    (pkgs.writeScriptBin "open-code" ''
      #!/usr/bin/env bash
      relative_path=$(pwd | cut -d'/' -f4-)
      code --folder-uri=vscode-remote://ssh-remote+charybdis/home/romain/$relative_path
    '')

    (pkgs.writeScriptBin "playerctl_polybar" ''
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

      button_previous="%{A1:strawberry --restart-or-previous:}  $previous  %{A}"
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
    '')

  ] ++ (
    if host-specific.wifi then 
      [
        networkmanager
        networkmanagerapplet
      ] else []
    );


  # Programs known by Home-Manager
  programs = {
    autorandr = host-specific.autorandr;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    git = import ./programs/git.nix;
    vim = {
      extraConfig = ''
        set autoindent
        set number
        syntax on
      '';
    };
    zsh = import ./programs/zsh.nix;
  };

  # Services
  services = {
    picom = {
      enable = true;
      settings = {
        corner-radius = 10;
        rounded-corners-exclude = [
           "window_type = 'dock'"
        ];
      };
    };
  };

  # Copy custom files / dotfiles
  home.file.".config/qt5ct/qt5ct.conf".source = ../dotfiles/qt5ct.conf;
  home.file.".config/polybar".source = ../dotfiles/polybar;
  home.file.".ssh/config".source = ../dotfiles/ssh_config;
  home.file.".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ../dotfiles/MonokaiStockly;
  home.file.".tilix.dconf".source = ../dotfiles/tilix.dconf;
  home.file.".config/oh-my-zsh-scripts/git.zsh".source = ../dotfiles/OhMyZsh/git.zsh;
  home.file.".config/ranger/rc.conf".source = ../dotfiles/ranger/rc.conf;
  home.file.".config/ranger/scope.sh".source = ../dotfiles/ranger/scope.sh;
  home.file.".local/share/ranger/bookmarks".source = ../dotfiles/ranger/bookmarks;

  # X Config
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = import ./programs/i3.nix (args // { host-specific = host-specific; });
    numlock.enable = true;
  };
  gtk = {
    enable = true;
    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };
  };

  # Session variable
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # General settings
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; # Necessary for vscode
  home.stateVersion = "22.05";
}
