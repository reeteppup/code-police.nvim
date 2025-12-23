local M = {}

local func_query_string = [[
  (method_signature) @func_header
  (function_signature) @func_header
]]

local complexity_query_string = [[
  (if_statement) @rule_if
  (for_statement) @rule_loop
  (while_statement) @rule_loop
  (switch_statement) @rule_switch
  (try_statement) @rule_try
]]

local function get_status(complexityCount)
	if complexityCount > 20 then
		return "■", "CodePoliceError"
	elseif complexityCount > 10 then
		return "■", "CodePoliceWarn"
	else
		return "■", "CodePoliceOk"
	end
end

local function get_nesting_depth(node, root_node)
	local depth = 0
	local current = node:parent()

	while current and current:id() ~= root_node:id() do
		local type = current:type()
		if
			type == "if_statement"
			or type == "for_statement"
			or type == "while_statement"
			or type == "switch_statement"
		then
			depth = depth + 1
		end
		current = current:parent()
	end
	return depth
end

local function get_rule_points(capture_name, captured_node, sibling)
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

	local depth = get_nesting_depth(captured_node, sibling)

	if depth > 0 then
		points = points + 2

		points = points + math.floor(depth ^ depth)
	end

	return points
end

local function get_complexity_count(node, complexity_query)
	local type = node:type()
	local complexityCount = 0

	if type ~= "method_signature" and type ~= "function_signature" then
		return 0
	end

	local sibling = node:next_named_sibling()

	if sibling == nil then
		return 0
	end

	local sib_type = sibling:type()
	if sib_type ~= "function_body" and sib_type ~= "block" then
		return 0
	end

	local start_row, _, end_row, _ = sibling:range()
	local total_lines = end_row - start_row
	complexityCount = complexityCount + math.floor(total_lines / 10)

	for id, captured_node, _ in complexity_query:iter_captures(sibling, 0, 0, -1) do
		local capture_name = complexity_query.captures[id]

		complexityCount = complexityCount + get_rule_points(capture_name, captured_node, sibling)
	end

	return complexityCount
end

local function analyze_node(node, ns_id, complexity_query)
	local start_row, _, _, _ = node:range()

	local complexityCount = get_complexity_count(node, complexity_query)

	local text, highlight_group = get_status(complexityCount)

	vim.api.nvim_buf_set_extmark(0, ns_id, start_row, 0, {
		virt_text = { { text, highlight_group } },
		virt_text_pos = "eol",
	})
end

function M.check(ns_id)
	local parser = vim.treesitter.get_parser(0, "dart")
	local tree = parser:parse()[1]
	local root = tree:root()

	local status_func, func_query = pcall(vim.treesitter.query.parse, "dart", func_query_string)
	local status_cpx, complexity_query = pcall(vim.treesitter.query.parse, "dart", complexity_query_string)

	if not status_func or not status_cpx then
		return
	end

	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
	local seen_lines = {}
	for _, node, _ in func_query:iter_captures(root, 0, 0, -1) do
		local start_row, _, _, _ = node:range()
		if not seen_lines[start_row] then
			analyze_node(node, ns_id, complexity_query)
			seen_lines[start_row] = true
		end
	end
end

return M
