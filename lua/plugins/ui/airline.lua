return {
  {
    "vim-airline/vim-airline",
    lazy = false,
    init = function()
      vim.g.airline_theme = "onedark"
      vim.g.airline_powerline_fonts = 1
      vim.g["airline#extensions#tabline#enabled"] = 1
    end,
  },
  { "vim-airline/vim-airline-themes", lazy = false },
}
