# 🚨 Code Police.nvim

Code Police is a Neovim plugin that aggressively enforces clean code standards. It visualizes complexity directly in your editor and punishes you for:

- Deep nesting (Exponential penalties!)
- Massive functions
- Spaghetti loops

It rewards you for good behavior, like adding top-level error handling (`try/catch`).

## ✨ Features

- **Complexity Analysis:** Calculates a score based on nesting depth and control flow.
- **Visual Feedback:** Shows ■ OK, ■ Big, or ■ Huge (Red) virtual text.
- **Strict Mode:** Depth > 3 is mathematically illegal.

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "reeteppup/code-police.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("code-police").setup()
  end,
}
```
