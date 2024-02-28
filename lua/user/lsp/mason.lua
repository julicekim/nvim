local servers = {
	"lua_ls",
	"pyright",
	"jsonls",
	"gopls",
	"svelte",
	"erlangls",
	"tsserver",
	"jdtls",
	-- "bashls",
	-- "cssls",
	-- "html",
	-- "yamlls",
}

local settings = {
	ui = {
		border = "none",
		icons = {
			package_installed = "",
			package_pending = "◍",
			package_uninstalled = "󱧗",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})

local neodev_ok, neodev = pcall(require, "neodev")
if not neodev_ok then
	return
end

neodev.setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	server = vim.split(server, "@")[1]

	local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	if server ~= "jdtls" then
		lspconfig[server].setup(opts)
	end

end
