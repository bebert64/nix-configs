{
  imports = [
    ./common.nix
    ../programs/server.nix
  ];

  config = {
    by-db-pkgs = { };
  };
}
