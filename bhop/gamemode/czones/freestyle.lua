ZONE.ID = 1

ZONE.Name = "Freestyle Zone"

ZONE.Init = function(self)
	if(self.data == "hsw") then
		self.hsw = true
	end
end

ZONE.PlayerStartTouch = function(self,ply)
	if(self.hsw && ply.Style > 1 && ply.Style < 5) then
		ply.fs = true
		ply:SendLua("LocalPlayer().fs = true")
		gtimer.SetCheckFS(ply,true)
		ply:SendLua("gtimer.SetCheckFS(LocalPlayer(),true)")
		ply:SendPVar("fs","true")
	elseif(ply.Style > 1 && ply.Style < 4) then
		ply.fs = true
		ply:SendLua("LocalPlayer().fs = true")
		gtimer.SetCheckFS(ply,true)
		ply:SendLua("gtimer.SetCheckFS(LocalPlayer(),true)")
		ply:SendPVar("fs","true")
	end
end

ZONE.PlayerEndTouch = function(self,ply)
	if(ply.fs) then
		ply.fs = false
		ply:SendLua("LocalPlayer().fs = false")
		ply:SendPVar("fs","false")
		gtimer.SetCheckFS(ply,false)
		ply:SendLua("gtimer.SetCheckFS(LocalPlayer(),false)")
	end
end

local Laser = Material("sprites/trails/laser")

ZONE.Draw = function(self)
	local Min, Max = self:GetCollisionBounds()
	Min=self:GetPos()+Min
	Min.z = Min.z + 2
	Max=self:GetPos()+Max

	local Col = Color(50, 50, 200, 255)
	
	local C1, C2, C3, C4, C5, C6, C7, C8 = Vector(Min.x, Min.y, Min.Z), Vector(Min.x, Max.y, Min.Z), Vector(Max.x, Max.y, Min.Z), Vector(Max.x, Min.y, Min.Z), Vector(Min.x, Min.y, Max.Z), Vector(Min.x, Max.y, Max.Z), Vector(Max.x, Max.y, Max.Z), Vector(Max.x, Min.y, Max.Z) 
	
	local w = (Max.y-Min.y)/150
	local l = (Max.x-Min.x)/150
	local h = (Max.z-Min.z)/150
	
	render.SetMaterial(Laser)
	render.DrawBeam(C1, C2, 20, 0, 1*w, Col) 
	render.DrawBeam(C2, C3, 20, 0, 1*l, Col)
	render.DrawBeam(C3, C4, 20, 0, 1*w, Col)
	render.DrawBeam(C4, C1, 20, 0, 1*l, Col)
	render.DrawBeam(C5, C6, 20, 0, 1*w, Col) 
	render.DrawBeam(C6, C7, 20, 0, 1*l, Col)
	render.DrawBeam(C7, C8, 20, 0, 1*w, Col)
	render.DrawBeam(C8, C5, 20, 0, 1*l, Col)
	render.DrawBeam(C1, C5, 20, 0, 1*h, Col) 
	render.DrawBeam(C2, C6, 20, 0, 1*h, Col) 
	render.DrawBeam(C3, C7, 20, 0, 1*h, Col) 
	render.DrawBeam(C4, C8, 20, 0, 1*h, Col) 
end