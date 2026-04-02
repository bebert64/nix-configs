{
  cerberus = {
    host = "cerberus";
    hostname = "cerberus.stockly.tech";
    port = 24;
    # Cerberus local IP, for refence
    # hostname = "192.168.1.12";
  };
  charybdis = {
    host = "charybdis";
    hostname = "charybdis.stockly.tech";
    port = 23;
  };
  orthos = {
    host = "orthos";
    hostname = "orthos.stockly.tech";
    remoteForwards = [
      {
        # Reverse SSH tunnel for notifications (notify-send back to local machine)
        bind.port = 2222;
        host = {
          address = "localhost";
          port = 22;
        };
      }
    ];
  };
  common-stockly = {
    host = "cerberus charybdis orthos";
    user = "romain";
    localForwards = [
      {
        # Postgres
        bind.port = 5432;
        host = {
          address = "localhost";
          port = 5432;
        };
      }
      {
        # Auth grpc
        bind.port = 3079;
        host = {
          address = "localhost";
          port = 3079;
        };
      }
      {
        # Auth http
        bind.port = 3080;
        host = {
          address = "localhost";
          port = 3080;
        };
      }
      {
        # Files grpc
        bind.port = 3109;
        host = {
          address = "localhost";
          port = 3109;
        };
      }
      {
        # Files http
        bind.port = 3110;
        host = {
          address = "localhost";
          port = 3110;
        };
      }
      {
        # Mock API Connector grpc
        bind.port = 1236;
        host = {
          address = "localhost";
          port = 1236;
        };
      }
      {
        # Repackages grpc
        bind.port = 3034;
        host = {
          address = "localhost";
          port = 3034;
        };
      }
      {
        # Repackages http
        bind.port = 3035;
        host = {
          address = "localhost";
          port = 3035;
        };
      }
      {
        # Shipments grpc
        bind.port = 3039;
        host = {
          address = "localhost";
          port = 3039;
        };
      }
      {
        # Shipments http
        bind.port = 3040;
        host = {
          address = "localhost";
          port = 3040;
        };
      }
      {
        # Stocks grpc
        bind.port = 3024;
        host = {
          address = "localhost";
          port = 3024;
        };
      }
      {
        # Invoices grpc
        bind.port = 3054;
        host = {
          address = "localhost";
          port = 3054;
        };
      }
      {
        # Invoices http
        bind.port = 3055;
        host = {
          address = "localhost";
          port = 3055;
        };
      }
      {
        # Operations grpc
        bind.port = 1224;
        host = {
          address = "localhost";
          port = 1224;
        };
      }
      {
        # Meilisearch http
        bind.port = 1245;
        host = {
          address = "localhost";
          port = 1245;
        };
      }
      {
        # Search Auths grpc
        bind.port = 1243;
        host = {
          address = "localhost";
          port = 1243;
        };
      }
      {
        # Search Ingestion
        bind.port = 1244;
        host = {
          address = "localhost";
          port = 1244;
        };
      }
      {
        # Backoffice Service grpc
        bind.port = 3084;
        host = {
          address = "localhost";
          port = 3084;
        };
      }
      {
        # Backoffice Service http
        bind.port = 3085;
        host = {
          address = "localhost";
          port = 3085;
        };
      }
      {
        # Backoffice Front http
        bind.port = 1241;
        host = {
          address = "localhost";
          port = 1241;
        };
      }
      {
        # Consumer Backoffice Service grpc
        bind.port = 3114;
        host = {
          address = "localhost";
          port = 3114;
        };
      }
      {
        # Consumer Backoffice Service http
        bind.port = 3115;
        host = {
          address = "localhost";
          port = 3115;
        };
      }
      {
        # Consumer Backoffice Front http
        bind.port = 1242;
        host = {
          address = "localhost";
          port = 1242;
        };
      }
      {
        # Buckets grpc
        bind.port = 1248;
        host = {
          address = "localhost";
          port = 1248;
        };
      }
      {
        # Buckets http
        bind.port = 1251;
        host = {
          address = "localhost";
          port = 1251;
        };
      }
      {
        # supply_messages gRPC
        bind.port = 3074;
        host = {
          address = "localhost";
          port = 3074;
        };
      }
      {
        # supply_messages HTTP
        bind.port = 3075;
        host = {
          address = "localhost";
          port = 3075;
        };
      }
    ];
  };
}
