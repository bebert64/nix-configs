{ sops-nix, pkgs, config, ... }:
let cfg = config.by-db; defaultSymlinkPath = "/run/user/1000/secrets"; in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    inherit defaultSymlinkPath;
    age.sshKeyPaths = [ "/home/${cfg.username}/.ssh/id_ed25519" ];
    secrets = {
      "1password-secret-keys/bebert64" = { };
      "1password-secret-keys/stockly" = { };
      "ffsync/bebert64" = { };
      "ffsync/shortcuts-db" = { };
      "github-refined-token" = { };
      "gmail/bebert64" = { };
      "gmail/stockly" = { };
      "raspi/postgresql/rw" = { };
    };
  };

  home = {
    packages = [ pkgs.sops ];
  };

  programs.zsh = {
    shellAliases = {
      sops-edit = "EDITOR=vim && cd $HOME/${cfg.nixConfigsRepo}/programs/secrets && sops secrets.yaml";
    };

    initExtra = ''
      compdef '_files -W "${defaultSymlinkPath}" -/' sops-read
      sops-read () {
        PROMPT_EOL_MARK=""
        cat ${defaultSymlinkPath}/$1
      }

    '';
  };
}
