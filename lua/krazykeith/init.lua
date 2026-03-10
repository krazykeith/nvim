require("krazykeith.set")
require("krazykeith.remap")
require("krazykeith.lazy_init")

local augroup = vim.api.nvim_create_augroup
local KrazyKeithGroup = augroup('KrazyKeith', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

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

autocmd({ "BufWritePre" }, {
    group = KrazyKeithGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = KrazyKeithGroup,
    callback = function(e)
        local opts = { buffer = e.buf }

        vim.keymap.set("n", "gd", function()
            local clients = vim.lsp.get_clients({ bufnr = e.buf })
            if #clients == 0 then
                vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
                return
            end

            local has_definition = false
            for _, c in ipairs(clients) do
                if c.server_capabilities.definitionProvider then
                    has_definition = true
                    break
                end
            end

            if has_definition then
                vim.lsp.buf.definition()
            else
                vim.notify("LSP: No definition provider available", vim.log.levels.WARN)
            end
        end, opts)

        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)

        vim.keymap.set("n", "<leader>ls", function()
            local clients = vim.lsp.get_clients({ bufnr = e.buf })
            if #clients == 0 then
                vim.notify("No LSP clients attached to this buffer", vim.log.levels.WARN)
            else
                local client_names = {}
                for _, c in ipairs(clients) do
                    table.insert(client_names, c.name)
                end
                vim.notify("LSP clients: " .. table.concat(client_names, ", "), vim.log.levels.INFO)
            end
        end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Global K keybinding that works with or without LSP
vim.keymap.set("n", "K", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        -- LSP is available, use hover
        local has_hover = false
        for _, client in ipairs(clients) do
            if client.server_capabilities.hoverProvider then
                has_hover = true
                break
            end
        end
        
        if has_hover then
            vim.lsp.buf.hover()
        else
            vim.notify("LSP: No hover provider available", vim.log.levels.WARN)
        end
    else
        -- No LSP, fall back to help
        vim.cmd("help " .. vim.fn.expand("<cword>"))
    end
end, { desc = "LSP hover or help" })

-- Format keybinding - uses conform.nvim when configured, LSP otherwise
vim.keymap.set("n", "<leader>f", function()
    local conform = require("conform")
    local formatters = conform.list_formatters()
    if #formatters > 0 then
        conform.format({ async = false })
    else
        vim.lsp.buf.format({ async = false })
    end
end, { desc = "Format code" })


-- Ensure OpenTofu files are recognized as Terraform files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.tf", "*.tfvars" },
    callback = function()
        vim.bo.filetype = "terraform"
    end,
})
