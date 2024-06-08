local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = true,
  sources = {
    require("none-ls.code_actions.eslint"),
    formatting.prettier.with({ extra_args = {"--single-quote", "--jsx-single-quote" } }),
    formatting.black.with({ extra_args = { "--fast" } }),
    formatting.google_java_format,
    formatting.stylua,
    diagnostics.golangci_lint,
  },
})
