{ nixpkgs-unstable, pkgs, ... }:
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
          ExecStart = "${pkgs.unstable.stash}/bin/stash --config /usr/local/etc/stash/config.yml";
        };
      };
    };
  };

  system.activationScripts = {
    symlingStashConfig = ''
      ${pkgs.coreutils}/bin/mkdir -p /usr/local/etc/stash
      ${pkgs.coreutils}/bin/ln -s ${./config.yml} /usr/local/etc/stash/config.yaml
    '';
  };
}
