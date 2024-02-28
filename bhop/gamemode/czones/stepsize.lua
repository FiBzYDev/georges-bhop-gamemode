ZONE.ID = 2

ZONE.Name = "Step Size Zone"

ZONE.Init = function(self)
	self.size = tonumber(self.data)
end

ZONE.PlayerStartTouch = function(self,ply)
	ply:SetStepSize(self.size)
end

ZONE.PlayerEndTouch = function(self,ply)
	ply:SetStepSize(18)
end