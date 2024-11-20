{ nixpkgs-unstable, pkgs, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  };
in
{
  # environment.systemPackages = [ pkgs.unstable.stash ];

  nixpkgs.overlays = [ overlay-unstable ];

  systemd = {
    services = {
      stash = {
        enable = true;
        description = "Stash server";
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.unstable.stash}/bin/stash";
        };

      };
    };
    # timers = {
    #   stash = {
    #     Unit = {
    #       Description = "Timer for test";
    #     };
    #     Timer = {
    #       Unit = "test.service";
    #       OnBootSec = "1s";
    #       OnUnitInactiveSec = "5";
    #     };
    #     Install = {
    #       WantedBy = [ "timers.target" ];
    #     };
    #   };
    # };
  };
}
