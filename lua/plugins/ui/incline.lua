return {
  'b0o/incline.nvim',
  config = function()
    vim.opt.termguicolors = false
    require('incline').setup()
  end,
}
