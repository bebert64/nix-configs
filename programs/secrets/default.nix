{
  sops-nix,
  pkgs,
  config,
  ...
}:
let
  cfg = config.by-db;
  SymlinkPath = config.sops.defaultSymlinkPath;
in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/home/${cfg.username}/.ssh/id_ed25519" ];
    secrets = {
      "1password-secret-keys/bebert64" = { };
      "1password-secret-keys/stockly" = { };
      "ffsync/bebert64" = { };
      "ffsync/shortcuts-db" = { };
      "raspi/postgresql/rw" = { };
      "stash/api-key" = { };
      "jellyfin/access-token" = { };
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
        cd $HOME/${cfg.nixConfigsRepo}/programs/secrets
        sops secrets.yaml || true
        cd -
      }

    '';
  };
}
