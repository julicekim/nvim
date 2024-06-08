
local status_ok, lualine = pcall(require, "ufo")
if not status_ok then
	return
end

require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})
