return {
	func_query = [[
		(method_declaration) @func_header
		(constructor_declaration) @func_header
		(lambda_expression) @func_header
	]],
	body_types = { "block" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"enhanced_for_statement",
		"while_statement",
		"do_statement",
		"switch_expression",
		"switch_statement",
		"try_statement",
		"try_with_resources_statement",
		"catch_clause",
		"synchronized_statement",
	},
	complexity_query = [[
		(if_statement) @rule_if
		(for_statement) @rule_loop
		(enhanced_for_statement) @rule_loop
		(while_statement) @rule_loop
		(do_statement) @rule_loop
		(switch_expression) @rule_switch
		(switch_statement) @rule_switch
		(try_statement) @rule_try
		(try_with_resources_statement) @rule_try 
		(catch_clause) @rule_if
		(synchronized_statement) @rule_loop 
	]],
}
