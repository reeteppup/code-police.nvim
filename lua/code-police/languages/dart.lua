return {
	func_query = [[
        (method_signature) @func_header
        (function_signature) @func_header
    ]],
	body_types = { "function_body", "block" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"while_statement",
		"switch_statement",
	},
	complexity_query = [[
        (if_statement) @rule_if
        (for_statement) @rule_loop
        (while_statement) @rule_loop
        (switch_statement) @rule_switch
        (try_statement) @rule_try
    ]],
}
