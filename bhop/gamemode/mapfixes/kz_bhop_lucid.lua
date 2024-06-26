local te = {
Vector(-1455, 1336, 160),
Vector(-1104, 1431, 164)
}

local cr = {
Vector(-1539, 1336, 192),
Vector(-976, 1431, 277)
}

local fake = {
	Vector(408,2192,-32),
	Vector(1368,2672,-16)
}

local rem = Vector(-1248, 1384.01001, 268)
local rem2 = Vector(880, 2432, 100)

HOOKS["InitPostEntity"] = function()
	local target = nil
	local target2 = nil
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(v:GetPos() == rem) then
			v:Remove()
			target = ents.FindByName(v:GetSaveTable().target)[1]			
		elseif(v:GetPos() == rem2) then
			v:Remove()
			target2 = ents.FindByName(v:GetSaveTable().target)[1]
		end
	end
			
	local a = ents.Create("crouch_fix")
	a:SetPos((cr[1]+cr[2])/2)
	a.min = cr[1]
	a.max = cr[2]
	a.targetpos = target:GetPos()
	a.targetang = target:GetAngles()
	a:Spawn()
	
	local f = ents.Create("fake_tele")
	f:SetPos((te[1]+te[2])/2)
	f.min = te[1]
	f.max = te[2]
	f.targetpos = target:GetPos()
	f.targetang = target:GetAngles()
	f:Spawn()
	
	f = nil
	f = ents.Create("fake_tele")
	f:SetPos((fake[1]+fake[2])/2)
	f.min = fake[1]
	f.max = fake[2]
	f.targetpos = target2:GetPos()
	f.targetang = target2:GetAngles()
	f:Spawn()
end