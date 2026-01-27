local M = {}
local general = require("code-police.languages.general")

local cache = {
	queries = {},
	mappings = {},
}

local function get_status(complexityCount)
	if complexityCount > 20 then
		return "■ refactor this bs", "CodePoliceError"
	elseif complexityCount > 10 then
		return "■ common you can do better", "CodePoliceWarn"
	else
		return "■ you doing well!", "CodePoliceOk"
	end
end

local function get_nesting_depth(node, root_node, mapping)
	local depth = 0
	local current = node:parent()
	local nesting_set = mapping.nesting_set -- Use pre-calculated set

	while current and current:id() ~= root_node:id() do
		if nesting_set[current:type()] then
			depth = depth + 1
		end
		current = current:parent()
	end
	return depth
end

local function get_rule_points(capture_name, captured_node, sibling, mapping)
	local points = 0
	if capture_name == "rule_if" then
		points = 1
	elseif capture_name == "rule_loop" then
		points = 2
	elseif capture_name == "rule_switch" then
		points = 1
	elseif capture_name == "rule_try" then
		points = -2
	end

	local depth = get_nesting_depth(captured_node, sibling, mapping)

	if depth > 0 then
		points = points + 2
		points = points + math.floor(depth ^ depth)
	end

	return points
end

local function get_body_node(node, mapping)
	local body_set = mapping.body_set

	local child_count = node:named_child_count()
	for i = 0, child_count - 1 do
		local child = node:named_child(i)
		if body_set[child:type()] then
			return child
		end
	end

	local current_sibling = node:next_named_sibling()
	while current_sibling do
		if body_set[current_sibling:type()] then
			return current_sibling
		end
		current_sibling = current_sibling:next_named_sibling()
	end

	return nil
end

local function get_complexity_count(node, complexity_query, mapping)
	local complexityCount = 0
	local body_node = get_body_node(node, mapping)

	if not body_node then
		return 0
	end

	local start_row, _, end_row, _ = body_node:range()
	local total_lines = end_row - start_row

	if total_lines > 0 then
		complexityCount = complexityCount + math.floor(total_lines / 10)
	end

	for id, captured_node, _ in complexity_query:iter_captures(body_node, 0, 0, -1) do
		local capture_name = complexity_query.captures[id]
		complexityCount = complexityCount + get_rule_points(capture_name, captured_node, body_node, mapping)
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

local function list_to_set(list)
	local set = {}
	for _, v in ipairs(list or {}) do
		set[v] = true
	end
	return set
end

local function get_or_load_mapping(ft)
	if cache.mappings[ft] then
		return cache.mappings[ft]
	end

	local status, mapping = pcall(require, "code-police.languages." .. ft)
	if not status then
		return nil
	end

	mapping.nesting_set = list_to_set(mapping.nesting_list)
	mapping.body_set = list_to_set(mapping.body_types)

	cache.mappings[ft] = mapping
	return mapping
end

local function get_or_create_queries(ft, mapping)
	if cache.queries[ft] then
		return cache.queries[ft].func, cache.queries[ft].cpx
	end

	local status_func, func_query = pcall(vim.treesitter.query.parse, ft, mapping.func_query)
	local status_cpx, cpx_query = pcall(vim.treesitter.query.parse, ft, mapping.complexity_query)

	if not status_func or not status_cpx then
		return nil, nil
	end

	cache.queries[ft] = { func = func_query, cpx = cpx_query }
	return func_query, cpx_query
end

local function check(ns_id, ft, mapping)
	-- Fetch from Cache
	local func_query, complexity_query = get_or_create_queries(ft, mapping)
	if not func_query then
		return
	end

	local parser = vim.treesitter.get_parser(0, ft)
	local tree = parser:parse()[1]
	local root = tree:root()

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
	local mapping = get_or_load_mapping(ft)

	if mapping then
		check(ns_id, ft, mapping)
	end
end

return M
