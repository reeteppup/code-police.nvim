return {
	func_query = [[
		(function_item) @func_header
		(closure_expression) @func_header
	]],
	body_types = { "block" },
	nesting_list = {
		"if_expression",
		"for_expression",
		"while_expression",
		"loop_expression",
		"match_expression",
		"match_arm",
	},
	complexity_query = [[
		(if_expression) @rule_if
		(for_expression) @rule_loop
		(while_expression) @rule_loop
		(loop_expression) @rule_loop
		(match_expression) @rule_switch
	]],
}
