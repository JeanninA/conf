return {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = function()
        require("no-neck-pain").setup({
            width = 180, -- largeur maximale de la zone de code
            autocmds = {
                enableOnVimEnter = true,
            },
        })
    end,
}
