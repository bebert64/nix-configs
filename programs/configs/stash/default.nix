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
        (pkgs.writeScriptBin "restore-stash" ''
          set -euxo pipefail

          rsync -aP '/mnt/NAS/Comics/Fini/Planet of the Apes/14 Planet of the Apes issues/Elseworlds/stash_bkp/' ${stashDir}/ --exclude "archive"
        '')
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
          Type = "exec";
          ExecStart = "${stash}/bin/stash --config ${stashDir}/config.yml --nobrowser";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  services.nginx.virtualHosts."stash.capucina.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9999";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60000s;
      '';
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;
}
