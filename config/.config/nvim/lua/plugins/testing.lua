return {
  {
    "nvim-neotest/neotest",
    pin = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/nvim-nio",
      "fredrikaverpil/neotest-golang",
      "thenbe/neotest-playwright",
    },
    keys = {
      {
        "<leader>Tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>Tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run file tests",
      },
      {
        "<leader>Ts",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop test",
      },
      {
        "<leader>To",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test output",
      },
      {
        "<leader>TO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle output panel",
      },
      {
        "<leader>Tm",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle summary",
      },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({}),
          require("neotest-playwright").adapter({
            options = { enable_dynamic_test_discovery = true },
          }),
        },
      })
    end,
  },
}
