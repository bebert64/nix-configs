{ config, lib, ... }:
{
  options.by-db.git = {
    userName = with lib; mkOption { type = types.str; };
    userEmail = with lib; mkOption { type = types.str; };
  };

  config.programs.git =
    let
      cfg = config.by-db.git;
    in
    {
      enable = true;
      userName = "${cfg.userName}";
      userEmail = "${cfg.userEmail}";
      aliases = {
        a = "add";
        ar = "!git add $(git rev-parse --show-toplevel)";
        arc = "!git add $(git rev-parse --show-toplevel) && git commit";
        arca = "!git add $(git rev-parse --show-toplevel) && git commit --amend";
        arcap = "!git add $(git rev-parse --show-toplevel) && git commit --amend && git push -u --force-with-lease";
        arcp = "!git add $(git rev-parse --show-toplevel) && git commit && git push -u";
        b = "branch";
        c = "commit";
        ca = "commit --amend";
        cap = "!git commit --amend && git push -u --force-with-lease";
        co = "checkout";
        com = "!git checkout master || git checkout main";
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
        mom = "merge --no-edit origin/master || merge --no-edit origin/main";
        momp = "!git merge --no-edit origin/master || git merge --no-edit origin/main && git push";
        mum = "merge --ff-only upstream/master || merge --ff-only upstream/main";
        pfl = "push --force-with-lease";
        pl = "pull";
        pmp = "!git pull && git momp";
        ps = "push -u";
        r = "rebase";
        rc = "rebase --continue";
        ri = "rebase -i";
        riom = "rebase -i origin/master || rebase -i origin/main";
        rt = "restore";
        s = "status";
        sp = "stash pop";
        st = "stash";
        sw = "switch";
        wip = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip'";
        wipp = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip' && git push -u";
      };
      ignores = [
        "*.swp"
        ".vscode"
      ];
      extraConfig = {
        pull.rebase = "true";
        core = {
          commentchar = "%";
          editor = "vim";
          ui = "true";
        };
        push.default = "current";
        gc.autoDetach = "false";
      };
    };
}
