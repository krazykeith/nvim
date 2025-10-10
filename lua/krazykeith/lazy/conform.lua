return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      terraform = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      tfvars = { "terraform_fmt" },
    },
    formatters = {
      terraform_fmt = {
        command = vim.fn.expand("~/.local/share/nvim/mason/bin/terraform"),
        args = { "fmt", "-" },
        stdin = true,
      },
    },
  },
}
