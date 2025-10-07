return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "folke/neodev.nvim", opts = {} },
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        { "folke/trouble.nvim", opts = {} },
    },
    config = function()
        local nvim_lsp = require("lspconfig")
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local protocol = require("vim.lsp.protocol")
        local trouble = require("trouble")

        mason.setup()

        mason_lspconfig.setup({
            ensure_installed = {
                "clangd",
                "tsserver",
                "cssls",
                "tailwindcss",
                "html",
                "jsonls",
                "eslint",
                "pyright",
            },
        })

        -- 🔹 Diagnostic settings
        vim.diagnostic.config({
            virtual_text = {
                spacing = 2,
                prefix = "●",
                wrap = true,  -- wrap long diagnostic messages
                max_width = 80, -- force wrapping after 80 chars
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                focusable = true,
                source = "always",
                header = "",
                prefix = "",
                max_width = 80, -- force wrapping after 80 chars
                wrap = true,  -- ensures floating diagnostics wrap too
            },
            severity_sort = true,
        })

        -- 🔹 Custom diagnostic signs
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- 🔹 Trouble keymaps
        vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true })
        vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true })
        vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true })
        vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true })
        vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true })
        vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { silent = true })

        -- 🔹 on_attach function
        local on_attach = function(client, bufnr)
            -- format on save (disable for clangd)
            if client.server_capabilities.documentFormattingProvider and client.name ~= "clangd" then
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("Format", { clear = true }),
                    buffer = bufnr,
                    callback = function()
                        vim.lsp.buf.format()
                    end,
                })
            end

            -- keymaps for LSP
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end

        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- 🔹 Setup handlers
        mason_lspconfig.setup_handlers({
            function(server)
                nvim_lsp[server].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                })
            end,

            -- clangd custom setup
            ["clangd"] = function()
                nvim_lsp["clangd"].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--completion-style=detailed",
                        "--header-insertion=never",
                    },
                    init_options = {
                        clangdFileStatus = true,
                    },
                })
            end,
        })
    end,
}
