# Shared zsh config for all users (including root).
# User-specific config (aliases, helpers, plugins) is in programs/zsh/default.nix (HM).
#
# NixOS and HM have different option schemas for zsh, so this file can only be
# used as a NixOS module. HM users still benefit from it because zsh sources
# /etc/zshrc (written by NixOS) before ~/.zshrc (written by HM).
{
  programs.zsh = {
    enable = true;
    histSize = 200000;
    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
      "EXTENDED_HISTORY"
    ];
    ohMyZsh.enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
}
