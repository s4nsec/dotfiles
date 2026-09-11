return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        -- nvim-treesitter main uses vim.list.unique, which arrives after Neovim 0.11.
        vim.list = vim.list or {}
        vim.list.unique = vim.list.unique or function(values)
            local result = {}
            local seen = {}
            for _, value in ipairs(values) do
                if not seen[value] then
                    seen[value] = true
                    table.insert(result, value)
                end
            end
            return result
        end

        local parsers = {
            "bash", "c", "javascript", "jsdoc", "latex", "lua", "markdown",
            "markdown_inline", "python", "rust", "templ", "typescript", "vimdoc",
        }
        local install_task = require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "bash", "c", "help", "javascript", "lua", "markdown",
                "python", "rust", "templ", "tex", "typescript",
            },
            callback = function(event)
                install_task:await(function(err)
                    if err then
                        return
                    end

                    vim.schedule(function()
                        if not vim.api.nvim_buf_is_valid(event.buf) then
                            return
                        end

                        local filetype = vim.bo[event.buf].filetype
                        local language = vim.treesitter.language.get_lang(filetype) or filetype
                        if not vim.list_contains(require("nvim-treesitter").get_installed("parsers"), language) then
                            return
                        end

                        vim.treesitter.start(event.buf)
                        if vim.treesitter.query.get(language, "indents") then
                            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end)
                end)
            end,
        })
    end
}
