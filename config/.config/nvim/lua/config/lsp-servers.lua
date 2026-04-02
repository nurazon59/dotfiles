local M = {}

M.servers = {
  "astro",
  "golangci_lint_ls",
  "gopls",
  "jsonls",
  "jsonnet_ls",
  "lua_ls",
  "marksman",
  "mdx_analyzer",
  "postgres_lsp",
  "prismals",
  "pylsp",
  "pyright",
  "tailwindcss",
  "taplo",
  "terraformls",
  "tinymist",
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
  "yamllint",
}

M.external_servers = {
  "nixd",
}

function M.setup()
  vim.lsp.config("*", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  })

  for _, server in ipairs(M.external_servers) do
    vim.lsp.enable(server)
  end

  vim.lsp.config("postgres_lsp", {
    cmd = { "postgres-language-server", "lsp-proxy" },
    root_markers = { "postgres-language-server.jsonc", "postgrestools.jsonc", ".git" },
    filetypes = { "sql" },
  })

  vim.lsp.config("terraformls", {
    filetypes = { "terraform", "tf", "terraform-vars" },
  })
end

return M
