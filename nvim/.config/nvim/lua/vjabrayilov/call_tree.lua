-- Fully expanded call trees in a Snacks picker.
-- The built-in lsp_incoming_calls/lsp_outgoing_calls pickers only list one level;
-- these keep asking the server for callers of callers (or callees of callees)
-- until they reach the ends of the call graph.

local M = {}

local function key(item)
    return item.uri .. ":" .. item.selectionRange.start.line .. ":" .. item.name
end

-- Returns the callers (incoming) or callees (outgoing) of `item` as
-- CallHierarchyItems whose `children` are the next level. A function is expanded
-- only once, which also breaks recursion cycles.
---@async
local function expand(lsp, client, item, depth, opts, expanded)
    if depth >= opts.max_depth then
        return {}
    end
    local method = ("callHierarchy/%sCalls"):format(opts.incoming and "incoming" or "outgoing")
    local calls = {}
    lsp.request(client, method, function()
        return { item = item }
    end, function(_, result)
        calls = result
    end)

    local nodes = {}
    for _, call in ipairs(calls) do
        local target = opts.incoming and call.from or call.to
        local node = vim.deepcopy(target)
        -- for callers, jump to the call site; fromRanges of outgoing calls are in
        -- the parent's file, so callees keep their definition range
        if opts.incoming then
            node.selectionRange = call.fromRanges[1] or node.selectionRange
        end
        if not expanded[key(target)] then
            expanded[key(target)] = true
            node.children = expand(lsp, client, target, depth + 1, opts, expanded)
        end
        nodes[#nodes + 1] = node
    end
    return nodes
end

---@type snacks.picker.finder
local function finder(opts, ctx)
    local lsp = require("snacks.picker.source.lsp")
    local buf, win = ctx.filter.current_buf, ctx.filter.current_win
    ctx.picker.matcher.opts.keep_parents = true

    return function(cb)
        local roots = {}
        lsp.request(buf, "textDocument/prepareCallHierarchy", function(client)
            return vim.lsp.util.make_position_params(win, client.offset_encoding)
        end, function(client, result)
            for _, item in ipairs(result or {}) do
                roots[#roots + 1] = { client = client, item = item }
            end
        end)

        for _, root in ipairs(roots) do
            local expanded = { [key(root.item)] = true }
            root.item.children = expand(lsp, root.client, root.item, 0, opts, expanded)
            for _, item in ipairs(lsp.results_to_items(root.client, { root.item })) do
                item.tree = true
                cb(item)
            end
        end
    end
end

local function format(item, picker)
    local ret = Snacks.picker.format.tree(item, picker)
    vim.list_extend(ret, Snacks.picker.format.lsp_symbol(item, picker))
    return ret
end

local function pick(defaults, opts)
    Snacks.picker.pick(vim.tbl_extend("force", {
        finder = finder,
        format = format,
        max_depth = 5,
        workspace = true, -- makes lsp_symbol show the file of each node
        jump = { tagstack = true, reuse_win = true },
    }, defaults, opts or {}))
end

function M.incoming(opts)
    pick({ title = "Incoming Call Tree", incoming = true }, opts)
end

function M.outgoing(opts)
    pick({ title = "Outgoing Call Tree", incoming = false }, opts)
end

return M
