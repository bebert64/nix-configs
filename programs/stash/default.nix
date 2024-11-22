# Waiting for stash version from nixpkgs to catch up with the installed version
# so that the schema is compatible with my current db.
{ pkgs, config, ... }:
let
  hmCfg = config.home-manager.users.${config.by-db.user.name};
  nixConfigsRepo = "${hmCfg.home.directory}/${hmCfg.by-db.nixConfigsRepo}";
in
{
  # environment.systemPackages = [ pkgs.stash ];

  systemd = {
    services = {
      stash = {
        enable = true;
        description = "Stash server";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "exec";
          # ExecStart = "stash --config /stash/config.yml";
          ExecStart = "/stash/stash --config /stash/config.yml";
        };
      };
    };
  };

  system.activationScripts = {
    symlingStashConfig = ''
      ${pkgs.coreutils}/bin/mkdir -p /stash
      ${pkgs.coreutils}/bin/ln -sf ${nixConfigsRepo}/programs/stash/config.yml /stash/
      ${pkgs.coreutils}/bin/ln -sf ${nixConfigsRepo}/programs/stash/scrapers /stash/
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
      9999
    ];
  };
}
