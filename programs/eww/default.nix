{ pkgs, lib, ... }:
let
  polarClockScript = pkgs.writeShellScript "polar-clock" ''
    export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.jq ]}"
    ${builtins.readFile ./polar-clock.sh}
  '';
in
{
  home.packages = [ pkgs.eww ];

  xdg.configFile = {
    "eww/eww.yuck".source = ./eww.yuck;
    "eww/eww.scss".source = ./eww.scss;
    "eww/scripts/polar-clock.sh".source = "${polarClockScript}";
  };

  wayland.windowManager.sway.config.startup = [
    { command = "eww open polar-clock"; }
  ];
}
