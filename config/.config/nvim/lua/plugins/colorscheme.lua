return {
  -- Tokyonightテーマ（暗い背景）
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- night, storm, day, moon から選択
      transparent = true, -- 背景透過を有効（ターミナルの背景が見える）
    },
  },

  -- 他の人気テーマ（コメントアウトで無効化）
  -- { "catppuccin/nvim", name = "catppuccin" },
  -- { "ellisonleao/gruvbox.nvim" },
  -- { "rebelot/kanagawa.nvim" },
  -- { "sainnhe/everforest" },

  -- LazyVimでテーマを適用
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight", -- ここを変更してテーマを切り替え
    },
  },
}

