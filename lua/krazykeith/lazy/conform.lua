return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      tfvars = { "terraform_fmt" },
      -- Let TypeScript files use LSP formatting instead of conform
      -- typescript = { "prettier" },
      -- javascript = { "prettier" },
      -- typescriptreact = { "prettier" },
      -- javascriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
    },
    formatters = {
      terraform_fmt = {
        command = vim.fn.expand("~/.local/share/nvim/mason/bin/terraform"),
        args = { "fmt", "-" },
        stdin = true,
      },
      prettier = {
        command = vim.fn.expand("~/.local/share/nvim/mason/bin/prettier"),
        args = { "--stdin-filepath", vim.fn.expand("%") },
        stdin = true,
      },
    },
  },
}
