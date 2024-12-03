# Waiting for stash version from nixpkgs to catch up with the installed version
# so that the schema is compatible with my current db.
{ pkgs, config, ... }:
let
  nixConfigsRepo = "${config.homeDirectory}/${config.by-db.nixConfigsRepo}";
  stash = pkgs.callPackage ./package.nix { };
in
{
  home = {
    packages = [
      stash
    ];

    activationScript = {
      symlinkStashConfig = ''
        mkdir -p ${config.homeDirectory}/.config/stash/
        ln -sf ${nixConfigsRepo}/programs/stash/config.yml ${config.homeDirectory}/.config/stash/
        ln -sf ${nixConfigsRepo}/programs/stash/scrapers ${config.homeDirectory}/.config/stash/
      '';
    };

    systemd = {
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
          ExecStart = "${stash}/bin/stash --config ${config.homeDirectory}/.config/stash/config.yml";
        };
      };
    };
  };
}
