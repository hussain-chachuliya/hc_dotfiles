vim.opt.wrap = true -- Enable word wrap
vim.opt.linebreak = true -- Avoid breaking words in the middle when wrapping

vim.api.nvim_create_autocmd("FileType", {
  pattern = "kdl",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    -- Optional: start with all folds open instead of closed
    vim.opt_local.foldlevel = 99
  end,
})
