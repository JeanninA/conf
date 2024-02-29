return {
    "ThePrimeagen/harpoon",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        vim.keymap.set("n", "<leader>m", "<cmd>lua require('harpoon.mark').add_file()<cr>")
        vim.keymap.set("n", "<leader>n", "<cmd>lua require('harpoon.ui').nav_next()<cr>")
        vim.keymap.set("n", "<leader>p", "<cmd>lua require('harpoon.ui').nav_prev()<cr>")
        vim.keymap.set("n", "<leader>h", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>")
        vim.keymap.set("n", "<leader>1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>")
        vim.keymap.set("n", "<leader>2", "<cmd>lua require('harpoon.ui').nav_prev(2)<cr>")
        vim.keymap.set("n", "<leader>3", "<cmd>lua require('harpoon.ui').nav_prev(3)<cr>")
        vim.keymap.set("n", "<leader>4", "<cmd>lua require('harpoon.ui').nav_prev(4)<cr>")
        vim.keymap.set("n", "<leader>5", "<cmd>lua require('harpoon.ui').nav_prev(5)<cr>")
        vim.keymap.set("n", "<leader>6", "<cmd>lua require('harpoon.ui').nav_prev(6)<cr>")
        vim.keymap.set("n", "<leader>7", "<cmd>lua require('harpoon.ui').nav_prev(7)<cr>")
        vim.keymap.set("n", "<leader>8", "<cmd>lua require('harpoon.ui').nav_prev(8)<cr>")
        vim.keymap.set("n", "<leader>9", "<cmd>lua require('harpoon.ui').nav_prev(9)<cr>")
    end,
}
