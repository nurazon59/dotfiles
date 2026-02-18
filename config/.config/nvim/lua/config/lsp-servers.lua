local M = {}

M.servers = {
  "astro",
  "gopls",
  "jsonls",
  "jsonnet_ls",
  "lua_ls",
  "markdown_oxide",
  "mdx_analyzer",
  "postgres_lsp",
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
    local opts = {
      capabilities = capabilities,
    }

    if lsp == "postgres_lsp" then
      opts.cmd = { "postgres-language-server", "lsp-proxy" }
      opts.root_dir = function(bufnr)
        return vim.fs.root(bufnr, { "postgres-language-server.jsonc", "postgrestools.jsonc", ".git" })
      end
      opts.filetypes = { "sql" }
      opts.single_file_support = true
    end

    lspconfig[lsp].setup(opts)
  end
end

return M
