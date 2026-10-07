return {
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup({})
        end,
        cmd = "Trouble",
        keys = {
            {
                "<leader>tt",
                "<cmd>Trouble diagnostics toggle focus=true<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader> tT",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>ts",
                "<cmd>Trouble symbols toggle focus=false win.size=0.4<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>td",
                "<cmd>Trouble lsp toggle focus=false win.position=right win.size=0.4<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>tl",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>tq",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
            {
                "gci",
                "<cmd>Trouble lsp_incoming_calls toggle focus=true<cr>",
                desc = "Incoming Calls (Trouble)",
            },
            {
                "gco",
                "<cmd>Trouble lsp_outgoing_calls toggle focus=true<cr>",
                desc = "Outgoing Calls (Trouble)",
            },
        },
    }
}
