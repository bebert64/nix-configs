{
  config,
  nixai,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.by-db.generativeAi.enable {
    services = {
      ollama = {
        enable = true;
        acceleration = "cuda";
      };
    };
    packages = [ nixai.packages.${pkgs.system}.default ];
  };
}
