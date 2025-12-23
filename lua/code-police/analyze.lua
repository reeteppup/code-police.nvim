local M = {}

local general = require("code-police.languages.general")

function M.run(ns_id)
	general.check()

	local ft = vim.bo.filetype

	local status, lang_module = pcall(require, "code-police.languages." .. ft)

	if status then
		lang_module.check(ns_id)
	else
	end
end

return M
