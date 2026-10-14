-- ~/.config/nvim/lua/mm/plugins/lualine.lua

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        icons_enabled = true,
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = { { "branch", icon = "" }, "diff" },
        lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
        lualine_x = { { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } }, "filetype" },
        lualine_y = { "progress" },
        lualine_z = { { "location", icon = "" } },
      },
    })
  end,
}
