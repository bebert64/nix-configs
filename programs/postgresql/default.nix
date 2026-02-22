{ pkgs, config, lib, ... }:
{
  services.postgresql = {
    enable = true;
    # Pin the version to prevent surprise upgrades. Check current version
    # with `postgres --version` and adjust if needed before applying.
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       all     192.168.1.0/24  trust
      host  all       all     127.0.0.1/32  trust
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5432 ];
  };

  environment.systemPackages = [
    (
      let
        cfg = config.services.postgresql;
        # Set this to the target version before running the upgrade
        newPostgresVersion = pkgs.postgresql_16;
        newPostgres = newPostgresVersion.withPackages (cfg.extensions or (_: [ ]));
      in
      pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -euxo pipefail

        if [ "$(id -u)" != "0" ]; then
          echo "This script must be run as root" 1>&2
          exit 1
        fi

        systemctl stop postgresql

        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
        export NEWBIN="${newPostgres}/bin"
        export OLDDATA="${cfg.dataDir}"
        export OLDBIN="${cfg.package}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA" ${lib.escapeShellArgs (cfg.initdbArgs or [])}

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          "$@"
      ''
    )
  ];
}
