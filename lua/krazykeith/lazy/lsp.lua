return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
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
    
    -- Configure LSP logging to reduce verbosity
    vim.lsp.set_log_level("off") -- Disable LSP logging completely
    
    -- Mason setup for LSP server management
    require("mason").setup({
      ensure_installed = {
        "prettier",
        "tflint",
        "terraform-ls"
      },
    })
    
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "zls",
        "terraformls",
        "ts_ls",
        "eslint",
      },
      automatic_installation = true,
      handlers = {
        -- Default handler for all servers
        function(server_name)
          -- Use the new vim.lsp.config API
          vim.lsp.config(server_name)
        end,
      },
    })

    -- Explicit LSP server configurations using new API
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "Lua 5.1" },
          diagnostics = {
            globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
          },
        },
      },
    })

    vim.lsp.config("ts_ls", {
      capabilities = capabilities,
      settings = {
        typescript = {
          tsserver = {
            maxTsServerMemory = 8192,
          },
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
        },
        javascript = {
          tsserver = {
            maxTsServerMemory = 8192,
          },
          preferences = {
            includePackageJsonAutoImports = "auto",
          },
        },
      },
      on_attach = function(client, bufnr)
        -- Enable formatting for TypeScript files
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = true
      end,
    })

    vim.lsp.config("zls", {
      root_dir = function()
        return vim.fn.finddir(".git", ".;") or vim.fn.findfile("build.zig", ".;") or vim.fn.findfile("zls.json", ".;")
      end,
      settings = {
        zls = {
          enable_inlay_hints = true,
          enable_snippets = true,
          warn_style = true,
        },
      },
      capabilities = capabilities,
    })

    -- Terraform LSP configuration
    vim.lsp.config("terraformls", {
      capabilities = capabilities,
      cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/terraform-ls"), "serve" }, -- Use Mason-installed terraform-ls
      settings = {
        terraform = {
          path = vim.fn.expand("~/.local/share/nvim/mason/bin/terraform"), -- Use Mason-installed terraform
        },
        terraformls = {
          experimentalFeatures = {
            validateOnSave = true,
          },
          -- Reduce logging verbosity
          logLevel = "error", -- Only log errors, not info/debug messages
        },
      },
      on_attach = function(client, bufnr)
        -- Enable formatting for Terraform files
        client.server_capabilities.documentFormattingProvider = true
        client.server_capabilities.documentRangeFormattingProvider = true
      end,
      -- Only start in terraform project directories
      root_dir = function(fname)
        local util = require('lspconfig.util')
        -- Convert fname to string if it's a number (buffer number)
        local filename = type(fname) == 'number' and vim.api.nvim_buf_get_name(fname) or fname
        return util.root_pattern('.terraform', '*.tf', '*.hcl')(filename) or util.find_git_ancestor(filename)
      end,
      -- Only start for terraform files
      filetypes = { "terraform", "tf", "hcl" },
    })

    -- ESLint configuration with better error handling
    vim.lsp.config("eslint", {
      capabilities = capabilities,
      settings = {
        codeActionOnSave = {
          enable = true,
          mode = "all",
        },
        format = false, -- Disable ESLint formatting in favor of conform.nvim
      },
      on_attach = function(client, bufnr)
        -- Disable ESLint formatting capabilities
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
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
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
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
