{ sops-nix, pkgs, config, lib, ... }:
let cfg = config.by-db; defaultSymlinkPath = "/run/user/1000/secrets"; in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    inherit defaultSymlinkPath;
    age.sshKeyPaths = [ "/home/${cfg.username}/.ssh/id_ed25519" ];
    secrets."gmail/bebert64" = { };
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
        cat ${defaultSymlinkPath}/$1
      }

    '';
  };
}


# sops = {
#   defaultSopsFile = ../secrets/example.yaml;
#   age.sshKeyPaths = [ "/home/user/.ssh/id_ed25519" ];
#   secrets.example_key = {
#     neededForUsers = true;
#   };
#   defaultSymlinkPath = "/run/user/1000/secrets";
#   defaultSecretsMountPoint = "/run/user/1000/secrets.d";

#   # secrets.example_key.owner = host-specific.username;
#   # Either the group id or group name representation of the secret group
#   # It is recommended to get the group name from `config.users.users.<?name>.group` to avoid misconfiguration
#   # secrets.example_key.group = host-specific.username;
# };
