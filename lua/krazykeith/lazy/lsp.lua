return {
  "neovim/nvim-lspconfig",
  -- opts = {
  --   servers = {
  --     terraformls = {},
  --   },
  -- },
  dependencies = {
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

    -- Fix LSP log size issue and enable file watching
    vim.lsp.set_log_level("ERROR") -- Reduce logging to only errors
    vim.lsp.set_log_level = function() end -- Disable log level changes
    
    -- Enable file watching for LSP clients
    vim.lsp.buf.document_highlight = function() end
    vim.lsp.buf.clear_references = function() end

    require("fidget").setup({})

    -- Note: Using require('lspconfig') shows deprecation warning but is still functional
    -- The new vim.lsp.config API is not yet fully stable for all use cases
    local lspconfig = require("lspconfig")

    lspconfig.zls.setup({
      root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
      settings = {
        zls = {
          enable_inlay_hints = true,
          enable_snippets = true,
          warn_style = true,
        },
      },
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        vim.notify("ZLS LSP client attached", vim.log.levels.INFO)
        -- Enable file watching
        if client.server_capabilities.workspace then
          client.server_capabilities.workspace.didChangeWatchedFiles = {
            dynamicRegistration = true,
          }
        end
      end,
    })

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "Lua 5.1" },
          diagnostics = {
            globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
          },
        },
      },
      on_attach = function(client, bufnr)
        vim.notify("Lua LSP client attached", vim.log.levels.INFO)
      end,
    })

    lspconfig.terraformls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        vim.notify("Terraform LSP client attached", vim.log.levels.INFO)
      end,
    })

    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        vim.notify("TypeScript LSP client attached", vim.log.levels.INFO)
        -- Enable file watching for TypeScript LSP
        if client.server_capabilities.workspace then
          client.server_capabilities.workspace.didChangeWatchedFiles = {
            dynamicRegistration = true,
          }
        end
      end,
      on_exit = function(code, signal, client_id)
        vim.notify("TypeScript LSP client exited with code " .. code .. " and signal " .. signal, vim.log.levels.WARN)
      end,
      on_error = function(err, client_id, bufnr)
        vim.notify("TypeScript LSP error: " .. vim.inspect(err), vim.log.levels.ERROR)
      end,
      settings = {
        typescript = {
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
        },
        javascript = {
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
        },
      },
      -- Add timeout and retry settings
      timeout_ms = 10000,
      single_file_support = true,
      -- Enable file watching
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<S-Tab>'] = cmp.mapping.select_next_item(cmp_select),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
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

    -- Simple LSP status monitoring
    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("LspStatus", {}),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          vim.notify("LSP client " .. client.name .. " detached", vim.log.levels.WARN)
          
          -- Auto-restart TypeScript LSP if it detaches
          if client.name == "ts_ls" then
            vim.defer_fn(function()
              vim.notify("Attempting to restart TypeScript LSP...", vim.log.levels.INFO)
              lspconfig.ts_ls.setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                  vim.notify("TypeScript LSP client reattached", vim.log.levels.INFO)
                end,
                settings = {
                  typescript = {
                    preferences = {
                      includePackageJsonAutoImports = "auto",
                    },
                  },
                  javascript = {
                    preferences = {
                      includePackageJsonAutoImports = "auto",
                    },
                  },
                },
                timeout_ms = 10000,
                single_file_support = true,
              })
            end, 1000) -- Wait 1 second before restarting
          end
        end
      end,
    })
    
    -- Add command to manually restart LSP servers
    vim.api.nvim_create_user_command("LspRestartTS", function()
      vim.notify("Restarting TypeScript LSP...", vim.log.levels.INFO)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.notify("TypeScript LSP client restarted", vim.log.levels.INFO)
        end,
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
          javascript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
        },
        timeout_ms = 10000,
        single_file_support = true,
      })
    end, { desc = "Restart TypeScript LSP server" })
    
    -- Enable file watching globally for all LSP clients
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("LspFileWatching", {}),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.workspace then
          client.server_capabilities.workspace.didChangeWatchedFiles = {
            dynamicRegistration = true,
          }
          vim.notify("File watching enabled for " .. client.name, vim.log.levels.INFO)
        end
      end,
    })
  end
}
