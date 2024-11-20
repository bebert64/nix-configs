{ nixpkgs-unstable, pkgs, config, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  };
in
{
  nixpkgs.overlays = [ overlay-unstable ];

  systemd = {
    services = {
      stash = {
        enable = true;
        description = "Stash server";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.unstable.stash}/bin/stash";
        };
      };
    };
  };

  system.activationScripts = {
    symlingStashConfig = ''
      ${pkgs.coreutils}/bin/mkdir -p /root/.stash
      # ${pkgs.coreutils}/bin/ln -s ${config.home-manager.users.S}/config.yml /root/.stash/config.yml
      ${pkgs.coreutils}/bin/ln -s /home/romain/nix-configs/programS/stash/config.yml /root/.stash/config.yml
    '';
  };
}
