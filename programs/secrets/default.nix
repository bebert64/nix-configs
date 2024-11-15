{ sops-nix, pkgs, config, lib, ... }:
let cfg = config.by-db; in
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/example.yaml;
    age.sshKeyPaths = [ "/home/user/.ssh/id_ed25519" ];
    # secrets.example_key = {
    #   owner = home-manager.users.user.name;
    #   group = home-manager.users.user.group;
    # };
  };

  home = {
    packages = [ pkgs.sops ];
    activation = {
      createSopsAgeDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/sops/age
      '';
    };
  };

  programs.zsh.shellAliases = {
    sops-edit = "cd $HOME/${cfg.nixConfigsRepo}/programs/secrets/secrets.yaml";
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
