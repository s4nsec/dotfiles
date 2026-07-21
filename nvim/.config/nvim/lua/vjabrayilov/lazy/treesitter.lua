return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local parsers = {
            "bash", "c", "javascript", "jsdoc", "lua", "markdown",
            "markdown_inline", "rust", "templ", "typescript", "vimdoc",
        }
        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "bash", "c", "help", "javascript", "lua", "markdown",
                "rust", "templ", "typescript",
            },
            callback = function()
                vim.treesitter.start()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end
}
