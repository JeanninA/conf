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
                svelte = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "yamlfmt" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                liquid = { "prettier" },
                lua = { "stylua" },
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,
                sql = { "sqlfmt" },
                go = { "gofmt", "goimports" },
            },
            format_on_save = function(bufnr)
                local ignore_filetypes = {
                    yaml = true,
                    yml = true,
                    json = true,
                }

                local ft = vim.bo[bufnr].filetype
                if ignore_filetypes[ft] then
                    return nil
                end

                return {
                    timeout_ms = 500,
                    lsp_fallback = true,
                }
            end,
        })

        vim.keymap.set({ "n", "v" }, "<leader>mf", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 2500,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
