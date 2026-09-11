return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()

        -- Applied to every server. mason-lspconfig merges its own overrides on top.
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    }
                }
            }
        })

        -- ruff is lint/format only: no goto-definition, no hover. pyright covers those.
        vim.lsp.config("ruff", {
            on_attach = function(client)
                client.server_capabilities.hoverProvider = false
            end,
        })

        vim.lsp.config("ltex_plus", {
            settings = {
                ltex = {
                    language = "en-GB",
                    diagnosticSeverity = "information",
                    additionalRules = {
                        enablePickyRules = false,
                    },
                    disabledRules = {
                        ["en-GB"] = { "MORFOLOGIK_RULE_EN_GB" },
                    },
                },
            },
        })

        vim.lsp.config("texlab", {
            settings = {
                texlab = {
                    build = {
                        executable = "latexmk",
                        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                        onSave = true,
                    },
                    chktex = {
                        onOpenAndSave = true,
                        onEdit = false,
                    },
                },
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ruff",
                "pyright",
                "gopls",
                "rust_analyzer",
                "clangd",
                "marksman",
                "texlab",
                "ltex_plus",
            },
            -- rustaceanvim owns rust_analyzer; enabling it here too spawns a second client.
            automatic_enable = { exclude = { "rust_analyzer" } },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
