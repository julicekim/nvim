local jdtls_dir = vim.fn.stdpath("data") .. "/mason/share/jdtls"
local config_dir = jdtls_dir .. "/config"
local plugins_dir = jdtls_dir .. "/plugins/"
local path_to_jar = plugins_dir .. "org.eclipse.equinox.launcher_1.6.700.v20231214-2017.jar"
local path_lombok_jar = jdtls_dir .. "/lombok.jar"

local java_17_home = os.getenv("JAVA_17_HOME")

local java_dap_dir = vim.fn.stdpath("data") .. "/mason/share/java-debug-adapter/"
local java_test_dir = vim.fn.stdpath("data") .. "/mason/share/java-test/"

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
	return
end

-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
os.execute("mkdir -p " .. workspace_dir)

local bundles = {}

vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. "*.jar", true), "\n"))
vim.list_extend(
	bundles,
	vim.split(vim.fn.glob(java_dap_dir .. "com.microsoft.java.debug.plugin-0.51.1.jar", true), "\n")
)

-- for k, v in pairs(bundles) do
-- 	print(k, v)
-- end

local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {

		java_17_home .. "/bin/java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:" .. path_lombok_jar,

		"-jar",
		path_to_jar,
		"-configuration",
		config_dir,
		"-data",
		workspace_dir,
	},
	root_dir = root_dir,
	settings = {
		java = {
			eclipse = { downloadSources = true },
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-17",
						path = java_17_home,
					},
				},
			},
			maven = { downloadSources = true },
			implentationCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
			references = { includeDecompressedSources = true },
			inlayHints = {
				parameterHints = { enabled = true },
			},
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
			},
			importOrder = { "java", "javax", "org", "com" },
			sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
			codeGeneration = {
				toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
				hashCodeEquals = { useInstanceof = true, useJava7Objects = true },
				useBlocks = true,
			},
			flags = { allow_incremental_sync = true },
		},
	},
	init_options = { bundles = bundles },
}

config["on_attach"] = function(client, bufnr)
	require("user.lsp.handlers").on_attach(client, bufnr)

	local _, _ = pcall(vim.lsp.codelens.refresh)
	require("jdtls").setup_dap({ hotcodereplace = "auto" })

	local jdtls_dap_ok, jdtls_dap = pcall(require, "jdtls.dap")
	if jdtls_dap_ok then
		jdtls_dap.setup_dap_main_class_configs({ verbose = true })
	end
end

config["capabilities"] = require("user.lsp.handlers").capabilities

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.java" },
	callback = function()
		local _, _ = pcall(vim.lsp.codelens.refresh)
	end,
})

require("jdtls").start_or_attach(config)
require("dap.ext.vscode").load_launchjs()

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
	mode = "v", -- VISUAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
	C = {
		name = "Java",
		o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
		v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
		c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
		t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
		T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
		u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
	},
}

local vmappings = {
	C = {
		name = "Java",
		v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
		c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
		m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
	},
}

which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(vmappings, vopts)
