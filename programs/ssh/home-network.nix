{

  bureau = {
    host = "bureau";
    port = 2223;
  };

  raspi4 = {
    host = "raspi4";
    port = 2222;
  };

  raspi5 = {
    host = "raspi5";
    port = 2226;
  };

  salon = {
    host = "salon";
    port = 2225;
  };

  stockly-romainc = {
    host = "stockly-romainc";
    user = "user";
    port = 2224;
  };

  home-romain = {
    host = "bureau raspi4 raspi5 salon";
    user = "romain";
  };

  home-common = {
    host = "bureau raspi4 raspi5 salon stockly-romainc";
    hostname = "82.225.65.163";
  };
}
