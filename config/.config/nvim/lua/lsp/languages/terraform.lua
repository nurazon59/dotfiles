return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          filetypes = { "terraform", "tf", "terraform-vars" },
        },
      },
    },
  },
}
