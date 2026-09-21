local prose_filetypes = {
    "asciidoc",
    "gitcommit",
    "latex",
    "mail",
    "rst",
    "tex",
    "text",
    "typst",
}

return {
    "preservim/vim-pencil",
    init = function()
        vim.g["pencil#textwidth"] = 80
        vim.g["pencil#wrapModeDefault"] = "hard"
        vim.g["pencil#autoformat"] = 1
    end,
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("prose_wrapping", { clear = true }),
            pattern = prose_filetypes,
            callback = function()
                vim.fn["pencil#init"]({
                    wrap = "hard",
                    textwidth = 80,
                    autoformat = 1,
                })
                vim.opt_local.textwidth = 80
                vim.opt_local.formatoptions:remove("l")
            end,
        })

        -- Hard wrapping can split commands and other syntax inside fenced code
        -- blocks. Prettier handles Markdown prose while preserving those blocks.
        vim.api.nvim_create_autocmd("FileType", {
            group = "prose_wrapping",
            pattern = "markdown",
            callback = function()
                vim.fn["pencil#init"]({ wrap = "soft" })
            end,
        })
    end,
}
