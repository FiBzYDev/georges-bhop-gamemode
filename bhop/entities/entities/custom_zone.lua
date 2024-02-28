AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ZoneType" )
end

if SERVER then
	function ENT:Initialize()  
		self:SetSolid(SOLID_BBOX)
		
		local bbox = (self.max-self.min)/2
	
		self:PhysicsInitBox(-bbox, bbox)
		self:SetCollisionBoundsWS(self.min,self.max)
	
		self:SetTrigger(true)
		self:DrawShadow(false)
		self:SetNotSolid(true)
		self:SetNoDraw(false)
	
		self.Phys = self:GetPhysicsObject()
		if(self.Phys and self.Phys:IsValid()) then
			self.Phys:Sleep()
			self.Phys:EnableCollisions(false)
		end 
		 //Set the positions according to the world 
		self:SetZoneType(self.ztype)
		if(gtimer.customz && gtimer.customz[self.ztype]) then
			if(gtimer.customz[self.ztype].PlayerStartTouch) then
				self.stf = gtimer.customz[self.ztype].PlayerStartTouch
			end
			if(gtimer.customz[self.ztype].PlayerEndTouch) then
				self.etf = gtimer.customz[self.ztype].PlayerEndTouch
			end
			if(gtimer.customz[self.ztype].Init) then
				gtimer.customz[self.ztype].Init(self)
			end
		end
	end

	function ENT:StartTouch(ent)  
		if(self.stf && ent && ent:IsValid() && ent:IsPlayer() && !ent:IsBot()) then
			self.stf(self,ent)
		end
	end

	function ENT:EndTouch(ent)  
		if(self.etf && ent && ent:IsValid() && ent:IsPlayer() && !ent:IsBot()) then
			self.etf(self,ent)
		end
	end
else
	local Laser = Material("sprites/trails/bluelightning")
	
	
	function ENT:Initialize()
	end 

	function ENT:Think() 
		local Min, Max = self:GetCollisionBounds()
		self:SetRenderBounds(Min, Max) 
	end 
	
	local cachef = nil
	local cached = false

	function ENT:Draw()
		if(cached && !cachef) then return end
		if(cachef) then cachef(self) end
		if(!cached) then
			if(gtimer.customz && gtimer.customz[self:GetZoneType()] && gtimer.customz[self:GetZoneType()].Draw) then
				cachef = gtimer.customz[self:GetZoneType()].Draw
				cachef(self)
			end
			cached = true
		end
	end
end