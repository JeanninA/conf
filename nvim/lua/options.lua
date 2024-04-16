vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.scrolloff = 8

vim.opt.spell = true
vim.opt.spelllang = { "fr", "en" }

vim.opt.swapfile = false

vim.opt.fillchars = "eob: " -- remove ~ symbole on empty lines

vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

vim.opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position
