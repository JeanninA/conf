return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        config = function()
            require("copilot").setup({})
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        config = function()
            require("copilot_cmp").setup()
        end,
        dependencies = { "zbirenbaum/copilot.lua" },
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("codecompanion").setup({
                strategies = {
                    chat = {
                        adapter = "copilot",
                    },
                    inline = {
                        adapter = "copilot",
                    },
                    cmd = {
                        adapter = "copilot",
                    },
                },
                display = {
                    chat = {
                        window = {
                            position = "right",
                        },
                    },
                },
            })

            vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat<CR>", { desc = "Open Code Companion Chat" })
        end,
    },
}
