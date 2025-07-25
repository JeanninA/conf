return {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            view_options = { show_hidden = true },
        })
        vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
        -- to open in a floating window, uncomment the line below
        -- vim.keymap.set("n", "-", ":Oil --float<CR>", { desc = "Open parent directory" })
    end,
}
