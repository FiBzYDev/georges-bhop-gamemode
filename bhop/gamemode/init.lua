include("bhop_cfg.lua")
include("shared.lua")
include("sv_timer.lua")
include("rtv/sv_rtv.lua")
include("sv_ranks.lua")
include("sv_jumpstats.lua")

AddCSLuaFile("bhop_cfg.lua")
AddCSLuaFile("rtv/config.lua")
AddCSLuaFile("rtv/cl_rtv.lua")
AddCSLuaFile("player_class/player_bhop.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_timer.lua")
AddCSLuaFile("cl_ljstats.lua")
AddCSLuaFile("sh_timer.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_viewoffsets.lua")

RunConsoleCommand("sv_airaccelerate", "0")
RunConsoleCommand("sv_stopspeed", "75")
RunConsoleCommand("sv_friction", "4")
RunConsoleCommand("sv_accelerate", "5")
RunConsoleCommand("sv_gravity", "800")
RunConsoleCommand("sv_sticktoground", "0")

util.AddNetworkString("RemoveSpectator")
util.AddNetworkString("ModeMenu")
util.AddNetworkString( "StatsMenu" )
util.AddNetworkString("ModeMenu2")
util.AddNetworkString("AddSpectator")
util.AddNetworkString("SetSpectators")
util.AddNetworkString("MovementData")

--local TPS_NAMETIME = 3
--local TPS_PREFIX = "FiBzY's Private Bhop Server | 100T \ REPLAY |"

--local TPS_NAMES = {
--	"Best server ever 10/10",
--	"CS:S-Like BHOP!",
--	"FiBzY is the best owner!",
--	"Why not click that join button?",
--	"FiBzY is hawt.",
--}
     
--local function ChangeName()
 --   local name = table.Random(TPS_NAMES)
  --  RunConsoleCommand("hostname", TPS_PREFIX.." / "..name)
  --  timer.Simple(TPS_NAMETIME, ChangeName)
--end
--ChangeName()

function GM:PlayerSpawn(ply)
	ply:SetTeam(TEAM_BHOP)
	player_manager.SetPlayerClass( ply, "player_bhop" )
	self.BaseClass:PlayerSpawn(ply)
	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" ) 
		
	ply:SetHull( BHOP.HullMin, BHOP.HullStand )
	ply:SetHullDuck( BHOP.HullMin, BHOP.HullCrouch )
	
	ply:SetJumpPower(BHOP.JumpPower)
	ply:SetWalkSpeed(BHOP.WalkSpeed)
	ply:SetRunSpeed(BHOP.SneakSpeed)
	
	ply:SetCrouchedWalkSpeed(BHOP.CrouchedWalkSpeed)
	ply:SetDuckSpeed(BHOP.CrouchedSpeed)
	ply:SetUnDuckSpeed(BHOP.UnCrouchedSpeed)
	
	ply:SetStepSize(BHOP.StepSize)
	
	if ply:IsBot() then
		ply:SetModel(BHOP.BotPlayerModel)
	else
		ply:SetModel(BHOP.PlayerModel)
	end
	
end

local spectable = {}

function GM:EntityTakeDamage( ent, dmg )
 
	if ( ent:IsPlayer() ) then
		return dmg:ScaleDamage( 0 )
	end
	
	return self.BaseClass:EntityTakeDamage(ent,dmg)
 
end

local lookuptable = {}
local uidcache = {}

local function lookupuid(id)
	if(lookuptable[id]) then return lookuptable[id] end
	return nil
end

local function findplyuid(ply)
	if(uidcache[ply]) then return uidcache[ply] end
	return nil
end

function GM:FindPUid(uid)
	lookupuid(uid)
end

local pm = FindMetaTable("Player")

if(game.GetMap() != "bhop_exodus") then
	hook.Add("PlayerNoClip","StopNoclip",function(ply)
		if(ply:GetMoveType() != MOVETYPE_NOCLIP) then
			ply:StopTimer()
		end
	end)
end

function pm:SpawnAsObserver()
	self:StripWeapons()
	self:KillSilent()
	self:Spectate( self.SpecMode )
	self:Freeze( false )
end

function pm:SendPVar(var,val)
	if(!spectable[self]) then return end
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		p:SendLua("LocalPlayer()."..var.." = "..val)
	end
end

function pm:SendRestart()
	if(!spectable[self]) then return end
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		p:SendLua("gtimer.ResetTimer()")
	end
end

