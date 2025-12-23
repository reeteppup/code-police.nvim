local M = {}

function M.check()
	local lines = vim.api.nvim_buf_line_count(0)
	if lines > 1000 then
		vim.notify("File is huge!", vim.log.levels.WARN)
	end
end

return M
