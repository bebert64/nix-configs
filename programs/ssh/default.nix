{
  programs.ssh = {
    enable = true;
    serverAliveCountMax = 2;
    serverAliveInterval = 40;
    matchBlocks = import ./stockly.nix // import ./home-network.nix;
  };
}
