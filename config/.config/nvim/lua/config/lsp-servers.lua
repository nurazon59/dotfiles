local M = {}

M.servers = {
  "astro",
  "gopls",
  "jsonls",
  "jsonnet_ls",
  "lua_ls",
  "markdown_oxide",
  "mdx_analyzer",
  "prismals",
  "pylsp",
  "pyright",
  "tailwindcss",
  "taplo",
  "terraformls",
  "tinymist",
  "vtsls",
}

M.tools = {
  "actionlint",
  "biome",
  "buf",
  "eslint_d",
  "golangci-lint",
  "oxlint",
  "prettier",
  "prettierd",
  "ruff",
  "shfmt",
  "stylua",
  "textlint",
  "typos",
}

function M.setup()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  for _, lsp in ipairs(M.servers) do
    lspconfig[lsp].setup({
      capabilities = capabilities,
    })
  end
end

return M
