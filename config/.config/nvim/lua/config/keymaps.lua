-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape insert mode with jj" })

local function del(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

del("n", "grn")
del("n", "grr")
del("n", "gri")
del("n", "grt")
del("n", "gO")
del({ "n", "x" }, "gra")
del({ "i", "s" }, "<C-S>")

local opts = { noremap = true, silent = true, nowait = true }
vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", vim.tbl_extend("force", opts, { desc = "LSP Definitions" }))
vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", vim.tbl_extend("force", opts, { desc = "LSP References" }))
vim.keymap.set(
  "n",
  "gi",
  "<cmd>FzfLua lsp_implementations<CR>",
  vim.tbl_extend("force", opts, { desc = "LSP Implementations" })
)
vim.keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", vim.tbl_extend("force", opts, { desc = "LSP Type Definitions" }))
