local remove = {
	Vector(-4848, -1268, -56),
	Vector(-1680.5, -2324, -84),
	Vector(5320.5, -2736, 20),
	Vector(-4876, 1898, 31),
	Vector(-4156, 1896, 98.72),
	Vector(-4118, -1924, -44)
} --all the beggining to level select tps to stop people getting telehopped like level 4 along with that one dumb trigger that hates the world and a dodgy trigger

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(v:GetPos() == Vector(543.5, -980, -84)) then
			v:SetKeyValue("target","level18")
		end
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end