function pm:GetSendTable()
	if(!spectable[self]) then return {self} end
	local rt = {self}
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		table.insert(rt,p)
	end
	return rt
end

function pm:SendStart(start)
	if(!spectable[self]) then return end
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		p:SendLua("gtimer.StartTimer("..start..")")
	end
end

function pm:SendEnd(tend)
	if(!spectable[self]) then return end
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		p:SendLua("gtimer.StopTimer("..tend..")")
	end
end

function pm:SendPB(newpb)
	if(!spectable[self]) then return end
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		p:SendLua("gtimer.SetPB("..newpb..")")
	end
end

function pm:SendStyle(style)
	if(!spectable[self]) then return end
	local filter = RecipientFilter()
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		filter:AddPlayer(p)
	end
	umsg.Start("SetStyle",filter)
	umsg.Short(style)
	umsg.End()
end

function pm:AddSpec(ent)
	local t = {self}
	local p = nil
	for k,v in pairs(spectable[self]) do
		p = nil
		p = lookupuid(k)
		if(p) then
			table.insert(t,p)
		end
	end
	table.insert(t,ent)
	net.Start("SetSpectators")
	net.WriteTable(spectable[self])
	net.Send(ent)
	net.Start("AddSpectator")
	net.WriteString(findplyuid(ent))
	net.WriteString(ent:Nick())
	net.Send(t)
	local s = self.Style or 1
	ent:SendLua("gtimer.ResetTimer()")
	timer.Simple(0.02,function() --ensuring it happens after anything else
	if(self.fs) then
		ent:SendLua("LocalPlayer().fs = true")
	else
		ent:SendLua("LocalPlayer().fs = false")
	end
	if(self.bonus && self.bpb) then
		ent:SendLua("gtimer.SetPB("..tonumber(self.bpb)..")")
	elseif(self.pb && self.pb[s]) then
		ent:SendLua("gtimer.SetPB("..tonumber(self.pb[s])..")")
	end
	if(self.bonus) then
		umsg.Start("SetStyle",ent)
		umsg.Short(100)
		umsg.End()
	else
		umsg.Start("SetStyle",ent)
		umsg.Short(self.Style)
		umsg.End()
	end
	if(self.gtimer) then
		ent:SendLua("gtimer.StartTimer("..self.gtimer..")")
	end
	if(self.finishtime) then
		ent:SendLua("gtimer.StopTimer("..self.finishtime..")")
	end
	if(!self.finishtime && !self.gtimer) then
		ent:SendLua("gtimer.ResetTimer()")
	end
	end)
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if ply:HasWeapon(wep:GetClass()) then return false end
	timer.Simple(0.1,function() if(wep:IsValid()) then ply:SetAmmo(420,wep:GetPrimaryAmmoType()) end end)
	return true
end

function GM:InitPostEntity() 
		for k,v in pairs(ents.FindByClass("func_door")) do
			if(!v.IsP) then continue end
			local mins = v:OBBMins()
			local maxs = v:OBBMaxs()
			local h = maxs.z - mins.z
			if(h > 80 && !table.HasValue(self.Alldoors,game.GetMap()) && !table.HasValue(self.Heightdoors,game.GetMap())) then continue end
			local tab = ents.FindInBox( v:LocalToWorld(mins)-Vector(0,0,10), v:LocalToWorld(maxs)+Vector(0,0,5) )
			if(tab || (v.BHSp > 100)) then
				for _,v2 in pairs(tab) do if(v2 && v2:IsValid() && v2:GetClass() == "trigger_teleport") then tele = v2 end end
				if(tele || (v.BHSp > 100)) then
					v:Fire("Lock")
					v:SetKeyValue("spawnflags","1024")
					v:SetKeyValue("speed","0")
					v:SetRenderMode(RENDERMODE_TRANSALPHA)
					if(v.BHS) then
						v:SetKeyValue("locked_sound",v.BHS)
					else
						v:SetKeyValue("locked_sound","DoorSound.DefaultMove")
					end
					v:SetNWInt("Platform",1)
				end
			end
		end
	
		for k,v in pairs(ents.FindByClass("func_button")) do
			if(!v.IsP) then continue end
			if(v.SpawnFlags == "256") then 
				local mins = v:OBBMins()
				local maxs = v:OBBMaxs()
				local tab = ents.FindInBox( v:LocalToWorld(mins)-Vector(0,0,10), v:LocalToWorld(maxs)+Vector(0,0,5) )
				if(tab) then
					for _,v2 in pairs(tab) do if(v2 && v2:IsValid() && v2:GetClass() == "trigger_teleport") then tele = v2 end end
					if(tele) then
						v:Fire("Lock")
						v:SetKeyValue("spawnflags","257")
						v:SetKeyValue("speed","0")
						v:SetRenderMode(RENDERMODE_TRANSALPHA)
						if(v.BHS) then
							v:SetKeyValue("locked_sound",v.BHS)
						else
							v:SetKeyValue("locked_sound","None (Silent)")
						end
						v:SetNWInt("Platform",1)
					end
				end
			end
		end
