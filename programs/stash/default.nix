# Waiting for stash version from nixpkgs to catch up with the installed version
# so that the schema is compatible with my current db.
# { nixpkgs-unstable, pkgs, config, ... }:
{ pkgs, config, ... }:
let
  hmCfg = config.home-manager.users.${config.by-db.username};
  nixConfigsRepo = hmCfg.by-db.nixConfigsRepo;
  #   overlay-unstable = final: prev: {
  #     unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  #   };
in
{
  # nixpkgs.overlays = [ overlay-unstable ];

  systemd = {
    services = {
      stash = {
        enable = true;
        description = "Stash server";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "/stash/stash --config /stash/config.yml";
        };
      };
    };
  };

  system.activationScripts = {
    symlingStashConfig = ''
      ${pkgs.coreutils}/bin/mkdir -p /stash
      ${pkgs.coreutils}/bin/ln -s ${nixConfigsRepo}/programs/stash/config.yml /stash/config.yml
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 9999 ];
  };
}
