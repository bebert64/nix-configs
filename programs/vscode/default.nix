{ pkgs, ... }:
{
  config.home = {
    packages = [ pkgs.vscode ];
    file = {
      ".vscode/extensions/stockly.monokai-stockly-1.0.0".source = ./MonokaiStockly;
    };
  };
}
