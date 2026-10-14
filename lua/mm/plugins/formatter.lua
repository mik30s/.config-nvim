-- ~/nvim/lua/slydragonn/plugins/formatter.lua

return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
                python = { "isort", "black" },
                kotlin = { "ktlint" },
            },
            format_on_save = function(bufnr)
                local slow = { kotlin = true }
                return {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = slow[vim.bo[bufnr].filetype] and 5000 or 1000,
                }
            end,
        })

        vim.keymap.set({ "n", "v" }, "<leader>f", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
 
