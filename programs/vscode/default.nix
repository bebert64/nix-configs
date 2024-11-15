{ pkgs, ... }:
{
  config.home = {
    packages = with pkgs; [
      vscode
      polkit # polkit is the utility used by vscode to save as sudo
    ];
    file = {
      ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;
    };
  };
}
