local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
  auto_instal = true,
	ensure_installed = {
		"bash",
		"c",
		"go",
		"javascript",
		"json",
		"lua",
		"python",
		"typescript",
		"tsx",
		"css",
		"rust",
		"java",
		"yaml",
		"markdown",
		"markdown_inline",
		"html",
		"svelte",
	}, -- one of "all" or a list of languages
	ignore_install = { "vimdoc", "phpdoc" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "css" }, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = {
		enable = true,
		disable = {
			"python",
			"css",
		},
	},
})

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
