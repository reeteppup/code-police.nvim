return {
	func_query = [[
		(method_signature) @func_header
		(function_signature) @func_header
		(constructor_signature) @func_header -- Critical for Flutter
		(getter_signature) @func_header
		(setter_signature) @func_header
	]],
	body_types = { "function_body", "block" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"while_statement",
		"do_statement",
		"switch_statement",
		"try_statement",
		"catch_clause",
	},
	complexity_query = [[
		(if_statement) @rule_if
		(for_statement) @rule_loop
		(while_statement) @rule_loop
		(do_statement) @rule_loop 
		(switch_statement) @rule_switch
		(try_statement) @rule_try
		(catch_clause) @rule_if 
	]],
}
