return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    win = {
      width = 40,
      col = math.huge,
      row = math.huge,
      border = "rounded",
      padding = { 1, 2 },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
