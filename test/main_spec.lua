describe("main", function()
    local nvim

    local buf
    local lines

    before_each(function()
        buf = 0
        lines = {
            [[<<<<<<< HEAD]],
            [[local value = 5 + 7]],
            [[print(value)]],
            [[print(string.format("value is %d", value))]],
            [[=======]],
            [[local value = 1 - 1]],
            [[>>>>>>> new_branch]],
        }

        nvim = vim.fn.jobstart(
            { "nvim", "--embed", "--headless", "-c", 'lua require("conflict-marker").setup()' },
            { rpc = true }
        )
        vim.fn.rpcrequest(nvim, "nvim_buf_set_lines", buf, 0, -1, true, lines)
    end)

    after_each(function()
        vim.fn.jobstop(nvim)
    end)

    it("sets lines correctly", function()
        local result = vim.fn.rpcrequest(nvim, "nvim_buf_get_lines", buf, 0, -1, true)
        assert.is_same(result, lines)
    end)
end)
