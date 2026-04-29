return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter")
        treesitter.setup()
        treesitter.install({
            "python",
            "java",
            "c",
            "lua",
            "vim",
            "vimdoc",
            "query",
            "javascript",
            "typescript",
            "html",
            "yaml",
            "go",
            "rust",
            "markdown",
        })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "python",
                "java",
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "javascript",
                "typescript",
                "html",
                "yaml",
                "go",
                "rust",
                "markdown",
            },
            callback = function()
                -- syntax highlighting, provided by Neovim
                vim.treesitter.start()
                -- indentation, provided by nvim-treesitter
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
