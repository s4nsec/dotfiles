return {
    "tanvirtin/vgit.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
        require("vgit").setup({
            settings = {
                -- Gitsigns remains responsible for the sign column.
                live_gutter = { enabled = false },
            },
        })
    end,
}
