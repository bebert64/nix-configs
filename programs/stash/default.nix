{
  pkgs,
  config,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
  stashDir = "${cfgUser.home.homeDirectory}/.stash";
  stash = pkgs.stash;
in
{
  home-manager.users.${config.by-db.user.name} = {
    home = {
      packages = [
        stash
        pkgs.ffmpeg
      ];

      file = {
        "${stashDir}/scrapers".source = ./scrapers;
      };
    };

    systemd.user = {
      enable = true;
      services.stash = {
        Unit = {
          Description = "Stash server";
        };
        Service = {
          Type = "simple";
          Restart = "on-failure";
          ExecStart = "${stash}/bin/stash --config ${stashDir}/config.yml --nobrowser";
          Environment = "PATH=/run/current-system/sw/bin/:${cfgUser.home.homeDirectory}/.nix-profile/bin/";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;
}
