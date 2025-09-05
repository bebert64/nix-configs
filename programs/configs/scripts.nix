{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{

  home.packages = [
    (writeScriptBin "psg" ''
      set -euo pipefail

      ps aux | grep $1 | grep -v psg | grep -v grep
    '')

    (writeScriptBin "run" ''
      set -euxo pipefail

      nix run "nixpkgs#$1" -- "''${@:2}"
    '')
  ];

}
