return {
	func_query = [[
        (function_declaration) @func_header
        (function_expression) @func_header
        (arrow_function) @func_header
        (method_definition) @func_header
        (class_declaration) @func_header
    ]],
	body_types = { "statement_block", "class_body" },
	nesting_list = {
		"if_statement",
		"for_statement",
		"for_in_statement",
		"while_statement",
		"do_statement",
		"switch_statement",
		"try_statement",
		"catch_clause",
	},
	complexity_query = [[
        (if_statement) @rule_if
        (for_statement) @rule_loop
        (for_in_statement) @rule_loop
        (while_statement) @rule_loop
        (do_statement) @rule_loop
        (switch_statement) @rule_switch
        (try_statement) @rule_try
        (catch_clause) @rule_if
    ]],
}
