{
  config,
  ...
}:
let
  instanceName = "main";
  autheliaUser = "authelia-${instanceName}";
in
{
  services.authelia.instances.${instanceName} = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storage_encryption_key".path;
      sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
    };

    settings = {
      theme = "auto";

      server.address = "tcp://127.0.0.1:9091";

      log.level = "info";

      authentication_backend.file.path = config.sops.secrets."authelia/users_database".path;

      session.cookies = [
        {
          domain = "capucina.net";
          authelia_url = "https://auth.capucina.net";
          default_redirection_url = "https://capucina.net";
        }
      ];

      storage.local.path = "/var/lib/authelia-${instanceName}/db.sqlite3";

      access_control = {
        default_policy = "deny";
        networks = [
          {
            name = "lan";
            networks = [ "192.168.1.0/24" ];
          }
        ];
        rules = [
          {
            domain = "*.capucina.net";
            networks = [ "lan" ];
            policy = "bypass";
          }
          {
            domain = "*.capucina.net";
            policy = "one_factor";
          }
        ];
      };

      # Filesystem notifier (no SMTP needed, password reset links go to a file)
      notifier.filesystem.filename = "/var/lib/authelia-${instanceName}/notification.txt";
    };
  };

  # Authelia needs to read sops-managed secret files
  sops.secrets."authelia/jwt_secret" = {
    owner = autheliaUser;
    group = autheliaUser;
  };
  sops.secrets."authelia/session_secret" = {
    owner = autheliaUser;
    group = autheliaUser;
  };
  sops.secrets."authelia/storage_encryption_key" = {
    owner = autheliaUser;
    group = autheliaUser;
  };
  sops.secrets."authelia/users_database" = {
    owner = autheliaUser;
    group = autheliaUser;
  };
}
