{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set autoindent
      set number
      syntax on
      colorscheme catppuccin-frappe
    '';
    plugins = [
      pkgs.vimPlugins.catppuccin-nvim
    ];
    extraLuaConfig = ''
      require("catppuccin").setup({
          transparent_background = true,
      })
    '';
  };
}
