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
        # Operations
        bind.port = 1824;
        host = {
          address = "localhost";
          port = 1824;
        };
      }
      {
        # Stocks
        bind.port = 1825;
        host = {
          address = "localhost";
          port = 1825;
        };
      }
      {
        # Auth (not sure why there is two, launch and check someday could be cool)
        bind.port = 1826;
        host = {
          address = "localhost";
          port = 1826;
        };
      }
      {
        # Auth (not sure why there is two, launch and check someday could be cool)
        bind.port = 1827;
        host = {
          address = "localhost";
          port = 1827;
        };
      }
      {
        # Backoffice Service
        bind.port = 1828;
        host = {
          address = "localhost";
          port = 1828;
        };
      }
      {
        # Backoffice Service HTTP (not sure why there is two, launch and check someday could be cool)
        bind.port = 1829;
        host = {
          address = "localhost";
          port = 1829;
        };
      }
      {
        # Backoffice Service HTTP (not sure why there is two, launch and check someday could be cool)
        bind.port = 51016;
        host = {
          address = "localhost";
          port = 51016;
        };
      }
      {
        # Shipments
        bind.port = 1830;
        host = {
          address = "localhost";
          port = 1830;
        };
      }
      {
        # Repackages
        bind.port = 1832;
        host = {
          address = "localhost";
          port = 1832;
        };
      }
      {
        # Invoices
        bind.port = 4006;
        host = {
          address = "localhost";
          port = 4006;
        };
      }
      {
        # Files
        bind.port = 1834;
        host = {
          address = "localhost";
          port = 1834;
        };
      }
    ];
  };
}
