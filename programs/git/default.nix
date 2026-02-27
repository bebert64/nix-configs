{ config, lib, ... }:
{
  options.byDb.git =
    with lib;
    with types;
    {
      user = {
        name = mkOption { type = str; };
        email = mkOption { type = str; };
      };
      mainOrMaster = mkOption {
        type = enum [
          "main"
          "master"
        ];
        default = "main";
      };
    };

  config.programs.git =
    let
      gitConfig = config.byDb.git;
    in
    {
      enable = true;
      settings = {
        user = gitConfig.user;
        pull.rebase = "true";
        core = {
          commentchar = "%";
          editor = "nvim";
          ui = "true";
        };
        push = {
          default = "current";
          autoSetupRemote = "true";
        };
        gc.autoDetach = "false";
        alias = {
          a = "add";
          ar = "!git add $(git rev-parse --show-toplevel)";
          arc = "!git add $(git rev-parse --show-toplevel) && git commit";
          arca = "!git add $(git rev-parse --show-toplevel) && git commit --amend";
          arcap = "!git add $(git rev-parse --show-toplevel) && git commit --amend && git push -u --force-with-lease";
          arcp = "!git add $(git rev-parse --show-toplevel) && git commit && git push -u";
          b = "branch";
          ba = "branch -a";
          c = "commit";
          ca = "commit --amend";
          cap = "!git commit --amend && git push -u --force-with-lease";
          clb = "!git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done;";
          co = "checkout";
          com = "!git checkout ${gitConfig.mainOrMaster}";
          cop = "!git commit && git push -u";
          cp = "cherry-pick";
          d = "diff";
          ds = "diff --staged";
          f = "fetch -pa";
          l = "log --graph --pretty=oneline --abbrev-commit";
          last = "log -1 HEAD";
          ma = "merge --abort";
          mc = "merge --continue";
          mcp = "!git merge --continue && git push";
          mom = "merge --no-edit origin/${gitConfig.mainOrMaster}";
          momp = "!git merge --no-edit origin/${gitConfig.mainOrMaster} && git push";
          ms = "merge --squash";
          mum = "merge --ff-only upstream/${gitConfig.mainOrMaster}";
          pfl = "push --force-with-lease";
          pl = "pull";
          # Merge the branch's base (main or branch.<name>.base). When base is unset we prompt once; empty = main, then we set base and merge.
          pmp = ''
            !f() {
              git fetch origin
              current=$(git rev-parse --abbrev-ref HEAD)
              base=$(git config branch."''$current".base)
              if [ -z "''$base" ]; then
                read -p "Branch to merge [${gitConfig.mainOrMaster}]: " base
                base="''${base:-${gitConfig.mainOrMaster}}"
                git config branch."''$current".base "''$base"
              fi
              base_ref=$(git rev-parse "origin/''$base" 2>/dev/null)
              if [ -z "''$base_ref" ]; then
                echo "Branch origin/''$base not found."
                return 1
              fi
              base_mb=$(git merge-base HEAD "origin/''$base" 2>/dev/null)
              if [ -z "''$base_mb" ]; then
                echo "origin/''$base is not in this branch's history."
                return 1
              fi
              git pull && git merge --no-edit "origin/''$base" && git push
            }; f
          '';
          ps = "push -u";
          r = "rebase";
          rc = "rebase --continue";
          ri = "rebase -i";
          riom = "rebase -i origin/${gitConfig.mainOrMaster}";
          rt = "restore";
          s = "status";
          sp = "stash pop";
          st = "stash";
          sw = "switch";
          wip = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip'";
          wipp = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip' && git push -u";
        };
      };
      ignores = [
        "*.swp"
        ".vscode"
      ];
    };
}
