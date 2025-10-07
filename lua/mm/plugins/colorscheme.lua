-- ~/nvim/lua/slydragonn/plugins/colorscheme.lua

return {
--    "folke/tokyonight.nvim",
--    "nyoom-engineering/oxocarbon.nvim",
--    "rmehri01/onenord.nvim",
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent_background = true, -- disables setting the background color.
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd("colorscheme  catppuccin")
    end,
}
 
