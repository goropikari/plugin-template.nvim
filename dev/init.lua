vim.g.mapleader = ','
vim.o.number = true

vim.opt.runtimepath:prepend(vim.fn.getcwd())

require('template').setup()
