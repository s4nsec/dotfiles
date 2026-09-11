return {
    "aznhe21/actions-preview.nvim",
    keys = {
        {
            "<leader>vca",
            function()
                require("actions-preview").code_actions()
            end,
            mode = { "n", "x" },
            desc = "Preview code actions",
        },
    },
}
