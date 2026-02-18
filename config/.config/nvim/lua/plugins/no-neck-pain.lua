return {
  "shortcuts/no-neck-pain.nvim",
  version = "*",
  opts = {
    width = 120,
    enableOnVimEnter = true,
    integrations = {
      NeoTree = {
        position = "left",
        reopen = true,
      },
    },
  },
  keys = {
    { "<leader>np", "<cmd>NoNeckPain<cr>", desc = "Toggle No Neck Pain" },
  },
}
