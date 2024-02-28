ZONE.ID = 3

ZONE.Name = "Hull Size Zone"

ZONE.Init = function(self)
	self.size = tonumber(self.data)
end

ZONE.PlayerStartTouch = function(self,ply)
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, self.size))
	ply:SendLua("LocalPlayer():SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, "..self.size.."))")
end

ZONE.PlayerEndTouch = function(self,ply)
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))
	ply:SendLua("LocalPlayer():SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))")
end