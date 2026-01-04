return {
	func_query = [[
		(function_declaration) @func_header
		(function_definition) @func_header
		(local_function_declaration) @func_header 
	]],
	body_types = { "block" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"while_statement",
		"repeat_statement",
		"do_statement",
		"function_definition",
	},
	complexity_query = [[
		(if_statement) @rule_if
		(elseif_statement) @rule_if 
		(for_statement) @rule_loop
		(while_statement) @rule_loop
		(repeat_statement) @rule_loop
		(do_statement) @rule_loop 
		
		;; Pcall/Xpcall Safety Bonus
		((function_call 
			name: (identifier) @__name 
			(#any-of? @__name "pcall" "xpcall")) @rule_try)
	]],
}
