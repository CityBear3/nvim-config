return {
  { 
    "airblade/vim-gitgutter",
    lazy = false,
    config = function()
      vim.api.nvim_set_hl(0, "GitGutterAddLineNr", { fg = "#00ff00" })
      vim.api.nvim_set_hl(0, "GitGutterChangeLineNr", { fg = "#ffff00" })
      vim.api.nvim_set_hl(0, "GitGutterDeleteLineNr", { fg = "#ff0000" })
      vim.api.nvim_set_hl(0, "GitGutterChangeDeleteLineNr", { fg = "#ff00ff" })
    end,
  },
}
