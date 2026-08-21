-- macro-turbo: apply a macro across a range with the environment suspended.
--
-- Replaying `@q` over many lines is slow because every iteration wakes up the
-- whole editor: nvim-lint spawns eslint_d on InsertLeave, `clipboard=unnamedplus`
-- shells out to pbcopy on every delete, treesitter re-parses, smear-cursor
-- animates. None of that affects the result, so we switch it off, run the macro,
-- and switch it back on.
--
-- What we deliberately leave alone: anything that *produces text*. nvim-autopairs
-- (which works via insert-mode mappings, not autocmds), LuaSnip, and 'smartindent'
-- were all active while the macro was recorded, so the recorded keystrokes account
-- for them. Disabling them here would silently change the output.

local M = {}

-- `eventignore=all` covers autocmd-driven plugins, but not these two categories:
--   * nvim_buf_attach listeners (treesitter, gitsigns) fire on every byte changed
--   * anything driven by a timer or a global flag (smear-cursor)
local function suspend(buf, win)
    local saved = {
        eventignore = vim.o.eventignore,
        clipboard = vim.o.clipboard,
        report = vim.o.report,
        lazyredraw = vim.o.lazyredraw,
        spell = vim.wo[win].spell,
        treesitter = vim.treesitter.highlighter.active[buf] ~= nil,
    }

    vim.o.eventignore = "all" -- nvim-lint, cmp, copilot, gitsigns, lualine, fidget
    vim.o.clipboard = "" -- no pbcopy round-trip per delete/yank
    vim.o.report = 999999 -- no "N fewer lines" message per iteration
    vim.o.lazyredraw = true
    vim.wo[win].spell = false

    if saved.treesitter then
        pcall(vim.treesitter.stop, buf)
    end
    pcall(function()
        require("gitsigns").detach(buf)
    end)
    pcall(function()
        local smear = require("smear_cursor")
        saved.smear = smear.enabled
        smear.enabled = false
    end)
    pcall(vim.diagnostic.enable, false, { bufnr = buf })

    return saved
end

local function restore(buf, win, saved)
    vim.o.eventignore = saved.eventignore
    vim.o.clipboard = saved.clipboard
    vim.o.report = saved.report
    vim.o.lazyredraw = saved.lazyredraw
    if vim.api.nvim_win_is_valid(win) then
        vim.wo[win].spell = saved.spell
    end

    if saved.treesitter then
        pcall(vim.treesitter.start, buf)
    end
    pcall(function()
        require("gitsigns").attach(buf)
    end)
    if saved.smear ~= nil then
        pcall(function()
            require("smear_cursor").enabled = saved.smear
        end)
    end
    pcall(vim.diagnostic.enable, true, { bufnr = buf })

    -- one catch-up pass instead of one per line
    pcall(function()
        require("lint").try_lint()
    end)
    vim.cmd("redraw!")
end

-- Returns nil on success, or a message describing where it stopped.
local function replay(buf, win, reg, first, last)
    local lnum, stopped = first, nil
    local applied, joined = 0, false

    while lnum <= last do
        if lnum > vim.api.nvim_buf_line_count(buf) then
            break
        end

        local count_before = vim.api.nvim_buf_line_count(buf)
        local tick_before = vim.b[buf].changedtick

        vim.api.nvim_win_set_cursor(win, { lnum, 0 })

        -- Collapse every iteration into a single undo entry. Skipped on the
        -- first pass so we don't join onto an unrelated earlier edit, and
        -- pcall'd because undojoin errors if the last action was an undo.
        if joined then
            pcall(vim.cmd, "undojoin")
        end

        local ok, err = pcall(vim.cmd, "normal @" .. reg)
        joined = true

        if not ok then
            -- Catchable failures (a failed /search, E-codes, errors raised from
            -- a mapping). Note these do NOT abort the rest of the macro, so the
            -- current line may already be partially edited.
            stopped = ("stopped at line %d: %s"):format(lnum, tostring(err):gsub("^.-:%s*", ""))
            break
        end

        if vim.b[buf].changedtick == tick_before then
            -- Nothing changed. A failed `f`/`t` motion is silent and
            -- uncatchable, but it does abort the rest of that macro run, so
            -- "no modification" is our only signal that it happened.
            stopped = ("stopped at line %d: macro changed nothing (a motion likely failed)"):format(lnum)
            break
        end

        applied = applied + 1

        -- The macro consumed one line and left (1 + delta) in its place, so the
        -- next target and the end of the range both shift by delta.
        local delta = vim.api.nvim_buf_line_count(buf) - count_before
        last = last + delta
        lnum = lnum + 1 + delta
    end

    return stopped, applied
end

---@param reg string single register name, e.g. "q"
---@param first integer 1-indexed first line of the range
---@param last integer 1-indexed last line of the range
function M.run(reg, first, last)
    reg = (reg == "" or reg == nil) and "q" or reg

    if #reg ~= 1 then
        vim.notify("macro-turbo: expected a single register name, got " .. vim.inspect(reg), vim.log.levels.ERROR)
        return
    end
    if vim.fn.getreg(reg) == "" then
        vim.notify("macro-turbo: register '" .. reg .. "' is empty", vim.log.levels.ERROR)
        return
    end
    if not vim.bo.modifiable then
        vim.notify("macro-turbo: buffer is not modifiable", vim.log.levels.ERROR)
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local started = vim.uv.hrtime()

    local saved = suspend(buf, win)
    -- restore() must run on every path: leaving eventignore=all set would kill
    -- completion, linting and git signs with nothing on screen to explain why.
    local ok, result, applied = pcall(replay, buf, win, reg, first, last)
    restore(buf, win, saved)

    local elapsed = (vim.uv.hrtime() - started) / 1e6

    if vim.api.nvim_win_is_valid(win) then
        local line = math.min(cursor[1], vim.api.nvim_buf_line_count(buf))
        pcall(vim.api.nvim_win_set_cursor, win, { line, cursor[2] })
    end

    if not ok then
        vim.notify("macro-turbo: " .. tostring(result), vim.log.levels.ERROR)
    elseif result then
        vim.notify(
            ("macro-turbo: %s (%d line%s applied, undo once to revert)")
                :format(result, applied, applied == 1 and "" or "s"),
            vim.log.levels.WARN
        )
    else
        vim.notify(("macro-turbo: %d lines in %.0fms"):format(applied, elapsed))
    end
end

vim.api.nvim_create_user_command("MacroTurbo", function(opts)
    M.run(opts.args, opts.line1, opts.line2)
end, {
    range = true,
    nargs = "?",
    desc = "Apply a macro over a range with autocmds/clipboard/treesitter suspended",
})

return M
