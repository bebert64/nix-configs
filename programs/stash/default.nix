{ nixpkgs-unstable, pkgs, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  };
  test-script = (pkgs.writeScriptBin "test" ''
    ${pkgs.coreutils}/bin/date >> /home/romain/test
  '');
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
          ExecStart = "${pkgs.bash}/bin/bash ${test-script}/bin/test";
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
          OnBootSec = "1s";
          OnUnitInactiveSec = "1s";
          OnUnitActiveSec = "1s";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
