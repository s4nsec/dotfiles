return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                -- ruff_format does not sort imports; organize_imports runs first for that.
                python = { "ruff_organize_imports", "ruff_format" },
            },
            format_on_save = {
                timeout_ms = 2000,
                -- "never", not "fallback": fallback would also LSP-format every
                -- filetype absent from formatters_by_ft (go, lua, c, ...).
                lsp_format = "never",
            },
        })
    end
}
