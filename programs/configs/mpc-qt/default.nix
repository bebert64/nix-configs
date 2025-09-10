# Terminal
{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      mpc-qt
    ];
    file = {
      ".config/mpc-qt/settings.json".source = ./settings.json;
    };
  };
}
