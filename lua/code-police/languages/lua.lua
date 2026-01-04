return {
	func_query = [[
        (function_declaration parameters: (parameters) @func_header)
        (function_definition parameters: (parameters) @func_header)
    ]],
	body_types = { "block" },

	nesting_list = {
		"if_statement",
		"for_statement",
		"while_statement",
		"repeat_statement",
	},
	complexity_query = [[
        (if_statement) @rule_if
        (elseif_statement) @rule_if
        (for_statement) @rule_loop
        (while_statement) @rule_loop
        (repeat_statement) @rule_loop
        ; Lua uses pcall/xpcall instead of try-catch
        ; We match the function call name to reward safety
        ((function_call 
            name: (identifier) @__name 
            (#any-of? @__name "pcall" "xpcall")) @rule_try)
    ]],
}