end 

function pm:RemoveSpec(ent)
	local t = {self}
	local p = nil
	if(spectable[self]) then
		for k,v in pairs(spectable[self]) do
			p = nil
			p = lookupuid(k)
			if(p && p != ent) then
				table.insert(t,p)
			end
		end
	end
	ent:SendLua("LocalPlayer().fs = false")
	net.Start("RemoveSpectator")
	net.WriteString(findplyuid(ent))
	net.Send(t)
end

function pm:SpawnAsSpectator()
	self:SpawnAsObserver()
	self:SetTeam( TEAM_SPECTATOR )
end

function GM:PlayerInitialSpawn(ply)
	local u = ply:UniqueID()
	lookuptable[u] = ply
	uidcache[ply] = u
	ply.SpecMode = OBS_MODE_IN_EYE
	ply.SpecID = 1
	ply.roam = false
	ply.chase = false
	timer.Simple(4,function()
		if(ply.CheckGroup and ply:CheckGroup("vip")) then -- Fixed this annoying ass error <3 itz
			ply.vipchat = ply:GetPData("VIPChat","")
			ply:SetNWString("VIPChat",ply.vipchat)
			ply:SetNWString("VIPChatCol",ply:GetPData("VIPChatCol",""))
		end
	end)
	self.BaseClass:PlayerInitialSpawn(ply)
end

function GM:GetPlayers(b_alive, filter)  
	local players = player.GetAll() 
	local Return = {} 
	for k,v in pairs(players) do 
		if (v:Alive() && !v.inspec) and b_alive then 
			if (filter and !table.HasValue(filter, v)) or !filter then 
				table.insert(Return, v) 
			end 
		elseif !b_alive then
			if (filter and !table.HasValue(filter, v)) or !filter then 
				table.insert(Return, v) 
			end 
		end 
	end 
	return Return 
end 


function GM:PlayerSay(ply,text,p)
	if(string.lower(text) == "!spec" || string.lower(text) == "/spec") then
		self:ToggleSpectator(ply)
		return ""
	end
	return self.BaseClass:PlayerSay(ply,text,p)
end
 
hook.Add("PlayerSay","ModesMenuToggle",function(ply,text,p)
        local t = string.lower(text)
        if(t == "!mode" or t == "/mode" or t == "!style" or t == "/style") then
                net.Start("ModeMenu")
                net.Send(ply)
                return ""
        end
end)
 
hook.Add("PlayerSay","ModesMenuToggle2",function(ply,text,p)
        local t = string.lower(text)
        if(t == "!mode2" or t == "/mode2" or t == "!style2" or t == "/style2") then
                net.Start("ModeMenu2")
                net.Send(ply)
                return ""
        end
end)

function GM:ShowTeam( ply )
    umsg.Start( "SpecHud", ply )
    umsg.End()
end

concommand.Add("vipname_help",function(ply,cmd,args)
	if(!(ply:CheckGroup("vip"))) then return end
	ply:PrintMessage(HUD_PRINTCONSOLE,"Use vipname_set to set your custom tag/name in chat")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Use hexcode colors in your message in this format ^FFFFFF.")
	ply:PrintMessage(HUD_PRINTCONSOLE,"^FFFFFFhi^000000hi - this would print as (white)hi(black)hi.")
	ply:PrintMessage(HUD_PRINTCONSOLE,"{name} is replaced by your actual steam name.")
	ply:PrintMessage(HUD_PRINTCONSOLE,"Use viptext_set and then a HEX CODE COLOR (FFFFFF) to set the color of your text.")
end)

concommand.Add("viptext_set",function(ply,cmd,args)
	if(!(ply:CheckGroup("vip"))) then return end
	ply:SetNWString("VIPChatCol",args[1])
	ply:SetPData("VIPChatCol",args[1])
end)

concommand.Add("vipname_set",function(ply,cmd,args)
	if(!(ply:CheckGroup("vip"))) then return end
	ply.vipchat = table.concat(args," ")
	ply:SetNWString("VIPChat",ply.vipchat)
	ply:SetPData("VIPChat",ply.vipchat)
	ply:PrintMessage(HUD_PRINTCONSOLE,"Custom name set.")
end)

