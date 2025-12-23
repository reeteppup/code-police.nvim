local M = {}
local analyze = require("code-police.analyze")

function M.setup(group, ns_id)
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = group,
		pattern = "*",
		callback = function()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(0) then
					analyze.run(ns_id)
				end
			end)
		end,
	})
end

return M
