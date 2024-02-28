local remove = {
Vector(-3946.5, -4732.5, 459),
Vector(-624.5, 3270, 4428),
}

local fake = {
	Vector(460, 2871, 3837),
	Vector(903, 3405, 3879)
}

local c3 = {
	Vector(461.5,2861,3936),
	Vector(902.5,3232,4049)
}

local c3target = nil

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
		elseif(v:GetPos() == Vector(681.5, 3138, 3941.5)) then
			v:Remove()
			c3target = ents.FindByName(v:GetSaveTable().target)[1]
			local mi = c3[1]
			local ma = c3[2]
			
			local a = ents.Create("crouch_fix")
			a:SetPos((mi+ma)/2)
			a.min = mi
			a.max = ma
			a.targetpos = c3target:GetPos()
			a.targetang = c3target:GetAngles()
			a:Spawn()
		end
	end
	local f = ents.Create("fake_tele")
	f:SetPos((fake[1]+fake[2])/2)
	f.min = fake[1]
	f.max = fake[2]
	f.targetpos = c3target:GetPos()
	f.targetang = c3target:GetAngles()
	f:Spawn()
end