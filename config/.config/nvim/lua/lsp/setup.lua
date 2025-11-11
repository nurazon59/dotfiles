local M = {}

M.servers = {
  "lua_ls",
  "ts_ls",
  "eslint",
  "gopls",
  "pyright",
  "rust_analyzer",
  "bashls",
  "jsonls",
  "yamlls",
  "html",
  "cssls",
  "terraformls",
}

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, lsp in ipairs(M.servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
  })
end

return M
