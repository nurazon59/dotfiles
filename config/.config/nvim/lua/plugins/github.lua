return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  config = function()
    require("octo").setup({
      use_local_fs = false,
      enable_builtin = false,
      default_remote = { "upstream", "origin" },
      ssh_aliases = {},
      picker = "fzf-lua",
      picker_config = {
        use_emojis = false,
      },
      issues = {
        order_by = {
          field = "CREATED_AT",
          direction = "DESC",
        },
      },
      pull_requests = {
        order_by = {
          field = "CREATED_AT",
          direction = "DESC",
        },
        always_select_remote_on_create = false,
      },
      file_panel = {
        size = 10,
        use_icons = true,
      },
      colors = {
        white = "#ffffff",
        grey = "#2A354C",
        black = "#000000",
        red = "#fdb8c0",
        dark_red = "#da3633",
        green = "#acf2bd",
        dark_green = "#238636",
        yellow = "#d3c846",
        dark_yellow = "#735c0f",
        blue = "#58A6FF",
        dark_blue = "#0366d6",
        purple = "#6f42c1",
      },
      use_diagnostic_signs = true,
    })
  end,
}
