# Waiting for stash version from nixpkgs to catch up with the installed version
# so that the schema is compatible with my current db.
{ pkgs, config, ... }:
let
  nixConfigsRepo = "${config.home.homeDirectory}/${config.by-db.nixConfigsRepo}";
  stash = pkgs.callPackage ./package.nix { };
in
{
  home = {
    packages = [
      stash
    ];

    activation = {
      symlinkStashConfig = ''
        mkdir -p ${config.home.homeDirectory}/.config/stash/
        ln -sf ${nixConfigsRepo}/programs/stash/config.yml ${config.home.homeDirectory}/.config/stash/
        ln -sf ${nixConfigsRepo}/programs/stash/scrapers ${config.home.homeDirectory}/.config/stash/
      '';
    };
  };

  systemd.user = {
    enable = true;
    services.stash = {
      Unit = {
        Description = "Stash server";
      };
      Install = {
        WantedBy = [ "multi-user.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${stash}/bin/stash --config ${config.home.homeDirectory}/.config/stash/config.yml";
      };
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;
}
