local M = {}

---returns first target which is in range [from, to]
---@param ... integer
---@param from integer
---@param to integer
---@return integer?
function M.target_in_range(from, to, ...)
    local arg = { ... }
    for _, v in ipairs(arg) do
        if v >= from and v <= to then
            return v
        end
    end

    return nil
end

return M
