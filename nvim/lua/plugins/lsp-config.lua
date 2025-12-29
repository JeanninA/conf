return {
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "html",
                    "pyright",
                    "cssls",
                    "tailwindcss",
                    "marksman",
                    "gopls",
                },
            })
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "stylua",
                    "prettier",
                    "eslint_d",
                    "mypy",
                    -- "ruff",
                    "black",
                    "isort",
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("lua_ls", { capabilities = capabilities })
            vim.lsp.config("ts_ls", { capabilities = capabilities })
            vim.lsp.config("html", { capabilities = capabilities })
            vim.lsp.config("pyright", {
                capabilities = capabilities,
                settings = {
                    pyright = {
                        disableOrganizeImports = true, -- Using Ruff
                    },
                    -- python = {
                    --     analysis = {
                    --         ignore = { "*" }, -- Using Ruff
                    --         typeCheckingMode = "off", -- Using mypy
                    --     },
                    -- },
                },
            })
            vim.lsp.config("cssls", { capabilities = capabilities })
            vim.lsp.config("tailwindcss", { capabilities = capabilities })
            vim.lsp.config("marksman", { capabilities = capabilities })
            vim.lsp.config("gopls", { capabilities = capabilities })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})

            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {})
            vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", {})

            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})
        end,
    },
}
