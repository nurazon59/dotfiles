local map = vim.keymap.set

local function del(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

del("n", "grr")
del("n", "gri")
del("n", "grt")
del({ "i", "s" }, "<C-S>")

map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / Clear hlsearch / Diff Update" }
)

map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>qq", "<cmd>confirm qa<cr>", { desc = "Quit All" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- stylua: ignore start
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
-- stylua: ignore end

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

map("i", "jj", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Escape insert mode" })

local opts = { noremap = true, silent = true, nowait = true }
map("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", vim.tbl_extend("force", opts, { desc = "LSP Definitions" }))
map("n", "gr", function()
  require("fzf-lua").lsp_references({
    includeDeclaration = false,
    fzf_opts = { ["--query"] = "!^import " },
  })
end, vim.tbl_extend("force", opts, { desc = "LSP References" }))
map("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", vim.tbl_extend("force", opts, { desc = "LSP Implementations" }))
map("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", vim.tbl_extend("force", opts, { desc = "LSP Type Definitions" }))
map("n", "gra", "<cmd>FzfLua lsp_code_actions<CR>", vim.tbl_extend("force", opts, { desc = "LSP Code Actions" }))
map("n", "grn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP Rename" }))
map("n", "gO", "<cmd>FzfLua lsp_document_symbols<CR>", vim.tbl_extend("force", opts, { desc = "LSP Document Symbols" }))
