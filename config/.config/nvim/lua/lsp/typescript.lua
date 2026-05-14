return {
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    -- Denoプロジェクトでは denols を attach、それ以外は typescript-tools を attach
    init = function()
      vim.lsp.config("denols", { root_markers = { "deno.json", "deno.jsonc" } })
    end,
    opts = {
      root_dir = function(bufnr, on_dir)
        if vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) then
          return
        end
        on_dir(vim.fs.root(bufnr, { "package.json", "tsconfig.json" }))
      end,
      single_file_support = false,
      settings = {
        tsserver_file_preferences = { disableFormatting = true },
        jsx_close_tag = { enable = true },
      },
    },
  },
}
