return {
    "ldelossa/litee-calltree.nvim",
    dependencies = { "ldelossa/litee.nvim" },
    -- Load before the keys are pressed: lazy's key stub is an expr mapping, and
    -- litee creates its help buffer on require, which fails under textlock (E565).
    event = "LspAttach",
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
