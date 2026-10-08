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
        opts.custom_highlights = function(colors)
            return {
                CursorLine = { bg = "#0d4a1e" },
                CursorColumn = { bg = "#0d4a1e" },
            }
        end
        require("catppuccin").setup(opts)
        local theme_file = vim.fn.expand("~/.cache/theme_mode")
        local flavor = "mocha"
        if vim.fn.filereadable(theme_file) == 1 then
            local mode = vim.fn.readfile(theme_file)[1]
            if mode == "light" then
                flavor = "latte"
            end
        end
        vim.cmd("colorscheme catppuccin-" .. flavor)
    end,
}
 
