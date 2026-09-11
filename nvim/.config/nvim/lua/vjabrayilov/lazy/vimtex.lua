return {
    "lervag/vimtex",
    commit = "182ad387e3f3107699483606c9a2b6648f8437b2",
    lazy = false,
    init = function()
        vim.cmd("filetype plugin indent on")
        vim.g.vimtex_syntax_enabled = 0
        vim.g.vimtex_compiler_method = vim.fn.executable("tectonic") == 1 and "tectonic" or "latexmk"
        vim.g.vimtex_quickfix_open_on_warning = 0

        if vim.fn.has("mac") == 1 then
            vim.g.vimtex_view_method = "skim"
        end
    end,
}
