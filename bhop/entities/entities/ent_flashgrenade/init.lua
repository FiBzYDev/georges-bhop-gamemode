---------------------------- 
--         SSBase         -- 
-- Created by Skeyler.com -- 
---------------------------- 

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
        self.Entity:SetModel("models/weapons/w_eq_flashbang.mdl")
        self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveCollide( MOVECOLLIDE_FLY_BOUNCE )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:DrawShadow( false )
		self.Entity:SetGravity( 0.4 )
		self.Entity:SetElasticity( 0.45 )
		self.Entity:SetFriction(0.2)

        self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        
        local phys = self.Entity:GetPhysicsObject()
        
        if (phys:IsValid()) then
                phys:Wake()
        end
        
        self.timer = CurTime() + 3
end

function ENT:Think()
        if self.timer <= CurTime() then
                self.Entity:Remove()
        end
end