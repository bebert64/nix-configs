{
  pkgs,
  config,
  ...
}:
let
  userConfig = config.byDb.hmUser;
  stashDir = "${userConfig.home.homeDirectory}/.stash";
  stash = pkgs.stash;
in
{
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
        Environment = "PATH=/run/current-system/sw/bin/:${userConfig.home.homeDirectory}/.nix-profile/bin/";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
