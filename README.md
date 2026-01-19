# nvim-config

My personal Neovim configuration.

## Requirements

- Neovim >= 0.9
- Git
- [Nerd Font](https://www.nerdfonts.com/) (for icons)

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this repository
git clone https://github.com/CityBear3/nvim-config.git ~/.config/nvim

# Start Neovim (plugins will be installed automatically)
nvim
```

## Plugin Manager

[lazy.nvim](https://github.com/folke/lazy.nvim) is used for plugin management.

## Key Plugins

- **nvim-tree** - File explorer
- **telescope.nvim** - Fuzzy finder
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** - Completion engine
- **mason.nvim** - LSP/DAP/Linter installer
- **lspsaga.nvim** - LSP UI enhancements
- **copilot.vim** - GitHub Copilot
- **claudecode.nvim** - Claude Code integration

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lazy-lock.json        # Plugin version lock
└── lua/
    ├── config/           # Plugin configurations
    ├── core/             # Core settings (options, keymaps, autocmds)
    └── plugins/          # Plugin specifications
```