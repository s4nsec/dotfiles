return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        lazy = false,
        config = function()
            require("rose-pine").setup({
                variant = "auto",      -- "main", "moon", "dawn" or "auto" (follows background)
                dark_variant = "main", -- used when background=dark and variant="auto"
                styles = {
                    italic = true,
                    transparency = true,
                },
            })
            vim.cmd("colorscheme rose-pine")
        end
    },

    {
        -- kept installed so <leader>uC can switch to it; not applied at startup
        "ellisonleao/gruvbox.nvim",
        lazy = true,
        opts = {
            terminal_colors = true,
            italic = {
                strings = true,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            invert_tabline = true,
            transparent_mode = true,
        },
    },
}
