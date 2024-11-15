{ sops-nix, home-manager, ... }:
{

  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/example.yaml;
    age.sshKeyPaths = [ "/home/user/.ssh/id_ed25519" ];
    secrets.example_key = {
      owner = home-manager.users.user.name;
      group = home-manager.users.user.group;
    };
  };
}
