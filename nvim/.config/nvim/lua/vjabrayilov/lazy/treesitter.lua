return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash", "c", "javascript", "jsdoc", "latex", "lua", "markdown",
                "markdown_inline", "python", "rust", "templ", "typescript", "vimdoc",
            },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}
