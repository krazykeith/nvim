return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      tfvars = { "terraform_fmt" },
      -- TypeScript and JavaScript files now use Biome
      typescript = { "biome" },
      javascript = { "biome" },
      typescriptreact = { "biome" },
      javascriptreact = { "biome" },
      json = { "biome" },
      css = { "biome" },
      scss = { "biome" },
      html = { "biome" },
      markdown = { "biome" },
    },
    -- Respect project-local formatter settings
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 500, lsp_fallback = true }
    end,
    formatters = {
      terraform_fmt = {
        command = vim.fn.expand("~/.local/share/nvim/mason/bin/terraform"),
        args = { "fmt", "-" },
        stdin = true,
      },
      biome = {
        command = vim.fn.expand("~/.local/share/nvim/mason/bin/biome"),
        args = function()
          -- Use the actual file path to ensure biome finds project config
          local file_path = vim.api.nvim_buf_get_name(0)
          return { "format", "--stdin-file-path", file_path }
        end,
        stdin = true,
        cwd = function()
          -- Ensure biome runs from the project root to find config files
          local config_files = { "biome.json", "biome.jsonc", ".biome.json", "package.json" }
          for _, name in ipairs(config_files) do
            local found = vim.fn.findfile(name, ".;")
            if found ~= "" then
              return vim.fn.fnamemodify(found, ":h")
            end
          end
          return vim.fn.getcwd()
        end,
      },
    },
  },
}
