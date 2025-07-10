{
  cerberus = {
    host = "cerberus";
    hostname = "cerberus.stockly.tech";
  };
  cerberus-local = {
    host = "cerberus-local";
    hostname = "192.168.1.12";
  };
  cerberus-common = {
    host = "cerberus cerberus-local";
    port = 24;
  };
  charybdis = {
    host = "charybdis";
    hostname = "charybdis.stockly.tech";
    port = 23;
  };
  common-stockly = {
    host = "cerberus cerberus-local charybdis";
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
        bind.port = 1226;
        host = {
          address = "localhost";
          port = 1226;
        };
      }
      {
        # Auth http
        bind.port = 1227;
        host = {
          address = "localhost";
          port = 1227;
        };
      }
      {
        # Files grpc
        bind.port = 1234;
        host = {
          address = "localhost";
          port = 1234;
        };
      }
      {
        # Files http
        bind.port = 1235;
        host = {
          address = "localhost";
          port = 1235;
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
        bind.port = 1232;
        host = {
          address = "localhost";
          port = 1232;
        };
      }
      {
        # Repackages http
        bind.port = 1233;
        host = {
          address = "localhost";
          port = 1233;
        };
      }
      {
        # Shipments grpc
        bind.port = 1230;
        host = {
          address = "localhost";
          port = 1230;
        };
      }
      {
        # Shipments http
        bind.port = 1231;
        host = {
          address = "localhost";
          port = 1231;
        };
      }
      {
        # Stocks grpc
        bind.port = 1225;
        host = {
          address = "localhost";
          port = 1225;
        };
      }
      {
        # Invoices grpc
        bind.port = 1237;
        host = {
          address = "localhost";
          port = 1237;
        };
      }
      {
        # Invoices http
        bind.port = 1249;
        host = {
          address = "localhost";
          port = 1249;
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
        bind.port = 1228;
        host = {
          address = "localhost";
          port = 1228;
        };
      }
      {
        # Backoffice Service http
        bind.port = 1229;
        host = {
          address = "localhost";
          port = 1229;
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
        bind.port = 1238;
        host = {
          address = "localhost";
          port = 1238;
        };
      }
      {
        # Consumer Backoffice Service http
        bind.port = 1239;
        host = {
          address = "localhost";
          port = 1239;
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
        bind.port = 1250;
        host = {
          address = "localhost";
          port = 1250;
        };
      }
    ];
  };
}
