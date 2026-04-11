{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = config.byDb.modifier;
  rofi = config.rofi.defaultCmd;
  homeDir = config.home.homeDirectory;
  sshr = "${pkgs.writeScriptBin "sshr" ''
    kitty --title "Ranger ($1)" kitten ssh $1 -t ranger
  ''}/bin/sshr";
  openRemote = "${pkgs.writeScriptBin "open-remote" ''
    selection=$(
      grep -P "^Host ([^*]+)$" ${homeDir}/.ssh/config | \
      sed 's/Host //' | \
      tr ' ' '\n' | \
      sort -u | \
      grep -v "$(hostname)" | \
      ${rofi}
    )
    [ -n "$selection" ] || exit 0
    ${sshr} "$selection"
  ''}/bin/open-remote";
in
{
  imports = [ ./common.nix ];

  byDb.ranger.bookmarksFile = ./bookmarks/default;

  home.packages = [ pkgs.wl-clipboard ];

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "${modifier}+Control+r" = "workspace $ws7; exec kitty -e ranger";
    "${modifier}+Shift+r" = "workspace $ws7; exec ${openRemote}";
  };
}
