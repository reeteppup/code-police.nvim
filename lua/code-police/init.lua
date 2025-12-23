local M = {}
local buf_write_post = require("code-police.events.buf_write_post")
local buf_read_post = require("code-police.events.buf_read_post")

function M.setup(opts)
	vim.api.nvim_set_hl(0, "CodePoliceError", { fg = "#FF0000" })
	vim.api.nvim_set_hl(0, "CodePoliceWarn", { fg = "#FFA500" })
	vim.api.nvim_set_hl(0, "CodePoliceOk", { fg = "#00FF00" })
	M.ns_id = vim.api.nvim_create_namespace("CodePolice")
	local group = vim.api.nvim_create_augroup("CodePolice", { clear = true })

	buf_write_post.setup(group, M.ns_id)
	buf_read_post.setup(group, M.ns_id)
end

return M
