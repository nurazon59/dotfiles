return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      width = 30, -- デフォルトは40なので、30に拡大
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        never_show = {
          ".git",
          ".DS_Store",
          ".history",
        },
      },
    },
  },
  keys = {
    {
      "<Space>e",
      function()
        local manager = require("neo-tree.sources.manager")
        local renderer = require("neo-tree.ui.renderer")

        -- Neo-treeのウィンドウが開いているかチェック
        local state = manager.get_state("filesystem")
        if state and renderer.window_exists(state) then
          -- 現在のウィンドウがNeo-treeかチェック
          if vim.bo.filetype == "neo-tree" then
            -- Neo-treeにいる場合は前のウィンドウ（エディタ）に戻る
            vim.cmd("wincmd p")
          else
            -- エディタにいる場合はNeo-treeにフォーカス
            vim.cmd("Neotree focus")
          end
        else
          -- Neo-treeが開いていない場合は開く
          vim.cmd("Neotree toggle")
        end
      end,
      desc = "Toggle Neo-tree focus between tree and editor",
    },
  },
}
