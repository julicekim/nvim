local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
	return
end

local chat_ok, copilotChat = pcall(require, "CopilotChat")
if not chat_ok then
	return
end

copilotChat.setup({})

dap.configurations.java = {
	{
		type = "java",
		request = "attach",
		name = "Debug (Attach) - Remote",
		hostName = "127.0.0.1",
		port = 5005,
	},
}

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
