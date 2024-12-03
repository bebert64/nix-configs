# Waiting for stash version from nixpkgs to catch up with the installed version
# so that the schema is compatible with my current db.
{ pkgs, config, ... }:
let
  stashDir = "${config.home.homeDirectory}/.config/stash";
  nixConfigsRepo = "${config.home.homeDirectory}/${config.by-db.nixConfigsRepo}";
  stash = pkgs.callPackage ./package.nix { };
in
{
  home = {
    packages = [
      stash

      (pkgs.writeScriptBin "restore-stash" ''
        set -euxo pipefail

        rsync -aP '/mnt/NAS/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_bkp/' ${stashDir}/ --exclude "archive"
      '')
    ];

    activation = {
      symlinkStashConfig = ''
        mkdir -p ${stashDir}/
        ln -sf ${nixConfigsRepo}/programs/stash/config.yml ${stashDir}/
        ln -sf ${nixConfigsRepo}/programs/stash/scrapers ${stashDir}/
      '';
    };
  };

  systemd.user = {
    enable = true;
    services.stash = {
      Unit = {
        Description = "Stash server";
        WantedBy = [ "multi-user.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${stash}/bin/stash --config ${stashDir}/config.yml";
      };
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;
}
