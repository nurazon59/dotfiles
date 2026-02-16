return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },

      lua = { "stylua" },
      javascript = { "oxfmt", "eslint" },
      typescript = { "oxfmt", "eslint" },
      go = { "goimports" },
      -- python = { "black" },
      -- rust = { "rustfmt" },
      json = { "oxfmt" },
      yaml = { "oxfmt" },
      markdown = { "oxfmt" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
