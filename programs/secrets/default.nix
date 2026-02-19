{
  sops-nix,
  pkgs,
  config,
  ...
}:
let
  byDbHomeManager = config.by-db;
  SymlinkPath = config.sops.defaultSymlinkPath;
in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
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
      compdef '_files -W "${SymlinkPath}" -/' sops-read

      sops-read () {
        PROMPT_EOL_MARK=""
        cat ${SymlinkPath}/$1
      }

      sops-edit () {
        cd ${byDbHomeManager.nixConfigsPath}/programs/secrets
        sops secrets.yaml || true
        cd -
      }

    '';
  };
}
