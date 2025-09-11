-- why: Gitの変更点を即座に把握したい
-- why: まずは既定挙動で体験を確認する
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- why: メッセージ/コマンドラインの可読性を上げたい
  -- why: 通知のUIを改善したい
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      { "rcarriga/nvim-notify", opts = {} },
    },
    opts = {},
  },

  -- why: Markdownの読みやすさを向上したい
  -- why: 負荷や表示崩れは後から調整で最小導入
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
