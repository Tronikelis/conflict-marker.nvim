local utils = require("conflict-marker.utils")

local M = {}

local CONFLICT_START = "^<<<<<<<"
local CONFLICT_END = "^>>>>>>>"
local CONFLICT_MID = "^=======$"

local BUF_OPT_CONFLICT = "_conflict_marker_nvim"

---@class conflict-marker.Conflict
---@field bufnr integer
local Conflict = {}

---@param obj conflict-marker.Conflict
---@return conflict-marker.Conflict
function Conflict:new(obj)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@param fn fun()
function Conflict:in_buf(fn)
    vim.api.nvim_buf_call(self.bufnr, fn)
end

---returns [down, up] lines
---@param pattern  string
---@return integer, integer
function Conflict:two_way_search(pattern)
    local down, up = 0, 0

    self:in_buf(function()
        down = vim.fn.search(pattern, "zcnbW")
        up = vim.fn.search(pattern, "zcnW")
    end)

    return down, up
end

---@return integer?, integer?
function Conflict:conflict_range()
    local from, to = 0, 0
    local in_range = true

    self:in_buf(function()
        from = vim.fn.search(CONFLICT_START, "zcnbW")
        to = vim.fn.search(CONFLICT_END, "zcnW")
    end)

    if from == 0 or to == 0 then
        return nil, nil
    end

    self:in_buf(function()
        -- don't accept cursor pos
        local up_end = vim.fn.search(CONFLICT_END, "znbW")
        if up_end == 0 then
            return
        end

        -- if conflict end is above conflict start
        if up_end > from then
            in_range = false
        end
    end)

    if not in_range then
        return nil, nil
    end

    return from, to
end

function Conflict:choose_ours()
    local from, to = self:conflict_range()
    if not from or not to then
        return
    end

    local start = utils.target_in_range(from, to, self:two_way_search(CONFLICT_START))
    local ending = utils.target_in_range(from, to, self:two_way_search(CONFLICT_MID))
    if not start or not ending then
        return
    end

    vim.api.nvim_buf_set_lines(self.bufnr, start - 1, start, true, {})
    -- offset by -1 because we deleted one line above
    vim.api.nvim_buf_set_lines(self.bufnr, ending - 2, to - 1, true, {})
end

function Conflict:choose_theirs()
    local from, to = self:conflict_range()
    if not from or not to then
        return
    end

    local start = utils.target_in_range(from, to, self:two_way_search(CONFLICT_MID))
    local ending = utils.target_in_range(from, to, self:two_way_search(CONFLICT_END))
    if not start or not ending then
        return
    end

    vim.api.nvim_buf_set_lines(self.bufnr, ending - 1, ending, true, {})
    vim.api.nvim_buf_set_lines(self.bufnr, from - 1, start, true, {})
end

function Conflict:choose_both()
    local from, to = self:conflict_range()
    if not from or not to then
        return
    end

    local start = utils.target_in_range(from, to, self:two_way_search(CONFLICT_START))
    local mid = utils.target_in_range(from, to, self:two_way_search(CONFLICT_MID))
    local ending = utils.target_in_range(from, to, self:two_way_search(CONFLICT_END))
    if not start or not mid or not ending then
        return
    end

    -- loop reverse, so I don't need to do - i
    for _, v in ipairs({ ending, mid, start }) do
        vim.api.nvim_buf_set_lines(self.bufnr, v - 1, v, true, {})
    end
end

function Conflict:choose_none()
    local from, to = self:conflict_range()
    if not from or not to then
        return
    end

    vim.api.nvim_buf_set_lines(self.bufnr, from - 1, to, true, {})
end

---@param fn fun(arg: conflict-marker.Conflict)
local function from_buffer_opts(fn)
    local arg = vim.b[BUF_OPT_CONFLICT]
    if not arg then
        return
    end
    fn(Conflict:new(arg))
end

function M.setup()
    vim.api.nvim_create_user_command("ConflictOurs", function()
        from_buffer_opts(function(conflict)
            conflict:choose_ours()
        end)
    end, {})
    vim.api.nvim_create_user_command("ConflictTheirs", function()
        from_buffer_opts(function(conflict)
            conflict:choose_theirs()
        end)
    end, {})
    vim.api.nvim_create_user_command("ConflictBoth", function()
        from_buffer_opts(function(conflict)
            conflict:choose_both()
        end)
    end, {})
    vim.api.nvim_create_user_command("ConflictNone", function()
        from_buffer_opts(function(conflict)
            conflict:choose_none()
        end)
    end, {})

    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function(ev)
            local bufnr = ev.buf
            local conflict = 0

            vim.api.nvim_buf_call(bufnr, function()
                conflict = vim.fn.search(CONFLICT_MID, "n")
            end)

            if conflict == 0 then
                return
            end

            ---@type conflict-marker.Conflict
            local args = { bufnr = bufnr }
            vim.b[bufnr][BUF_OPT_CONFLICT] = args
        end,
    })
end

return M
