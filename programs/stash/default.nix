{ nixpkgs-unstable, pkgs, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  };
in
{
  home.packages = [ pkgs.unstable.stash ];

  nixpkgs.overlays = [ overlay-unstable ];

  systemd.user = {
    enable = true;
    services = {
      test = {
        Unit = {
          Description = "Test";
        };
        Service = {
          Type = "exec";
          ExecStart = "${pkgs.coreutils}/bin/date >> /home/romainc/test";
        };

      };
    };
    timers = {
      test = {
        Unit = {
          Description = "Timer for test";
        };
        Timer = {
          Unit = "test.service";
          OnBootSec = "1";
          OnUnitInactiveSec = "1";
          OnUnitActiveSec = "1";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
