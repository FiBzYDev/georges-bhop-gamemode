GM.Name 		= "Bunny Hop"
GM.Author 		= "George, Edits by FiBzY"
GM.TeamBased 	= false

include("player_class/player_bhop.lua")
include("bhop_cfg.lua")
include("sh_viewoffsets.lua")
include("rtv/config.lua")

TEAM_BHOP = 2
team.SetUp(TEAM_BHOP, "Bunny Hoppers", BHOP.Orange, false) 


DeriveGamemode("base") 
DEFINE_BASECLASS("gamemode_base")

GM.Alldoors = {
	"bhop_archives",
	"bhop_monster_jam",
	"bhop_exzha",
	"bhop_areaportal_v1",
	"bhop_ytt_space"
}

GM.Heightdoors = {
	"bhop_gnite",
	"bhop_snowwhite"
}

GM.Nodoors = {
	"bhop_hive",
	"bhop_fury",
	"bhop_mcginis_fix"
}

hook.Add("InitPostEntity","RemoveShitWidgets",function()
	hook.Remove("PlayerTick", "TickWidgets") --they arent used and are intensive, yolo
end)

function GM:EntityKeyValue(ent, key, value) 
	if(table.HasValue(self.Nodoors,game.GetMap())) then return end
	if(string.find(value,"modelindex") && string.find(value,"AddOutput")) then
		return ""
	end
	if(ent:GetClass() == "func_door") then
		if(table.HasValue(GAMEMODE.Alldoors,game.GetMap())) then
			ent.IsP = true
		end
		if(string.find(string.lower(key),"movedir")) then
			if(value == "90 0 0") then
				ent.IsP = true
			end
		end
		if(string.find(string.lower(key),"noise1")) then
			ent.BHS = value
		end
		if(string.find(string.lower(key),"speed")) then
			if(tonumber(value) > 100) then
				ent.IsP = true
			end
			ent.BHSp = tonumber(value)
		end
	end
	if(ent:GetClass() == "func_button") then
		if(table.HasValue(GAMEMODE.Alldoors,game.GetMap())) then
			ent.IsP = true
		end
		if(string.find(string.lower(key),"movedir")) then
			if(value == "90 0 0") then
				ent.IsP = true
			end
		end
		if(key == "spawnflags") then ent.SpawnFlags = value end
		if(string.find(string.lower(key),"sounds")) then
			ent.BHS = value
		end
		if(string.find(string.lower(key),"speed")) then
			if(tonumber(value) > 100) then
				ent.IsP = true
			end
			ent.BHSp = tonumber(value)
		end
	end
	if(self.BaseClass.EntityKeyValue) then
		self.BaseClass:EntityKeyValue(ent,key,value)
	end
end 

function GM:PlayerNoClip( player )
	return true
end

local mc, bn, ba, bo, sl = math.Clamp, bit.bnot, bit.band, bit.bor, string.lower
local mc, ft = math.Clamp, FrameTime
local lp, Iv, Ip, ft, ic, ct, gf, ds, du, pj, ur, ut, uc = LocalPlayer, IsValid, IsFirstTimePredicted, FrameTime, CLIENT, CurTime, {}, {}, {}, {}, {}, {}, {}

local function AutoHop( ply, data )
	if CLIENT then return end
	if ply.Style != 7 and ply.Style != 9 then
		local bd = data:GetButtons()
		if ba( bd, 2 ) > 0 then
			if not ply:IsOnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() != 9 then
				data:SetButtons( ba( bd, bn( 2 ) ) )
			end
		end
	end
end
hook.Add( "SetupMove", "AutoHop", AutoHop )

function GM:Move( ply, data )

		local aa, speedgain  = ply:Crouching() and BHOP.CrouchingAirAccelerate or BHOP.AirAccelerate, BHOP.SpeedGain
		local aim = data:GetMoveAngles()
		local fw = aim:Forward()
		local right = aim:Right()
		local fmove = data:GetForwardSpeed()
		local smove = data:GetSideSpeed()
		local st = ply.Style and ply.Style or gtimer.style
		
		
		if ply.InSpawn && ply:GetVelocity():Length() > BHOP.JumpZoneSpeedCap then 
			data:SetVelocity(ply:GetVelocity() * (BHOP.JumpZoneSpeedCap/ply:GetVelocity():Length()))
		end
		
        if st == 1 or ply.bonus then
             if data:KeyDown( 1024 ) then smove = smove + 500 end
             if data:KeyDown( 512 ) then smove = smove - 500 end
        elseif not ply.bonus then
        if st == 2 then
			if data:KeyDown( 8 ) then fmove = fmove + 500 end
			if data:KeyDown( 16 ) then fmove = fmove - 500 end
        elseif st == 7 then
			--aa, speedgain = ply:Crouching() and 20 or 50, BHOP.SpeedGain
				local vel = ply:GetVelocity():Length2D()
			if vel > BHOP.LegitSpeedCap then
				data:SetVelocity(ply:GetVelocity() * (BHOP.LegitSpeedCap/vel))
			end
        elseif st == 6 or st == 9 then
			--aa, speedgain = 120, BHOP.SpeedGain
			end
		end
               
		if st == 10 and not ply.bonus then
            ply:SetSaveValue( "m_flLaggedMovementValue", 0.5 )
		else
			ply:SetSaveValue( "m_flLaggedMovementValue", 1 )
        end
		
        fw.z, right.z = 0,0
        fw:Normalize()
        right:Normalize()
 
        local wishvel = fw * fmove + right * smove
        wishvel.z = 0
 
        local wishspeed = wishvel:Length()
        if wishspeed > data:GetMaxSpeed() then
                wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
                wishspeed = data:GetMaxSpeed()
        end
 
        local wishspd = wishspeed
        wishspd = mc( wishspd, 0, speedgain )
 
        local wishdir = wishvel:GetNormal()
        local vel = data:GetVelocity()
        local current = vel:Dot( wishdir )
 
        local addspeed = wishspd - current
        if addspeed <= 0 then return end
 
        local accelspeed = aa * ft() * wishspeed
        if accelspeed > addspeed then
                accelspeed = addspeed
        end
        vel = vel + (wishdir * accelspeed)
       
        data:SetVelocity( vel )
		
        return false
