{
  pkgs,
  config,
  nix-ai,
  lib,
  ...
}:
{
  config = lib.mkIf config.by-db.generativeAi.enable {
    home.packages = [ nix-ai.packages.${pkgs.system}.default ];
    services = {
      ollama = {
        enable = true;
        acceleration = "cuda";
      };
    };
  };
}
