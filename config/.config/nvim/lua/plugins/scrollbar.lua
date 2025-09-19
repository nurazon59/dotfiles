return {
  "petertriho/nvim-scrollbar",
  dependencies = { "lewis6991/gitsigns.nvim" },
  config = function()
    local colors = require("tokyonight.colors").setup()
    require("scrollbar").setup({
      handle = {
        color = colors.bg_highlight,
      },
      marks = {
        Search = { colot = colors.orange },
        Error = { color = colors.error },
        Warn = { color = colors.warning },
        Info = { color = colors.info },
        Hint = { color = colors.hint },
        Misc = { color = colors.purple },
      },
    })
    require("scrollbar.handlers.gitsigns").setup()
  end,
}
