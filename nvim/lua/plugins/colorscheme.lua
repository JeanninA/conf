return {
    "rose-pine/neovim",
    priority = 1000,
    name = "rose-pine",
    config = function()
        require("rose-pine").setup({
            styles = { italic = false, transparency = true },
            highlight_groups = { Comment = { italic = true } },
        })
        vim.cmd.colorscheme("rose-pine")
    end,
}