function GM:PlayerDeathThink( pl )
end

function GM:ToggleSpectator(ply)
	if(!ply.inspec) then
		gtimer.SetRecord(ply,false)
		local players = self:GetPlayers(true,{ply})
		ply.inspec = true
		if(ply.SpecID) then
			if(!players[ply.SpecID]) then
				ply.SpecID = 1
			end
			ply.SpecEnt = players[ply.SpecID]
			if(!spectable[ply.SpecEnt]) then
				spectable[ply.SpecEnt] = {}
			end
			ply.SpecEnt:AddSpec(ply)
			spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
		end
		ply:SpawnAsSpectator()
		if(ply.SpecMode != OBS_MODE_ROAMING) then
			ply:SpectateEntity(ply.SpecEnt)
		end
		ply:ResetTimer()
		if(spectable[ply]) then
			local p = nil
			for k,v in pairs(spectable[ply]) do
				p = nil
				p = lookupuid(k)
				if(p && p:IsValid()) then
					self:SpectateNext(p)
				end
			end
		end
	else
		ply.inspec = false
		if(ply.SpecEnt) then
			ply.SpecEnt:RemoveSpec(ply)
			spectable[ply.SpecEnt][findplyuid(ply)] = nil
			ply.SpecEnt = nil
			net.Start("SetSpectators")
			net.WriteTable({})
			net.Send(ply)
		end
		local s = ply.Style or 1
		ply:SendLua("gtimer.SetPB("..tonumber(ply.pb[s])..")")
		ply:Spawn()
		ply:SendLua("gtimer.ResetTimer()")
		ply:ResetTimer()
	end
end

function GM:PlayerDisconnected(ply)
	if(spectable[ply]) then
		local p = nil
		for k,v in pairs(spectable[ply]) do
			p = nil
			p = lookupuid(k)
			if(p && p:IsValid()) then
				self:SpectateNext(p)
			end
		end
	end
	if(ply.SpecEnt) then
		ply.SpecEnt:RemoveSpec(ply)
		spectable[ply.SpecEnt][findplyuid(ply)] = nil
	end
	lookuptable[ply:UniqueID()] = nil
	uidcache[ply] = nil
	
	if(ply.fagbanme) then
		RunConsoleCommand("ulx", "banid", ply:SteamID() , 0, "Strafe Hack/Movement Recorder Detected")
	end
	
	self.BaseClass:PlayerDisconnected(ply)
end

