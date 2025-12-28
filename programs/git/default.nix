{ config, lib, ... }:
{
  options.by-db.git =
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
      cfg = config.by-db.git;
    in
    {
      enable = true;
      settings = {
        user = cfg.user;
        pull.rebase = "true";
        core = {
          commentchar = "%";
          editor = "nvim";
          ui = "true";
        };
        push.default = "current";
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
          com = "!git checkout ${cfg.mainOrMaster}";
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
          mom = "merge --no-edit origin/${cfg.mainOrMaster}";
          momp = "!git merge --no-edit origin/${cfg.mainOrMaster} && git push";
          ms = "merge --squash";
          mum = "merge --ff-only upstream/${cfg.mainOrMaster}";
          pfl = "push --force-with-lease";
          pl = "pull";
          pmp = "!git pull && git momp";
          ps = "push -u";
          r = "rebase";
          rc = "rebase --continue";
          ri = "rebase -i";
          riom = "rebase -i origin/${cfg.mainOrMaster}";
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
