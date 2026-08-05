return {
  "zbirenbaum/copilot.lua",
  config = function()
    require("copilot").setup({
      filetypes = {
        markdown = true,
        yaml = true,
      },
      suggestion = {enabled = false},
      panel = {enabled = false},
    })
  end,
}

