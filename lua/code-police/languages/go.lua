return {
	func_query = [[
		(function_declaration) @func_header
		(method_declaration) @func_header
		(func_literal) @func_header
	]],
	body_types = { "block" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"expression_switch_statement",
		"type_switch_statement",
		"select_statement",
		"communication_case",
	},
	complexity_query = [[
		(if_statement) @rule_if
		(for_statement) @rule_loop
		(expression_switch_statement) @rule_switch
		(type_switch_statement) @rule_switch
		(select_statement) @rule_switch
		
		;; Captures 'recover()' calls to simulate try/catch complexity
		((call_expression 
			function: (identifier) @__name 
			(#eq? @__name "recover")) @rule_try)

		;; Optional: Penalize spawning goroutines as they add async complexity
		(go_statement) @rule_switch 
	]],
}
