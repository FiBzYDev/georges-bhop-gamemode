HOOKS["InitPostEntity"] = function()	
	--all the broken spikes are belong to us
	local p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-328, 11992, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-296, 12095, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-655, 12151, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-815, 11920, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-815, 11808, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-911, 11840, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
			
	p = ents.Create("bhop_iblock")
	p:SetPos(Vector(-1071, 11840, 4703))
	p.min = Vector(-2,-2,-1.5)
	p.max = Vector(2,2,1)
	p:Spawn()
end