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
          ExecStart = "/root/.stash/stash";
        };
      };
    };
  };

  system.activationScripts = {
    symlingStashConfig = ''
      ${pkgs.coreutils}/bin/mkdir -p /root/.stash
      ${pkgs.coreutils}/bin/ln -s /home/romain/nix-configs/programs/stash/config.yml /root/.stash/config.yml
    '';
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 9999 ];
  };

}
