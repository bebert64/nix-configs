{ pkgs, ... }:
{
  imports = [
    ./ranger
    ./secrets
    ./ssh
    ./zsh
    ./btop.nix
    ./direnv.nix
    ./git.nix
    ./vim.nix
    ./scripts.nix
  ];
}
