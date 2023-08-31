{
  enable = true;
  userName = "RomainC";
  userEmail = "bebert64@gmail.com";
  aliases = {
    a = "add";
    b = "branch";
    c = "commit";
    ca = "commit --amend";
    co = "checkout";
    com = "checkout master";
    cp = "cherry-pick";
    d = "diff";
    ds = "diff --staged";
    l = "log --graph --pretty=oneline --abbrev-commit";
    last = "log -1 HEAD";
    ma = "merge --abort";
    mc = "merge --continue";
    mom = "merge origin/master --no-edit";
    f = "fetch -p";
    pl = "pull";
    ps = "push -u";
    r = "rebase";
    rc = "rebase --continue";
    ri = "rebase -i";
    ra = "rebase --abort";
    riom = "rebase -i origin/master";
    s = "status";
    # Scripts
    arc = "!git add $(git rev-parse --show-toplevel) && git commit";
    arca = "!git add $(git rev-parse --show-toplevel) && git commit --amend";
    arcap = "!git add $(git rev-parse --show-toplevel) && git commit --amend && git push -u --force-with-lease";
    arcp = "!git add $(git rev-parse --show-toplevel) && git commit && git push -u";
    clean-local = "git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -d";
    pmp = "!git pl && git mom && git ps";
    wip = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip'";
    wipp = "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip' && git push -u";
  };
  ignores = [
    "*.swp"
    ".vscode"
  ];
  extraConfig = {
    pull.rebase = "true";
    core.commentchar = "%";
    color.ui = "true";
    push.default = "current";
    gc.autoDetach = "false";
  };
}
