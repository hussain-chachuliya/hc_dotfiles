return {
  -- 1. Add and configure the plugin
  {
    "Mofiqul/vscode.nvim",
    lazy = false, -- make sure it loads during startup so it's available
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      -- Optional settings based on your preference:
      transparent = false, -- Set to true if you want a transparent background
      italic_comments = true, -- Enable italic comments
      -- style = "light",      -- Uncomment if you prefer the VS Code light theme
    },
  },

  -- 2. Configure LazyVim to load the colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
