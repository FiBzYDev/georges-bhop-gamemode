AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ZoneType" )
	self:NetworkVar( "Bool", 0, "Bonus" )
end

if SERVER then
	function ENT:Initialize()  
		self:SetSolid(SOLID_BBOX)
		
		local bbox = (self.max-self.min)/2
		self.pos = (self.min+self.max)/2
	
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
		if(self.bonus) then
			self:SetBonus(true)
		else
			self:SetBonus(false)
		end
	end

	function ENT:StartTouch(ent)  
		if(ent && ent:IsValid() && ent:IsPlayer() && !ent:IsBot()) then
			if(self:GetZoneType() == 1) then
				if(ent:GetMoveType() == MOVETYPE_WALK) then
					ent:SetMoveType(MOVETYPE_WALK)
					ent:SetLocalVelocity(Vector(0,0,30))
					ent:SetPos(self.pos)
				end
				ent.InSpawn = true
				if(self:GetBonus()) then
					ent.bonus = true
				else
					ent.bonus = false
				end
				gtimer.SetBonus(ent,ent.bonus)
				if(ent.gtimer) then
					ent:ResetTimer()
				end
			elseif(self:GetZoneType() == 2 && ent.gtimer && !ent.finishtime) then
				if(self:GetBonus() == ent.bonus) then
					ent:StopTimer(true,self:GetBonus())
				end
			elseif(self:GetZoneType() == 3 && ent.gtimer) then
				if(self:GetBonus() == ent.bonus) then
					ent:StopTimer(false,self:GetBonus())
				end
			end
		end
	end

	function ENT:EndTouch(ent)  
		if(self:GetZoneType() == 1 && ent && ent:IsValid() && ent:IsPlayer() && !ent:IsBot()) then
			ent.InSpawn = false
			if(self:GetBonus()) then
				ent.bonus = true
			else
				ent.bonus = false
			end
			gtimer.SetBonus(ent,ent.bonus)
			if(!ent.timer) then
				if(ent:GetMoveType() != MOVETYPE_NOCLIP) then
					ent:StartTimer()
				end
			end
		end
	end
else

	local Laser = Material(BHOP.ZoneMaterial)
			
	function ENT:Initialize() 
	end 

	function ENT:Think() 
		local Min, Max = self:GetCollisionBounds()
		self:SetRenderBounds(Min, Max) 
	end 

	function ENT:Draw()
		if(self:GetZoneType() > 2) then return end
		local Min, Max = self:GetCollisionBounds()
		Min=self:GetPos()+Min
		Min.z = Min.z + 2
		Max=self:GetPos()+Max

		local Zero = 0
		local Glow = math.random( 255, 200 )
		local ZeroB = 0
		local GlowB = math.random( 130, 100 )
		local START = Color(Glow,Glow,Glow)
		local END = Color(Glow,Glow,Glow)
		local BONUS = Color(Glow,Glow,Glow)
		
		local Col = START
		if(self:GetZoneType() == 2) then
			Col = END
		elseif(self:GetBonus()) then
			Col = BONUS
		end

		local C1, C2, C3, C4, C5, C6, C7, C8 = Vector(Min.x, Min.y, Min.Z), Vector(Min.x, Max.y, Min.Z), Vector(Max.x, Max.y, Min.Z), Vector(Max.x, Min.y, Min.Z), Vector(Min.x, Min.y, Max.Z), Vector(Min.x, Max.y, Max.Z), Vector(Max.x, Max.y, Max.Z), Vector(Max.x, Min.y, Max.Z) 
	
		local w = (Max.y-Min.y)/BHOP.ZoneTextureWith
		local l = (Max.x-Min.x)/BHOP.ZoneTextureWith
		local h = (Max.z-Min.z)/BHOP.ZoneTextureWith
		local zw = BHOP.ZoneWith
			
		render.SetMaterial(Laser)
		render.DrawBeam(C1, C2, zw, 0, 1*w, Col) 
		render.DrawBeam(C2, C3, zw, 0, 1*l, Col)
		render.DrawBeam(C3, C4, zw, 0, 1*w, Col)
		render.DrawBeam(C4, C1, zw, 0, 1*l, Col)
		--render.DrawBeam(C5, C6, zw, 0, 1*w, Col) 
		--render.DrawBeam(C6, C7, zw, 0, 1*l, Col)
		--render.DrawBeam(C7, C8, zw, 0, 1*w, Col)
		--render.DrawBeam(C8, C5, zw, 0, 1*l, Col)
		--render.DrawBeam(C1, C5, zw, 0, 1*h, Col) 
		--render.DrawBeam(C2, C6, zw, 0, 1*h, Col) 
		--render.DrawBeam(C3, C7, zw, 0, 1*h, Col) 
		--render.DrawBeam(C4, C8, zw, 0, 1*h, Col) 
	end
end