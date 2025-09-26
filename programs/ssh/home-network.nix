{

  bureau = {
    host = "bureau";
    port = 2223;
  };

  raspi = {
    host = "raspi";
    port = 2222;
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
    host = "bureau raspi salon";
    user = "romain";
  };

  home-common = {
    host = "bureau raspi salon stockly-romainc";
    hostname = "88.160.246.99";
  };
}
