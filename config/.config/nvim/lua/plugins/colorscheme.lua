return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    pin = true,
    lazy = false,
    priority = 1000,
    opts = {
      variant = "moon",
      styles = { transparency = true },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },
}
