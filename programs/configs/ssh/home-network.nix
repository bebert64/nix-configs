{
  raspi = {
    host = "raspi raspi-ext";
    hostname = "88.160.246.99";
    port = 2222;
  };

  raspi-local = {
    host = "raspi-local";
    hostname = "192.168.1.2";
  };

  raspi-ipv6 = {
    host = "raspi-ipv6";
    hostname = "2a01:e0a:83d:98c0:dea6:32ff:feaf:289e";
  };

  fixe-bureau = {
    host = "fixe-bureau fixe-bureau-ext";
    hostname = "88.160.246.99";
    port = 2223;
  };

  fixe-bureau-local = {
    host = "fixe-bureau-local";
    hostname = "192.168.1.4";
  };

  fixe-bureau-ipv6 = {
    host = "fixe-bureau-ipv6";
    hostname = "2a01:e0a:83d:98c0:10e1:716e:b165:5e42";
  };

  as-romain = {
    host = "raspi raspi-ext raspi-local raspi-ipv6 fixe-bureau fixe-bureau-ext fixe-bureau-local fixe-bureau-ipv6";
    user = "romain";
  };

  stockly-romainc = {
    host = "stockly-romainc stockly-romainc-ext";
    hostname = "88.160.246.99";
    port = 2224;
  };

  stockly-romainc-local = {
    host = "stockly-romainc-local";
    hostname = "192.168.1.5";
  };

  stockly-romainc-ipv6 = {
    host = "stockly-romainc-ipv6";
    hostname = "2a01:e0a:83d:98c0:170a:e3ea:b199:4cef";
  };

  as-user = {
    host = "stockly-romainc stockly-romainc-ext stockly-romainc-local stockly-romainc-ipv6";
    user = "user";
  };
}
