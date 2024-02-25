local jdtls_dir = vim.fn.stdpath("data") .. "/mason/share/jdtls"
local config_dir = jdtls_dir .. "/config"
local plugins_dir = jdtls_dir .. "/plugins/"
local path_to_jar = plugins_dir .. "org.eclipse.equinox.launcher_1.6.700.v20231214-2017.jar"
local path_lombok_jar = jdtls_dir .. "/lombok.jar"

local java_dap_dir = vim.fn.stdpath('data') .. '/mason/share/java-debug-adapter'
local java_test_dir = vim.fn.stdpath('data') .. '/mason/share/java-test'

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }

local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
	return
end

-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
os.execute("mkdir -p " .. workspace_dir)

local bundles = {
  vim.fn.glob(java_dap_dir .. 'com.microsoft.java.debug.plugin-*.jar', true)
}
vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_dir .. '*.jar', true), "\n"))

local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {

		"java",
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
			maven = { downloadSources = true },
			implentationCodeLens = { enabled = true },
			refreshUris = { enabled = true },
			references = { includeDecompressedSources = true },
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
			},
			flags = { allow_incremental_sync = true },
			init_options = { bundles = bundles },
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-17",
						path = "/Users/julicekim/.sdkman/candidates/java/17.0.5-zulu",
					},
				},
			},
		},
	},
}

config["on_attach"] = require('user.lsp.handlers').on_attach
config["capabilities"] = require('user.lsp.handlers').capabilities

require("jdtls").start_or_attach(config)
require("jdtls").setup_dap({hotcodereplace = "auto"})
require('dap.ext.vscode').load_launchjs()
