local remove = {
Vector(-912, -2880, 4510),
Vector(5408, -7104, 1480),
}

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
			local target = ents.FindByName(v:GetSaveTable().target)[1]			
			local mi = v:LocalToWorld(v:OBBMins())-Vector(0,0,100)
			local ma = v:LocalToWorld(v:OBBMaxs())
	
			local a = ents.Create("crouch_fix")
			a:SetPos((mi+ma)/2)
			a.min = mi
			a.max = ma
			a.targetpos = target:GetPos()
			a.targetang = target:GetAngles()
			a:Spawn()
		end
	end
end