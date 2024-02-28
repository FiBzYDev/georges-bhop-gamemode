HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
end