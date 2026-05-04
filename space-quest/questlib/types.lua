local types = {}

-- operator lookup tables
types.comp_ops = {
	['==']=true, 
	['!=']=true, 
	['<']=true, 
	['>']=true, 
	['<=']=true, 
	['>=']=true
}
types.expr_ops = {
	['+']=true, 
	['-']=true, 
	['*']=true, 
	['/']=true, 
	['%']=true
}
types.assi_ops = {
	['=']=true, 
	['+=']=true, 
	['-=']=true, 
	['*=']=true, 
	['/=']=true
}

-- pattern for variable references
types.var_pattern = '^<[%w_]+>$'

-- check if a string is a variable reference
function types.is_var(s)
	return type(s) == 'string' and s:match(types.var_pattern)
end

-- extract raw key from <var>
function types.unwrap_var(s)
	return s:sub(2, -2)
end

-- infer expression type by structure
function types.get_expr_type(expr)
	if type(expr) ~= 'table' then return 'literal' end
	if expr[1] == '?' then return 'cte' end
	local op = expr[2]
	if types.comp_ops[op] then return 'comp' end
	if types.expr_ops[op] then return 'expr' end
	if types.assi_ops[op] then return 'assi' end
	return 'unknown'
end

return types