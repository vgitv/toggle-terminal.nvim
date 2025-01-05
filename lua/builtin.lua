-- Here are defined the :Terminal builtin subcommands:
-- :Terminal <builtin-subcommand>

local M = {}
M.subcommands = {}


local utils = require('utils')
local options = {}
local state = {
    buf = -1,
    win = -1,
    height = -1,
}
local full_height = false


M.setup_options = function(opts)
    options = opts or {}
end


-- split current window
M.subcommands.toggle_window = function(relative_height)
    relative_height = relative_height or options.relative_height
    local height = math.floor(vim.o.lines * relative_height)
    if not vim.api.nvim_win_is_valid(state.win) then
        state = utils.create_window_below { height = height, buf = state.buf }
        if vim.bo[state.buf].buftype ~= 'terminal' then
            -- The options should be set first because the presence of 'number' may change the way
            -- the prompt is display (becaus it changes the terminal width)
            utils.set_local_options(options.local_options)
            vim.bo.buflisted = false
            vim.opt_local.winhighlight = 'Normal:MainTerminalNormal'
            -- Create terminal instance after setting local options
            vim.cmd.terminal()
        end
        if options.startinsert then
            vim.cmd.startinsert()
        end
    else
        vim.api.nvim_win_hide(state.win)
    end
end


M.subcommands.toggle_fullheight = function()
    if vim.api.nvim_win_is_valid(state.win) then
        if full_height then
            vim.api.nvim_win_set_height(state.win, state.height)
            full_height = false
        else
            vim.api.nvim_win_set_height(state.win, vim.o.lines)
            full_height = true
        end
    end
end


return M
