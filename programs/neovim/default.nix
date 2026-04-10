{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      set autoindent
      set number
      syntax on
      " For some reason, setting the colorscheme directly starts Neovim with a not-transparent background,
      " and the background only becomes transparent after changing the colorscheme.
      autocmd VimEnter * colorscheme catppuccin-frappe
    '';
    plugins = [
      pkgs.vimPlugins.catppuccin-nvim
      pkgs.vimPlugins.vim-nix
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.markdown
        p.markdown_inline
      ]))
      pkgs.vimPlugins.render-markdown-nvim
    ];
    extraLuaConfig = ''
      require('catppuccin').setup({
          transparent_background = true,
      })
      require('render-markdown').setup({})
    '';
  };
}
