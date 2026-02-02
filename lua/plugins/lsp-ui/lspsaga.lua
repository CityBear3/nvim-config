return {
  { 
    "nvimdev/lspsaga.nvim", 
    lazy = false,
    config = function()
      require("lspsaga").setup({
        -- UI Config
        ui = {
          border = "rounded",
          code_action = "💡",
        },
        -- lightbulb Config
        lightbulb = {
          enable = true,
          sign = true,
          virtual_text = true,
        },
        -- finder Config
        finder = {
          keys = {
            edit = "o",
            vsplit = "s",
            split = "i",
            tabe = "t",
            quit = "q",
          },
        },
        -- Symbol Outline config
        outline = {
          win_width = 40,
          show_symbol_details = true,
          auto_preview = true,
        },
      })
    end,
  },
}
