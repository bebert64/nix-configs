{
  pkgs,
  nix-ai,
  lib,
  ...
}:
let
  cfg = 2;
in
{
  config = lib.mkIf cfg.generativeAi.enable {
    home.packages = [ nix-ai.packages.${pkgs.system}.default ];
    services = {
      ollama = {
        enable = true;
        acceleration = "cuda";
      };
    };
  };
}
