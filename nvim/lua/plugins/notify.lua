return {
    "rcarriga/nvim-notify",
    config = function()
        local config = require("notify")
        config.setup({
            background_colour = "#000000", -- for 100% transparency
        })
    end,
}
