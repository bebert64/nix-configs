{
  config,
  lib,
  ...
}:
let
  userConfig = config.byDb.user;
  homeDir = "/home/${userConfig.name}";
  plansDir = "${homeDir}/.claude/plans";

  # Device IDs — fill these in after first run on each machine
  # Get the ID with: syncthing cli show system | jq -r .myID
  deviceIds = {
    bureau = "REPLACE-ME";
    salon = "REPLACE-ME";
    raspi4 = "5CQXE76-VF5NYUC-MPHH4MI-TC4FRHU-4CAMAXT-I7FGEIX-GIDSASJ-OMTT6AV";
    stockly-romainc = "NBWSZFL-ATUO5NW-DICUY5X-A7PCCMJ-Y4PCIQB-RVL6WKP-XMHGSVT-5ZXDRQV";
  };

  hostName = config.networking.hostName;

  otherDevices = lib.filterAttrs (name: _: name != hostName) deviceIds;
in
{
  config = {
    services.syncthing = {
      enable = true;
      user = userConfig.name;
      group = "users";
      dataDir = "${homeDir}/.local/share/syncthing";
      configDir = "${homeDir}/.config/syncthing";
      openDefaultPorts = true;
      settings = {
        devices = lib.mapAttrs (_name: id: { id = id; }) otherDevices;
        folders = {
          "claude-plans" = {
            path = plansDir;
            devices = lib.attrNames otherDevices;
            versioning = {
              type = "simple";
              params.keep = "5";
            };
          };
        };
      };
    };

    # Ensure the sync directory exists
    system.activationScripts.createClaudePlansDir = ''
      mkdir -p ${plansDir}
      chown ${userConfig.name}:users ${plansDir}
    '';

    # Open firewall for Syncthing discovery
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
  };
}
