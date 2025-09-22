return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
      "telescope",
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        preview = {
          layout = "horizontal",
          horizontal = "right:50%",
        },
      },
      keymap = {
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
      files = {
        prompt = "Files❯ ",
        cmd = "fd --type f --hidden --follow --exclude .git",
      },
      grep = {
        prompt = "Rg❯ ",
        cmd = "rg --vimgrep --hidden --glob '!.git'",
      },
    })

    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", opts)
    vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", opts)
    vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", opts)
    vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", opts)
    vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", opts)
    vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<CR>", opts)
    vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua git_status<CR>", opts)
    vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua resume<CR>", opts)
    vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", opts)
    vim.keymap.set("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<CR>", opts)
    vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", opts)
    vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", opts)
    vim.keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts)
    vim.keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)
  end,
}

