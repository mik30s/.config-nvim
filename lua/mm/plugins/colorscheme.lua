-- ~/.config/nvim/lua/mm/plugins/colorscheme.lua
-- Neon dark green theme built on catppuccin (mocha = dark, latte = light)

local dark = {
  rosewater = "#c6ffdd", flamingo = "#a8ffcf", pink = "#ff4fd8", mauve = "#b388ff",
  red = "#ff3864", maroon = "#ff6b8b", peach = "#ffb347", yellow = "#e8ff3a",
  green = "#39ff14", teal = "#00ffb3", sky = "#00f5d4", sapphire = "#2bffcf",
  blue = "#5cffa1", lavender = "#9dff7a",
  text = "#dcffe4", subtext1 = "#b4f5c4", subtext0 = "#8fdca3",
  overlay2 = "#6fbf85", overlay1 = "#559e6a", overlay0 = "#3f7d51",
  surface2 = "#2a5a37", surface1 = "#1c4026", surface0 = "#12301a",
  base = "#07140b", mantle = "#040e07", crust = "#020803",
}

local light = {
  rosewater = "#00804a", flamingo = "#009955", pink = "#d6009a", mauve = "#7a1fff",
  red = "#e0003c", maroon = "#c2185b", peach = "#e65c00", yellow = "#8a9a00",
  green = "#00b828", teal = "#00a37a", sky = "#0096a8", sapphire = "#008f6b",
  blue = "#00994d", lavender = "#3fa600",
  text = "#06301a", subtext1 = "#0d4426", subtext0 = "#175a33",
  overlay2 = "#2f7a4b", overlay1 = "#4a9465", overlay0 = "#6aae82",
  surface2 = "#9fe0b4", surface1 = "#bdf0cb", surface0 = "#d6fadf",
  base = "#effff3", mantle = "#e2fbe8", crust = "#d2f5da",
}

local function read_mode()
  local f = vim.fn.expand("~/.cache/theme_mode")
  if vim.fn.filereadable(f) == 1 and vim.fn.readfile(f)[1] == "light" then
    return "light"
  end
  return "dark"
end

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = false,
      term_colors = true,
      color_overrides = { mocha = dark, latte = light },
      styles = {
        comments = { "italic" },
        keywords = { "bold" },
        functions = { "bold" },
        conditionals = { "italic" },
      },
      custom_highlights = function(c)
        return {
          CursorLineNr = { fg = c.green, style = { "bold" } },
          LineNr = { fg = c.overlay0 },
          CursorLine = { bg = c.surface0 },
          Visual = { bg = c.surface1, style = { "bold" } },
          WinSeparator = { fg = c.green },
          FloatBorder = { fg = c.green, bg = c.mantle },
          NormalFloat = { bg = c.mantle },
          TelescopeBorder = { fg = c.green, bg = c.mantle },
          TelescopeTitle = { fg = c.crust, bg = c.green, style = { "bold" } },
          NeoTreeNormal = { bg = c.mantle },
          NeoTreeNormalNC = { bg = c.mantle },
          NeoTreeDirectoryIcon = { fg = c.green },
          NeoTreeDirectoryName = { fg = c.teal },
          NeoTreeRootName = { fg = c.green, style = { "bold" } },
          MatchParen = { fg = c.crust, bg = c.green, style = { "bold" } },
          Search = { fg = c.crust, bg = c.teal },
          IncSearch = { fg = c.crust, bg = c.green },
          PmenuSel = { fg = c.crust, bg = c.green, style = { "bold" } },
        }
      end,
      integrations = {
        cmp = true, gitsigns = true, neotree = true, treesitter = true,
        telescope = { enabled = true }, mason = true, render_markdown = true,
        native_lsp = { enabled = true, underlines = {
          errors = { "undercurl" }, warnings = { "undercurl" },
          hints = { "undercurl" }, information = { "undercurl" },
        } },
      },
    })

    local function apply(mode)
      mode = mode or read_mode()
      vim.o.background = mode
      vim.cmd.colorscheme(mode == "light" and "catppuccin-latte" or "catppuccin-mocha")
      if package.loaded["lualine"] then
        local ll = require("lualine")
        pcall(ll.setup, ll.get_config())
      end
    end

    vim.api.nvim_create_user_command("NeonTheme", function(o)
      apply(o.args ~= "" and o.args or nil)
    end, { nargs = "?", complete = function() return { "dark", "light" } end })

    apply()
  end,
}
