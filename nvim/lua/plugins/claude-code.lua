-- Find the job id of the running Claude terminal (if any)
local function claude_job()
    local state = require("claude-code").claude_code
    local bufnr = state.instances[state.current_instance]
    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
        for _, b in pairs(state.instances) do
            if vim.api.nvim_buf_is_valid(b) then
                bufnr = b
                break
            end
        end
    end
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        return vim.b[bufnr].terminal_job_id, bufnr
    end
end

-- Send "@path" (or "@path#Lx-y" for a visual range) to Claude and focus it
local function send_to_claude(range)
    local path = vim.fn.expand("%:.")
    if path == "" or vim.bo.buftype ~= "" then
        vim.notify("Current buffer is not a file", vim.log.levels.WARN)
        return
    end
    local ref = "@" .. path
    if range then
        ref = ref .. string.format("#L%d-%d", range[1], range[2])
    end

    local function send()
        local job, bufnr = claude_job()
        if not job then
            return false
        end
        vim.fn.chansend(job, ref .. " ")
        local win = vim.fn.win_findbuf(bufnr)[1]
        if not win then
            vim.cmd("ClaudeCode")
        else
            vim.api.nvim_set_current_win(win)
        end
        vim.cmd("startinsert")
        return true
    end

    if not send() then
        -- Claude not running yet: start it, then send once it has booted
        vim.cmd("ClaudeCode")
        vim.defer_fn(send, 1500)
    end
end

return {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
    opts = {
        window = {
            position = "botright vsplit",
            split_ratio = 0.35,
        },
        keymaps = {
            toggle = {
                normal = false,
                terminal = "<C-,>", -- hide Claude from inside its terminal
                variants = {},
            },
        },
    },
    keys = {
        { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude" },
        { "<leader>aC", "<cmd>ClaudeCodeContinue<CR>", desc = "Continue last Claude session" },
        { "<leader>ar", "<cmd>ClaudeCodeResume<CR>", desc = "Resume Claude session" },
        {
            "<leader>ab",
            function()
                send_to_claude()
            end,
            desc = "Send buffer to Claude",
        },
        {
            "<leader>ab",
            function()
                local s, e = vim.fn.line("v"), vim.fn.line(".")
                vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
                send_to_claude({ math.min(s, e), math.max(s, e) })
            end,
            mode = "x",
            desc = "Send selection to Claude",
        },
    },
}