end


local function ChangeMove( ply, data )
	if not ply:IsOnGround() then
		if not du[ ply ] then
			gf[ ply ] = 0
			ds[ ply ] = nil
			du[ ply ] = true
			
			ply:SetDuckSpeed( BHOP.CrouchedSpeed )
			ply:SetUnDuckSpeed( BHOP.UnCrouchedSpeed )
		end
		
		if ic and ply.Gravity != nil then
			if ply.Gravity or ply.Freestyle then
				ply:SetGravity( 0 )
			else
				ply:SetGravity( plg )
			end
		end
	else
		if not gf[ ply ] then
			gf[ ply ] = 0
		else

			if gf[ ply ] > 12 then
				if not ds[ ply ] then

					
			ply:SetDuckSpeed( BHOP.CrouchedSpeed )
			ply:SetUnDuckSpeed( BHOP.UnCrouchedSpeed )
					
					ds[ ply ] = true
				end
			else
				gf[ ply ] = gf[ ply ] + 1
				
				if gf[ ply ] == 1 then
					du[ ply ] = nil

					
					if pj[ ply ] then
						pj[ ply ] = pj[ ply ] + 1
					end
				elseif gf[ ply ] > 1 and data:KeyDown( 2 ) then
					if ic and gf[ ply ] < 4 then return end
					
					local vel = data:GetVelocity()
					vel.z = ply:GetJumpPower()
					
					ply:SetDuckSpeed( 0 )
					ply:SetUnDuckSpeed( 0 )
					gf[ ply ] = 0
					
					data:SetVelocity( vel )
				end
			end
		end
	end
end
hook.Add( "SetupMove", "ChangeMove", ChangeMove )

local boosters = {}
boosters["bhop_challenge2"] = 1
boosters["bhop_ytt_space"] = 1.1
boosters["bhop_dan"] = 1.5

local function getboosterstr(map)
	if(!boosters[map]) then return 1.3 end
	return boosters[map]
end

local var = nil
function GM:OnPlayerHitGround( ply, bInWater, bOnFloater, flFallSpeed )
	local ent = ply:GetGroundEntity()
	if(!var) then var = getboosterstr(game.GetMap()) end
	if(tonumber(ent:GetNWInt("Platform",0)) != 0) then
		if (ent:GetClass() == "func_door" || ent:GetClass() == "func_button") && ent.BHSp && ent.BHSp > 100 then
			timer.Simple(0.02,function()ply:SetVelocity( Vector( 0, 0, ent.BHSp*var ) ) end)
		elseif ent:GetClass() == "func_door" || ent:GetClass() == "func_button" then
			timer.Simple( 0.08, function()
				-- setting owner stops collision between two entities
				ent:SetOwner(ply)
				if(CLIENT)then
					ent:SetColor(Color(255,255,255,125)) --clientsided setcolor (SHOULD BE AUTORUN SHARED)
				end
			end)
			timer.Simple( 0.7, function()  ent:SetOwner(nil) end)
			timer.Simple( 0.7, function()  if(CLIENT)then ent:SetColor(Color (255,255,255,255)) end end)
		end
	end
	
	if(self.BaseClass && self.BaseClass.OnPlayerHitGround) then
		self.BaseClass:OnPlayerHitGround(ply)
	end
	if flFallSpeed < 350 then
		return true
	end
end

if(file.Exists("bhop/gamemode/mapfixes/"..game.GetMap()..".lua","LUA")) then
	HOOKS = {}
	include("bhop/gamemode/mapfixes/"..game.GetMap()..".lua")
	for k,v in pairs(HOOKS) do
		hook.Add(k,k.."_"..game.GetMap(),v)
	end
end