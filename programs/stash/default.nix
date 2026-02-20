{
  pkgs,
  config,
  ...
}:
let
  homeDirectory = config.byDb.hmUser.home.homeDirectory;
  stashDirectory = "${homeDirectory}/.stash";
  stash = pkgs.stash;
in
{
  home = {
    packages = [
      stash
      pkgs.ffmpeg
    ];

    file = {
      "${stashDirectory}/scrapers".source = ./scrapers;
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
        ExecStart = "${stash}/bin/stash --config ${stashDirectory}/config.yml --nobrowser";
        Environment = "PATH=/run/current-system/sw/bin/:${homeDirectory}/.nix-profile/bin/";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
