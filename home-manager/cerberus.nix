{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/btop
    ../programs/git
    ../programs/neovim
    ../programs/ranger
  ];

  options.byDb.paths.nixPrograms = lib.mkOption {
    type = lib.types.str;
  };

  config = {
    byDb = {
      paths.nixPrograms = "/home/romain/nix-configs/programs";
      git = {
        user = {
          name = "RomainC";
          email = "romain@stockly.ai";
        };
        mainOrMaster = "master";
      };
    };

    home = {
      username = "romain";
      homeDirectory = "/home/romain";
      stateVersion = "23.05";
      packages = [
        pkgs.fd
        (pkgs.writeScriptBin "update" ''
          #!/usr/bin/env bash
          cd /home/romain/nix-configs || exit 1
          git pull || exit 1
          home-manager switch --flake '.#romain@cerberus' --show-trace
        '')
      ];
      activation.symlinkCursorCommands = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /home/romain/.cursor
        ln -sfT /home/romain/nix-configs/programs/cursor/commands /home/romain/.cursor/commands
      '';
    };

    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
  };
}
