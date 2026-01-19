return {
  {
    "lambdalisue/glyph-palette.vim",
    lazy = false,
    config = function()
      vim.api.nvim_create_augroup("my-glyph-palette", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "my-glyph-palette",
        pattern = { "fern", "nerdtree", "startify" },
        callback = function()
          vim.fn["glyph_palette#apply"]()
        end,
      })
    end,
  },
}
