local chat_ok, copilotChat = pcall(require, "CopilotChat")
if not chat_ok then
	return
end

print("initialize copilot chat....")

copilotChat.setup({})
