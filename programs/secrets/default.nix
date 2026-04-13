{
  sops-nix,
  pkgs,
  config,
  ...
}:
let
  homeManagerBydbConfig = config.byDb;
  homeDir = config.home.homeDirectory;
  symlinkPath = config.sops.defaultSymlinkPath;
in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "${homeDir}/.ssh/id_ed25519" ];
    secrets = {
      "1password-secret-keys/bebert64" = { };
      "1password-secret-keys/stockly" = { };
      "code/mcp/asana-token" = { };
      "ffsync/bebert64" = { };
      "ffsync/shortcuts-db" = { };
      "jellyfin/guitar/access-token" = { };
      "jellyfin/media/access-token" = { };
      "notion/personal-token" = { };
      "radio-france/api-key" = { };
      "raspi/postgresql/rw" = { };
      "spotify/client_id" = { };
      "spotify/client_secret" = { };
      "spotify/refresh_token" = { };
      "stash/api-key" = { };
      "stockly/dbs/backoffice" = { };
      "stockly/dbs/buckets" = { };
      "stockly/dbs/files" = { };
      "stockly/dbs/invoices" = { };
      "stockly/dbs/operations" = { };
      "stockly/dbs/repackages" = { };
      "stockly/dbs/shipments" = { };
      "stockly/dbs/stocks" = { };
      "stockly/dbs/supply-messages" = { };
      "stockly/mcp/notion-token" = { };
      "stockly/mcp/sentry-token" = { };
    };
  };

  home = {
    packages = [ pkgs.sops ];
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      compdef '_files -W "${symlinkPath}" -/' sops-read

      sops-read () {
        PROMPT_EOL_MARK=""
        cat ${symlinkPath}/$1
      }

      sops-edit () {
        cd ${homeManagerBydbConfig.paths.nixPrograms}/secrets
        sops secrets.yaml || true
        cd -
      }

    '';
  };
}
