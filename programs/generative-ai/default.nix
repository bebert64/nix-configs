{
  config,
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
        loadModels = [
          "llama3"
          "codellama"
        ];
      };
    };
  };
}
