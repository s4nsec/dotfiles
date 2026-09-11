local opencode_cmd = "opencode --port"
local terminal_opts = {
    win = {
        position = "right",
        enter = false,
    },
}

return {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = {
        {
            "folke/snacks.nvim",
            optional = true,
            opts = {
                picker = {
                    actions = {
                        opencode_send = function(picker)
                            local items = vim.tbl_map(function(item)
                                if item.file then
                                    return require("opencode").format({
                                        path = item.file,
                                        from = item.pos,
                                        to = item.end_pos,
                                    })
                                end
                                return item.text
                            end, picker:selected({ fallback = true }))

                            require("opencode").prompt(table.concat(items, ", ") .. " ")
                        end,
                    },
                    win = {
                        input = {
                            keys = {
                                ["<a-o>"] = { "opencode_send", mode = { "n", "i" } },
                            },
                        },
                    },
                },
            },
        },
    },
    init = function()
        vim.g.opencode_opts = {
            server = {
                start = function()
                    Snacks.terminal.open(opencode_cmd, terminal_opts)
                end,
            },
        }
        vim.o.autoread = true
    end,
    keys = {
        {
            "<leader>Oa",
            function()
                require("opencode").ask("@this: ")
            end,
            mode = { "n", "x" },
            desc = "Ask OpenCode",
        },
        {
            "<leader>Os",
            function()
                require("opencode").select()
            end,
            mode = { "n", "x" },
            desc = "Select OpenCode action",
        },
        {
            "<leader>Ot",
            function()
                Snacks.terminal.toggle(opencode_cmd, terminal_opts)
            end,
            desc = "Toggle OpenCode",
        },
        {
            "go",
            function()
                return require("opencode").operator("@this ")
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "Add range to OpenCode",
        },
        {
            "goo",
            function()
                return require("opencode").operator("@this ") .. "_"
            end,
            expr = true,
            desc = "Add line to OpenCode",
        },
        {
            "<S-C-u>",
            function()
                require("opencode").command("session.half.page.up")
            end,
            desc = "Scroll OpenCode up",
        },
        {
            "<S-C-d>",
            function()
                require("opencode").command("session.half.page.down")
            end,
            desc = "Scroll OpenCode down",
        },
    },
}
