{
  sops-nix,
  pkgs,
  config,
  ...
}:
let
  homeManagerBydbConfig = config.byDb;
  symlinkPath = config.sops.defaultSymlinkPath;
in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "${homeManagerBydbConfig.paths.home}/.ssh/id_ed25519" ];
    secrets = {
      "1password-secret-keys/bebert64" = { };
      "1password-secret-keys/stockly" = { };
      "ffsync/bebert64" = { };
      "ffsync/shortcuts-db" = { };
      "raspi/postgresql/rw" = { };
      "stash/api-key" = { };
      "jellyfin/guitar/access-token" = { };
      "jellyfin/media/access-token" = { };
      "radio-france/api-key" = { };
    };
  };

  home = {
    packages = [ pkgs.sops ];
  };

  programs.zsh = {
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
