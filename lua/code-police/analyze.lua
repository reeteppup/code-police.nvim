local M = {}

local general = require("code-police.languages.general")

local function get_status(complexityCount)
	if complexityCount > 20 then
		return "■", "CodePoliceError"
	elseif complexityCount > 10 then
		return "■", "CodePoliceWarn"
	else
		return "■", "CodePoliceOk"
	end
end

local function get_nesting_depth(node, root_node, mapping)
	local depth = 0
	local current = node:parent()

	while current and current:id() ~= root_node:id() do
		local type = current:type()

		for _, nest_type in ipairs(mapping.nesting_list) do
			if type == nest_type then
				depth = depth + 1
				break
			end
		end

		current = current:parent()
	end
	return depth
end

local function get_rule_points(capture_name, captured_node, sibling, mapping) -- 1. Add mapping here
	local points = 0

	if capture_name == "rule_if" then
		points = 1
	end
	if capture_name == "rule_loop" then
		points = 2
	end
	if capture_name == "rule_switch" then
		points = 1
	end
	if capture_name == "rule_try" then
		points = -2
	end

	local depth = get_nesting_depth(captured_node, sibling, mapping)

	if depth > 0 then
		points = points + 2
		points = points + math.floor(depth ^ depth)
	end

	return points
end

local function get_complexity_count(node, complexity_query, mapping)
	local complexityCount = 0

	local sibling = node:next_named_sibling()

	if sibling == nil then
		return 0
	end

	local sib_type = sibling:type()
	local is_valid_body = false

	for _, type in ipairs(mapping.body_types) do
		if sib_type == type then
			is_valid_body = true
			break
		end
	end

	if not is_valid_body then
		return 0
	end

	local start_row, _, end_row, _ = sibling:range()
	local total_lines = end_row - start_row

	if total_lines > 0 then
		complexityCount = complexityCount + math.floor(total_lines / 10)
	end

	for id, captured_node, _ in complexity_query:iter_captures(sibling, 0, 0, -1) do
		local capture_name = complexity_query.captures[id]

		complexityCount = complexityCount + get_rule_points(capture_name, captured_node, sibling, mapping)
	end

	return complexityCount
end

local function analyze_node(node, ns_id, complexity_query, mapping)
	local start_row, _, _, _ = node:range()

	local complexityCount = get_complexity_count(node, complexity_query, mapping)

	local text, highlight_group = get_status(complexityCount)

	vim.api.nvim_buf_set_extmark(0, ns_id, start_row, 0, {
		virt_text = { { text, highlight_group } },
		virt_text_pos = "eol",
	})
end

local function check(ns_id, ft, mapping)
	local parser = vim.treesitter.get_parser(0, ft)
	local tree = parser:parse()[1]
	local root = tree:root()

	local func_query_string = mapping.func_query
	local complexity_query_string = mapping.complexity_query

	local status_func, func_query = pcall(vim.treesitter.query.parse, ft, func_query_string)
	local status_cpx, complexity_query = pcall(vim.treesitter.query.parse, ft, complexity_query_string)

	if not status_func or not status_cpx then
		return
	end

	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
	local seen_lines = {}
	for _, node, _ in func_query:iter_captures(root, 0, 0, -1) do
		local start_row, _, _, _ = node:range()
		if not seen_lines[start_row] then
			analyze_node(node, ns_id, complexity_query, mapping)
			seen_lines[start_row] = true
		end
	end
end

function M.run(ns_id)
	general.check()

	local ft = vim.bo.filetype
	local status, mapping = pcall(require, "code-police.languages." .. ft)

	if status then
		check(ns_id, ft, mapping)
	else
	end
end

return M
