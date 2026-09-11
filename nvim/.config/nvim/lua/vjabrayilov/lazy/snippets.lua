return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",

        dependencies = { "rafamadriz/friendly-snippets" },

        config = function()
            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node

            require("luasnip.loaders.from_vscode").lazy_load()

            ls.filetype_extend("javascript", { "jsdoc" })
            ls.filetype_extend("tex", { "latex" })
            ls.filetype_extend("plaintex", { "tex", "latex" })

            local markdown_snippets = {}
            local code_block_languages = {
                "bash",
                "c",
                "cpp",
                "css",
                "csv",
                "dockerfile",
                "go",
                "html",
                "java",
                "javascript",
                "json",
                "jsonc",
                "lua",
                "markdown",
                "markdown_inline",
                "php",
                "python",
                "regex",
                "sql",
                "templ",
                "txt",
                "yaml",
            }

            for _, language in ipairs(code_block_languages) do
                table.insert(markdown_snippets, s({
                    trig = ";" .. language,
                    name = language .. " code block",
                }, {
                    t({ "```" .. language, "" }),
                    i(1),
                    t({ "", "```" }),
                }))
            end

            table.insert(markdown_snippets, s(";markdownlint", {
                t({ "<!-- markdownlint-disable -->", "" }),
                i(1),
                t({ "", "<!-- markdownlint-restore -->" }),
            }))
            table.insert(markdown_snippets, s(";prettierignore", {
                t({ "<!-- prettier-ignore-start -->", "" }),
                i(1),
                t({ "", "<!-- prettier-ignore-end -->" }),
            }))
            table.insert(markdown_snippets, s(";link", {
                t("["),
                i(1, "text"),
                t("]("),
                i(2, "url"),
                t(")"),
            }))
            table.insert(markdown_snippets, s(";linkc", {
                t("["),
                i(1, "text"),
                t("]("),
                f(function()
                    return vim.fn.getreg("+")
                end, {}),
                t(")"),
            }))
            table.insert(markdown_snippets, s(";linkt", {
                t("["),
                i(1, "text"),
                t("]("),
                i(2, "url"),
                t('){:target="_blank"}'),
            }))
            table.insert(markdown_snippets, s(";linkex", {
                t("["),
                i(1, "text"),
                t("]("),
                f(function()
                    return vim.fn.getreg("+")
                end, {}),
                t('){:target="_blank"}'),
            }))
            for _, trigger in ipairs({ ";newline", ";pagebreak" }) do
                table.insert(markdown_snippets, s(trigger, {
                    t('<div style="page-break-after: always; visibility: hidden"> pagebreak </div>'),
                }))
            end
            table.insert(markdown_snippets, s(";todo", {
                t("<!-- TODO: "),
                i(1),
                t(" -->"),
            }))
            ls.add_snippets("markdown", markdown_snippets)

            ls.add_snippets("python", {
                s({
                    trig = ";dcl",
                    name = "Dataclass definition",
                }, {
                    t("@dataclass"),
                    i(1, "(frozen=True)"),
                    t({ "", "class " }),
                    i(2, "ClassName"),
                    i(3),
                    t({ ":", '    """' }),
                    i(4, "Docstring"),
                    t({ '"""', "", "    " }),
                    i(5, "attribute_name"),
                    t(": "),
                    i(6, "str"),
                    t({ "", "" }),
                    i(0),
                }),
            })

            --- TODO: What is expand?
            vim.keymap.set({ "i" }, "<C-s>e", function() ls.expand() end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<C-s>;", function() ls.jump(1) end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-s>,", function() ls.jump(-1) end, { silent = true })

            vim.keymap.set({ "i", "s" }, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, { silent = true })
        end,
    }
}
