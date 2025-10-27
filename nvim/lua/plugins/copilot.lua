return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        config = function()
            require("copilot").setup({ copilot_model = "gpt-5-copilot" })
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
    -- {
    --     "CopilotC-Nvim/CopilotChat.nvim",
    --     dependencies = {
    --         { "zbirenbaum/copilot.lua" },
    --         { "nvim-lua/plenary.nvim", branch = "master" },
    --     },
    --     build = "make tiktoken", -- Only on MacOS or Linux
    --     opts = {
    --         mappings = {
    --             reset = {
    --                 insert = "<C-r>",
    --                 normal = "<C-r>",
    --             },
    --         },
    --     },
    -- },
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
                        model = "gpt-5-copilot",
                    },
                },
                -- NOTE: The log_level is in `opts.opts`
                opts = {
                    log_level = "DEBUG",
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
