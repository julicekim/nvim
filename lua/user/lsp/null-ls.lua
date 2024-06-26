local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = true,
  sources = {
    formatting.prettier.with({ extra_args = {"--single-quote", "--jsx-single-quote" } }),
    formatting.black.with({ extra_args = { "--fast" } }),
    formatting.google_java_format,
    formatting.stylua,
    diagnostics.golangci_lint,
    require("none-ls.diagnostics.eslint"),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group=augroup,
        buffer=bufnr,
        callback = function() 
          vim.lsp.buf.format({bufnr=bufnr})
        end,
      })
    end
  end
})
