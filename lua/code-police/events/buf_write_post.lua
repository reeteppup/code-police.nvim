local M = {}
local analyze = require("code-police.analyze")

function M.setup(group, ns_id)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*",
		callback = function()
			analyze.run(ns_id)
		end,
	})
end

return M