function GM:SpectateNext(ply) 
	local players = self:GetPlayers(true,{ply})
	if(#players == 1) then
		if(ply.SpecID != 1 || (players[1] != ply.SpecEnt)) then
			ply.SpecID = 1
			local p = players[ply.SpecID]
			local c = tobool(ply.SpecEnt != p)
			if(ply.SpecEnt && c) then
				ply.SpecEnt:RemoveSpec(ply)
				spectable[ply.SpecEnt][findplyuid(ply)] = nil
			end
			ply.SpecEnt = p
			if(c) then
				if(!spectable[ply.SpecEnt]) then
					spectable[ply.SpecEnt] = {}
				end
				ply.SpecEnt:AddSpec(ply)
				spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
			end
		end
		return
	end
	ply.SpecID = ply.SpecID + 1
	if(ply.SpecID>#players)then
		ply.SpecID = 1
	end
	local p = players[ply.SpecID]
	local c = tobool(ply.SpecEnt != p)
	if(ply.SpecEnt && c) then
		ply.SpecEnt:RemoveSpec(ply)
		spectable[ply.SpecEnt][findplyuid(ply)] = nil
	end
	ply.SpecEnt = p
	if(ply.SpecEnt && c) then
		if(!spectable[ply.SpecEnt]) then
			spectable[ply.SpecEnt] = {}
		end
		ply.SpecEnt:AddSpec(ply)
		spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
	end
	ply:SpectateEntity(players[ply.SpecID])
end 

function GM:SpectatePrev(ply) 
	local players = self:GetPlayers(true,{ply})
	if(#players == 1) then
		if(ply.SpecID != 1 || (players[1] != ply.SpecEnt)) then
			ply.SpecID = 1
			local p = players[ply.SpecID]
			local c = tobool(ply.SpecEnt != p)
			if(ply.SpecEnt && c) then
				ply.SpecEnt:RemoveSpec(ply)
				spectable[ply.SpecEnt][findplyuid(ply)] = nil
			end
			ply.SpecEnt = p
			if(c) then
				if(!spectable[ply.SpecEnt]) then
					spectable[ply.SpecEnt] = {}
				end
				ply.SpecEnt:AddSpec(ply)
				spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
			end
		end
		return
	end
	ply.SpecID = ply.SpecID - 1
	if(ply.SpecID<1)then
		ply.SpecID = #players
	end
	local p = players[ply.SpecID]
	local c = tobool(ply.SpecEnt != p)
	if(ply.SpecEnt && c) then
		ply.SpecEnt:RemoveSpec(ply)
		spectable[ply.SpecEnt][findplyuid(ply)] = nil
	end
	ply.SpecEnt = p
	if(ply.SpecEnt && c) then
		if(!spectable[ply.SpecEnt]) then
			spectable[ply.SpecEnt] = {}
		end
		ply.SpecEnt:AddSpec(ply)
		spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
	end
	ply:SpectateEntity(players[ply.SpecID])
end 

function GM:ChangeSpecMode(ply)

	if(ply.chase) then
		ply.SpecMode = OBS_MODE_IN_EYE
		ply.chase = false
	else
		ply.SpecMode = OBS_MODE_CHASE
		ply.chase = true
	end
	ply:SetObserverMode(ply.SpecMode)
end

function GM:ToggleRoam(ply)
	if(ply.roam) then
		if(ply.OSpecEnt && ply.OSpecEnt:IsValid() && ply.OSpecEnt:Alive() && !ply.OSpecEnt.inspec) then
			ply.SpecEnt = ply.OSpecEnt
			if(!spectable[ply.SpecEnt]) then
				spectable[ply.SpecEnt] = {}
			end
			ply.SpecEnt:AddSpec(ply)
			spectable[ply.SpecEnt][findplyuid(ply)] = ply:Nick()
		else
			ply.SpectateNext = true
		end
		ply.OSpecEnt = nil
		if(ply.chase) then
			ply.SpecMode = OBS_MODE_CHASE
		else
			ply.SpecMode = OBS_MODE_IN_EYE
		end
		ply.roam = false
	else
		if(ply.SpecEnt) then
			ply.SpecEnt:RemoveSpec(ply)
			spectable[ply.SpecEnt][findplyuid(ply)] = nil
			ply.OSpecEnt = ply.SpecEnt
			ply.SpecEnt = nil
		end
		net.Start("SetSpectators")
		net.WriteTable({})
		net.Send(ply)
		ply.SpecMode = OBS_MODE_ROAMING
		ply.roam = true
	end
	ply:Spectate(ply.SpecMode)
	ply:SpectateEntity(ply.SpecEnt)
	if(ply.SpectateNext) then
		ply.SpectateNext = false
		self:SpectateNext(ply)
	end
end

function GM:IsSpawnpointSuitable()
	return true
end

hook.Add("KeyPress", "SpectateModeChange", function(ply, key) 
	if ply.inspec then 
		if !ply.roam && key == IN_ATTACK then 
			GAMEMODE:SpectateNext(ply)
		elseif !ply.roam && key == IN_ATTACK2 then 
			GAMEMODE:SpectatePrev(ply)
		elseif !ply.roam && key == IN_JUMP then 
			GAMEMODE:ChangeSpecMode(ply)
		elseif key == IN_RELOAD then 
			GAMEMODE:ToggleRoam(ply)
		end
	end 
end )

local APIKey = BHOP.APIKey
local function HandleSharedPlayer(ply, lenderSteamID)
    print(string.format("Family sharing account, %s | %s has been lent by %s", 
            ply:Nick(),
            ply:SteamID(),
            lenderSteamID
    ))

    if not (ULib and ULib.bans) then return end

    if ULib.bans[lenderSteamID] then
        ply:Kick("Your main account is banned.")
    end
end

local function CheckFamilySharing(ply)
    http.Fetch(
        string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
            APIKey,
            ply:SteamID64()
        ),
        
        function(body)
            body = util.JSONToTable(body)

            if not body or not body.response or not body.response.lender_steamid then
                error(string.format("FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
            end

            local lender = body.response.lender_steamid
            if lender ~= "0" then
                HandleSharedPlayer(ply, util.SteamIDFrom64(lender))
            end
        end,
        
        function(code)
            error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
        end
    )
end
hook.Add("PlayerAuthed", "CheckFamilySharing", CheckFamilySharing)