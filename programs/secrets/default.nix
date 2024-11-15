{ sops-nix, pkgs, config, lib, ... }:
let cfg = config.by-db; defaultSymlinkPath = "/run/user/1000/secrets"; in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    inherit defaultSymlinkPath;
    age.sshKeyPaths = [ "/home/${cfg.username}/.ssh/id_ed25519" ];
    secrets = {
      "gmail/bebert64" = { };
      "gmail/shortcuts-db" = { };
    };
  };

  home = {
    packages = [ pkgs.sops ];
    activation = {
      createSopsAgeDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/sops/age
      '';
    };
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
