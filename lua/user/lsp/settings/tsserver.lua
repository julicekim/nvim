local function organize_import()
	local param = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}

	vim.lsp.buf.execute_command(param)
end

return {
	init_options = {
		hostInfo = "neovim",
		preferences = {
			importModuleSpecifierPreference = "relative",
			disableSuggestions = true,
		},
	}
}
