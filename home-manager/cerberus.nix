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
      activation.symlinkCursor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /home/romain/.cursor
        mkdir -p /home/romain/Stockly/.cursor
        ln -sfT /home/romain/nix-configs/programs/cursor/rules/global /home/romain/.cursor/rules
        ln -sfT /home/romain/nix-configs/programs/cursor/rules/stockly /home/romain/Stockly/.cursor/rules
        ln -sfT /home/romain/nix-configs/programs/cursor/skills /home/romain/.cursor/skills
        ln -sf /home/romain/nix-configs/programs/cursor/scripts/parse_qtt.py /home/romain/Stockly/.cursor/parse_qtt.py
      '';
    };

    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
  };
}
