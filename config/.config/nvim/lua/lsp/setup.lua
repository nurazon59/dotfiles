local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
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
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    capabilities = capabilities,
  })
end
