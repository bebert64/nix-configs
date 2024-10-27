{
  "raspi" = {
    host = "raspi";
    hostname = "88.160.246.99";
    port = 2222;
  };

  "raspi-ipv6" = {
    host = "raspi-ipv6";
    hostname = "88.160.246.99";
  };

  "raspi-local" = {
    host = "raspi-local";
    hostname = "192.168.1.2";
  };

  "fixe-bureau-local" = {
    host = "fixe-bureau-local";
    hostname = "192.168.1.4";
  };

  "common-home-nextwork" = {
    host = "raspi raspi-local raspi-ipv6 fixe-bureau-local";
    user = "romain";
  };
}
