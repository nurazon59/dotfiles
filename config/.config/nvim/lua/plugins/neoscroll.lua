return {
  "karb94/neoscroll.nvim",
  event = "BufRead",
  config = function()
    local neoscroll = require("neoscroll")
    
    neoscroll.setup({
      mappings = {}, -- デフォルトマッピングを無効化
      hide_cursor = false,
      stop_eof = true,
      use_local_scrolloff = false,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = "sine",
      pre_hook = nil,
      post_hook = nil,
    })

    -- カスタムキーマッピング
    local keymap = {
      -- 半画面スクロール（Ctrl+j/k）
      ["<C-j>"] = function() neoscroll.ctrl_d({ duration = 100 }) end,
      ["<C-k>"] = function() neoscroll.ctrl_u({ duration = 100 }) end,
    }

    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func, { desc = "Smooth scroll with neoscroll" })
    end
  end,
}