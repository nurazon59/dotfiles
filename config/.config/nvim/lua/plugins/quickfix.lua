return {
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({
        auto_enable = true,
        func_map = {
          vsplit = "",
        },
      })
    end,
  },
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    keys = {
      {
        "<leader>q",
        function()
          require("quicker").toggle()
        end,
        desc = "Toggle quickfix",
      },
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        ft = "qf",
        desc = "Expand context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        ft = "qf",
        desc = "Collapse",
      },
    },
    opts = {},
  },
}
