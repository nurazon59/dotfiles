return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdfdvi",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_fold_enabled = 0
      
      vim.g.vimtex_format_enabled = 1
      
      vim.g.vimtex_indent_on_ampersands = 0
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>", { desc = "Compile LaTeX" })
          vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<cr>", { desc = "View PDF" })
          vim.keymap.set("n", "<leader>lc", "<cmd>VimtexClean<cr>", { desc = "Clean auxiliary files" })
          vim.keymap.set("n", "<leader>lC", "<cmd>VimtexClean!<cr>", { desc = "Clean all output files" })
          vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<cr>", { desc = "Show LaTeX errors" })
          vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>", { desc = "Toggle ToC" })
        end,
      })
    end,
  },
  
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "latex",
        "bibtex",
      })
    end,
  },
}