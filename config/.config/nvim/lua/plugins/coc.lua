return {
  "neoclide/coc.nvim",
  branch = "release",
  build = "npm ci",
  config = function()
    vim.g.coc_global_extensions = {
      "coc-json",
      "coc-toml",
    }
  end,
}
