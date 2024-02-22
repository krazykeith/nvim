vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local KrazyKeith_Fugitive = vim.api.nvim_create_augroup("KrazyKeith_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = KrazyKeith_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>p", function()
            vim.cmd.Git('push')
        end, opts)

        vim.keymap.set("n", "<leader>f", function()
            vim.cmd.Git('push --force-with-lease')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>P", function()
            vim.cmd.Git({'pull',  '--rebase'})
        end, opts)

        -- update curent branch with master NOTE: This is a rebase and a custom command
        vim.keymap.set("n", "<leader>u", function()
            vim.cmd.Git({'update-local'})
        end, opts)

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
    end,
})
