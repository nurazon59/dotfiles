return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- ターミナル設定
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = false,
      shade_factor = 0.3,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      
      -- フロートターミナル設定
      float_opts = {
        border = "rounded",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      
      -- ターミナルごとのキーマップ
      on_create = function(term)
        local opts = { buffer = term.bufnr, noremap = true, silent = true }
        -- ターミナル内でのEsc設定
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end,
    })

    -- カスタムターミナル関数
    local Terminal = require("toggleterm.terminal").Terminal
    
    -- 浮動ターミナル
    local float_term = Terminal:new({
      direction = "float",
      float_opts = {
        border = "double",
      },
      count = 1,
    })
    
    -- 水平ターミナル
    local horizontal_term = Terminal:new({
      direction = "horizontal",
      size = 15,
      count = 2,
    })
    
    -- 垂直ターミナル
    local vertical_term = Terminal:new({
      direction = "vertical",
      size = vim.o.columns * 0.4,
      count = 3,
    })
    
    -- lazygitターミナル
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      float_opts = { border = "single" },
      count = 4,
      -- 閉じた時の動作
      on_exit = function(t)
        -- リフレッシュが必要な場合のコマンド
      end,
    })

    -- lazygit（水平レイアウト比較用）
    local lazygit_h = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "horizontal",
      size = 15,
      count = 6,
    })

    -- htopターミナル
    local htop = Terminal:new({
      cmd = "htop",
      direction = "float",
      float_opts = {
        border = "double",
      },
      count = 5,
    })

    -- キーマップ設定関数
    local function set_terminal_keymaps()
      local opts = { noremap = true, silent = true }
      
      -- 基本操作
      vim.keymap.set("n", "<leader>tf", function() float_term:toggle() end, 
        { desc = "Toggle Float Terminal", unpack(opts) })
      vim.keymap.set("n", "<leader>th", function() horizontal_term:toggle() end, 
        { desc = "Toggle Horizontal Terminal", unpack(opts) })
      vim.keymap.set("n", "<leader>tv", function() vertical_term:toggle() end, 
        { desc = "Toggle Vertical Terminal", unpack(opts) })
      
      -- 特殊ターミナル
      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, 
        { desc = "Toggle Lazygit (Float)", unpack(opts) })
      vim.keymap.set("n", "<leader>tG", function() lazygit_h:toggle() end, 
        { desc = "Toggle Lazygit (Horizontal)", unpack(opts) })
      vim.keymap.set("n", "<leader>tt", function() htop:toggle() end, 
        { desc = "Toggle Htop", unpack(opts) })
      
      -- 全ターミナルを閉じる
      vim.keymap.set("n", "<leader>tq", "<cmd>ToggleTermToggleAll<cr>", 
        { desc = "Toggle All Terminals", unpack(opts) })
    end

    -- キーマップを設定
    set_terminal_keymaps()
    
    -- ターミナルモードでのキーマップ
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "kj", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    end

    -- ターミナル用autocmd
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
