-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- why: Markdown等でスペルチェックにより波線(undercurl)が大量表示され煩わしいため無効化する
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
-- fzf UI を素早く閉じる
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fzf",
  callback = function()
    local opts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set("t", "jk", "<C-c>", opts)
    vim.keymap.set("t", "jj", "<C-c>", opts)
    vim.keymap.set("n", "jk", "<cmd>close<CR>", opts)
    vim.keymap.set("n", "jj", "<cmd>close<CR>", opts)
  end,
})

-- lazygit を素早く閉じる（単キー）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lazygit",
  callback = function()
    local opts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set("t", "<C-q>", "q", opts)
    vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", opts)
  end,
})

-- ToggleTerm で起動した lazygit にも適用
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*lazygit*",
  callback = function(args)
    local opts = { buffer = args.buf, noremap = true, silent = true }
    vim.keymap.set("t", "<C-q>", "q", opts)
    vim.keymap.set("n", "<C-q>", "<cmd>close<CR>", opts)
  end,
})

-- why: lazygit 中の複数キー待ちを減らして体感ラグを下げる
local lazygit_timeoutlen = 200

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = { "lazygit", "term://*lazygit*" },
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].__prev_timeoutlen == nil then
      vim.b[buf].__prev_timeoutlen = vim.o.timeoutlen
      vim.o.timeoutlen = lazygit_timeoutlen
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "TermClose" }, {
  callback = function(args)
    local prev = vim.b[args.buf] and vim.b[args.buf].__prev_timeoutlen
    if prev ~= nil then
      vim.o.timeoutlen = prev
      vim.b[args.buf].__prev_timeoutlen = nil
    end
  end,
})

-- why: SQL LSPにGo to Definitionがないため、grepでDDL定義にジャンプする
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  callback = function()
    vim.keymap.set("n", "gd", function()
      local word = vim.fn.expand("<cword>")
      if word == "" then
        return
      end
      local pattern = [[CREATE\s+(OR\s+REPLACE\s+)?(TABLE|VIEW|FUNCTION|TYPE|TRIGGER|PROCEDURE)\s+(IF\s+NOT\s+EXISTS\s+)?(\w+\.)?]] .. word .. [[\b]]
      local obj = vim.system({ "rg", "--vimgrep", "--glob", "*.sql", pattern }):wait()
      local lines = vim.tbl_filter(function(l)
        return l ~= ""
      end, vim.split(obj.stdout or "", "\n"))
      if #lines == 1 then
        local file, lnum, col = lines[1]:match("^(.+):(%d+):(%d+):")
        if file then
          vim.cmd("edit " .. vim.fn.fnameescape(file))
          vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
          return
        end
      end
      require("fzf-lua").grep({
        search = pattern,
        no_esc = true,
        rg_opts = "--glob '*.sql'",
      })
    end, { buffer = 0, noremap = true, silent = true, desc = "DDL定義にジャンプ" })
  end,
})
