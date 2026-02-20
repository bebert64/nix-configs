{
  pkgs,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  stashDir = "${homeDir}/.stash";
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
        Environment = "PATH=/run/current-system/sw/bin/:${homeDir}/.nix-profile/bin/";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
