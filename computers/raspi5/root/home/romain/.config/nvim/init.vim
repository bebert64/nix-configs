set autoindent
set number
syntax on
" For some reason, setting the colorscheme directly starts Neovim with a not-transparent background,
" and the background only becomes transparent after changing the colorscheme.
autocmd VimEnter * colorscheme catppuccin-frappe
