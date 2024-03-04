local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
	return
end

-- dap.configurations.java = {
-- 	{
-- 		type = "java",
-- 		request = "attach",
-- 		name = "Debug (Attach) - Remote",
-- 		hostName = "127.0.0.1",
-- 		port = 5005,
-- 	},
-- }

local dapui_ok, dapui = pcall(require, "dapui")
if not dapui_ok then
	return
end

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

local opts = { noremap = true, silent = false }
--
-- -- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- move in debug
keymap('n', '<F5>', ':lua require"dap".continue()<CR>', opts)
keymap('n', '<F8>', ':lua require"dap".step_over()<CR>', opts)
keymap('n', '<F7>', ':lua require"dap".step_into()<CR>', opts)
keymap('n', '<S-F8>', ':lua require"dap".step_out()<CR>', opts)
