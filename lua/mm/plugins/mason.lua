-- ~/nvim/lua/slydragonn/plugins/mason.lua

return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            automatic_installation = true,
            automatic_enable = false,
            ensure_installed = {
                "cssls",
                "eslint",
                "html",
                "jsonls",
                "tsserver",
                "pyright",
                "tailwindcss",
                "rust_analyzer",
                "kotlin_language_server",
            },
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettier",
                "stylua", -- lua formatter
                "isort", -- python formatter
                "black", -- python formatter
                "pylint",
                "eslint_d",
                "ktlint",
            },
        })
    end,
}

