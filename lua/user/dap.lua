local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
	return
end

dap.adapters.java = function(callback, config)
  local handle
  local pid_or_port = config.request
  local port = type(pid_or_port) == 'number' and pid_or_port or 5005
  handle, pid = vim.loop.spawn("java", {
    args = {"-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address="..port, "-jar", config.program},
    detached = true
  }, callback)
  return {process = handle, pid = pid}
end

