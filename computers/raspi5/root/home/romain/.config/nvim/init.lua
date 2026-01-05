-- Basic settings
vim.opt.autoindent = true
vim.opt.number = true
vim.cmd('syntax on')

-- Catppuccin theme setup
require('catppuccin').setup({
    transparent_background = true,
})

-- For some reason, setting the colorscheme directly starts Neovim with a not-transparent background,
-- and the background only becomes transparent after changing the colorscheme.
vim.cmd('autocmd VimEnter * colorscheme catppuccin-frappe')
