require("vjabrayilov.set")
require("vjabrayilov.remap")
require("vjabrayilov.lazy_init")

local augroup = vim.api.nvim_create_augroup
local vjabrayilov= augroup('vjabrayilov', {})
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = vjabrayilov,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = vjabrayilov,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

        -- Fill every named argument of the call under the cursor: foo(name=, age=)
        vim.keymap.set("i", "<C-s>a", function()
            local params = vim.lsp.util.make_position_params(0, "utf-16")
            local res = vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", params, 1000)
            for _, r in pairs(res or {}) do
                local sig = r.result and r.result.signatures and r.result.signatures[1]
                if sig then
                    local parts = {}
                    for _, p in ipairs(sig.parameters or {}) do
                        local text = type(p.label) == "table"
                            and sig.label:sub(p.label[1] + 1, p.label[2])
                            or p.label
                        local name = text:match("^([%w_]+)")
                        if name then
                            table.insert(parts, string.format("%s=${%d:}", name, #parts + 1))
                        end
                    end
                    if #parts > 0 then
                        require("luasnip").lsp_expand(table.concat(parts, ", ") .. "$0")
                    end
                    return
                end
            end
        end, opts)

        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
