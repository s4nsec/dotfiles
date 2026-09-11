return {
    "pablos123/shellcheck.nvim",
    ft = { "sh", "bash", "ksh" },
    config = function()
        require("shellcheck-nvim").setup({})
    end,
}
