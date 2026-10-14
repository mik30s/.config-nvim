-- ~/.config/nvim/lua/mm/plugins/devicons.lua
-- Lua devicons (used by neo-tree, lualine, telescope). Requires a Nerd Font in terminal.

return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    default = true,
    strict = true,
    color_icons = true,
  },
}
