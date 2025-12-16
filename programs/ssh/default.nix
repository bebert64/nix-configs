{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        serverAliveCountMax = 2;
        serverAliveInterval = 40;
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    }
    // import ./stockly.nix
    // import ./home-network.nix;
  };
}
