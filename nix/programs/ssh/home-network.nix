{
  "raspi" = {
    host = "raspi raspi-ext";
    hostname = "88.160.246.99";
    port = 2222;
  };

  "raspi-local" = {
    host = "raspi-local";
    hostname = "192.168.1.2";
  };

  "raspi-ipv6" = {
    host = "raspi-ipv6";
    hostname = "2a01:e0a:83d:98c0:dea6:32ff:feaf:289e";
  };

  "bureau" = {
    host = "bureau bureau-ext";
    hostname = "88.160.246.99";
    port = 2223;
  };

  "bureau-local" = {
    host = "bureau-local";
    hostname = "192.168.1.4";
  };

  "bureau-ipv6" = {
    host = "bureau-ipv6";
    hostname = "2a01:e0a:83d:98c0:10e1:716e:b165:5e42";
  };

  "common-home-nextwork" = {
    host = "raspi raspi-ext raspi-local raspi-ipv6 bureau bureau-ext bureau-local bureau-ipv6";
    user = "romain";
  };
}
