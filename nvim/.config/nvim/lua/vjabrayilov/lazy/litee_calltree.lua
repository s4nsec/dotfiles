return {
    "ldelossa/litee-calltree.nvim",
    dependencies = { "ldelossa/litee.nvim" },
    opts = {
        on_open = "panel",
        map_resize_keys = false,
    },
    keys = {
        {
            "<leader>li",
            vim.lsp.buf.incoming_calls,
            desc = "Incoming call tree",
        },
        {
            "<leader>lo",
            vim.lsp.buf.outgoing_calls,
            desc = "Outgoing call tree",
        },
    },
    config = function(_, opts)
        require("litee.calltree").setup(opts)
    end,
}
