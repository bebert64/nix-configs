{
  pkgs,
  config,
  nix-ai,
  lib,
  ...
}:
let
  cfg = config.home-manager.users.${config.by-db.user.name};
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
