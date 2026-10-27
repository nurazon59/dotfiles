local lazypath = "@lazy-nvim@"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "lsp" },
  },
  install = {
    colorscheme = { "rose-pine-moon" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  checker = {
    enabled = false,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
