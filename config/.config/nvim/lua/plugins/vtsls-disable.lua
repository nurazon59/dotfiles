return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = { enabled = false },      -- why: typescript-toolsをメインにするため二重起動を防ぐ
        tsserver = { enabled = false },   -- why: 旧名の誤起動も明示的に抑止
        ts_ls = { enabled = false },      -- why: 将来の置換名も抑止
      },
    },
  },
}
