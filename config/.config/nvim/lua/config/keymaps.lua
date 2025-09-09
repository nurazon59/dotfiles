-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true, desc = "Escape insert mode with jj" })

-- 半画面スクロール
vim.keymap.set({ "n", "v" }, "J", "<C-d>zz", { desc = "半画面下スクロール" })
vim.keymap.set({ "n", "v" }, "K", "<C-u>zz", { desc = "半画面上スクロール" })

-- 1画面分スクロール
vim.keymap.set({ "n", "v" }, "<M-j>", "<C-f>zz", { desc = "1画面分下スクロール" })
vim.keymap.set({ "n", "v" }, "<M-k>", "<C-b>zz", { desc = "1画面分上スクロール" })