return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install({
        "astro",
        "bash",
        "css",
        "diff",
        "dockerfile",
        "fish",
        "git_rebase",
        "gitcommit",
        "go",
        "gomod",
        "gosum",
        "hcl",
        "html",
        "javascript",
        "json",
        "jsonnet",
        "lua",
        "markdown",
        "markdown_inline",
        "prisma",
        "python",
        "regex",
        "rust",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "typst",
        "vim",
        "vimdoc",
        "yaml",
      })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
