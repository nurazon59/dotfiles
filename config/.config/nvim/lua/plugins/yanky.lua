return {
  "gbprod/yanky.nvim",
  opts = {
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 500,
    },
  },
  config = function(_, opts)
    require("yanky").setup(opts)
    local palette = require("kanagawa.colors").setup({ theme = "wave" }).palette
    vim.api.nvim_set_hl(0, "YankyYanked", { bg = palette.waveBlue1 })
    vim.api.nvim_set_hl(0, "YankyPut", { bg = palette.waveBlue2 })
  end,
}
