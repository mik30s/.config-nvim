-- ~/nvim/lua/slydragonn/plugins/colorscheme.lua

return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme tokyonight-day")
    end,
}
 
