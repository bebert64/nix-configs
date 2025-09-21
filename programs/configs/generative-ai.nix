{
  config,
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
      nixai = {
        enable = true;
        mcp.enable = true;
      };
    };
  };
}
