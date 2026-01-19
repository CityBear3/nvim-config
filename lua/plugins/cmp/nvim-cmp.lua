return {
  { "hrsh7th/cmp-nvim-lsp", lazy = false },
  { "hrsh7th/cmp-buffer", lazy = false },
  { "hrsh7th/cmp-path", lazy = false },
  { "hrsh7th/cmp-cmdline", lazy = false },
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    config = function()
      require("config.cmp")
    end,
  },
  { "hrsh7th/cmp-vsnip", lazy = false },
  { "hrsh7th/vim-vsnip", lazy = false },
}
