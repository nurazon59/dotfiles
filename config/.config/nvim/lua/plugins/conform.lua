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
      javascript = { "prettier", "eslint" },
      typescript = { "prettier", "eslint" },
      go = { "goimports" },
      -- python = { "black" },
      -- rust = { "rustfmt" },
      json = { "prettier" },
      yaml = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
