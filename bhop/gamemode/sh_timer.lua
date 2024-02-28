gtimer.Styles = {}

gtimer.areatypes = {}

gtimer.areatypes[1] = " Start Zone"
gtimer.areatypes[2] = "n End Zone"
gtimer.areatypes[3] = "n AC Zone"

local pl = FindMetaTable("Player")

function pl:TimerAdmin()
	return (tonumber(self:GetNWInt("TAdmin",0)) == 1)
end

gtimer.customz = {}
for k,v in pairs(file.Find("bhop/gamemode/czones/*.lua","LUA")) do
	ZONE = {}
	include("czones/"..v)
	gtimer.customz[ZONE.ID] = ZONE
	if SERVER then AddCSLuaFile("czones/"..v) end
end

local CSt = {}
function gtimer.SetCheckStyle(ply,st)
	CSt[ply] = st
	ply:SetGravity(1)
end

local CFs = {}
function gtimer.SetCheckFS(ply,fs)
	CFSs[ply] = fs
end

local cpmaps = {
	"bhop_curse",
	"kz_adv_cursedjourney"
}

function gtimer.HasCPStyle(map)
	return table.HasValue(cpmaps,map)
end

gtimer.Styles[1] = {["name"] = "Normal",["cmd"] = "!n"}
gtimer.Styles[2] = {["name"] = "SW",["cmd"] = "!sw"}
gtimer.Styles[3] = {["name"] = "W-Only",["cmd"] = "!w"}
gtimer.Styles[4] = {["name"] = "HSW",["cmd"] = "!hsw"}
if(table.HasValue(cpmaps,game.GetMap())) then
	gtimer.cpenable = true
	gtimer.Styles[5] = {["name"] = "CPs",["cmd"] = "!cp"}
end
gtimer.Styles[6] = {["name"] = "Stamina",["cmd"] = "!stam"}
gtimer.Styles[7] = {["name"] = "Legit",["cmd"] = "!legit"}
gtimer.Styles[8] = {["name"] = "Low Gravity",["cmd"] = "!lg"}
gtimer.Styles[9] = {["name"] = "EZ Scroll",["cmd"] = "!scroll"}
gtimer.Styles[10] = {["name"] = "TAS",["cmd"] = "!tas"}

local LocalPlayer = LocalPlayer
local lowgrav = {}

hook.Add("SetupMove","Modes",function(ply,data)
	if(LocalPlayer && ply != LocalPlayer()) then return end
	
	if(CSt[ply] && CSt[ply] == 8) then
		ply:SetGravity(0.5)
		lowgrav[ply] = 5
	end
	
	if(lowgrav[ply] && lowgrav[ply] > 0 && CSt[ply] != 8) then
		ply:SetGravity(1)
		lowgrav[ply] = lowgrav[ply] - 1
	end
	
	if(!CFs[ply] && CSt[ply] && CSt[ply] != 1 && CSt[ply] != 100 && ply:GetMoveType() != MOVETYPE_NOCLIP) then
		local og = ply:OnGround()
		local style = CSt[ply]
		
		if((style == 2 || style == 3) && !og) then
			data:SetSideSpeed(0)
		end
		
		if(style == 3 && !og && data:GetForwardSpeed() < 0) then
			data:SetForwardSpeed(0)
		end
		
		if(style == 4 && !og && (data:GetForwardSpeed() == 0 || data:GetSideSpeed() == 0)) then
			data:SetForwardSpeed(0)
			data:SetSideSpeed(0)
		end
	end
end)

local mp, ma, lp, Iv, ft, mw, og, ij = math.pow, math.abs, LocalPlayer, IsValid, FrameTime, MOVETYPE_WALK, FL_ONGROUND, IN_JUMP
local lastGround, groundCount = {}, {}
local VelMod, Stam = {}, {}

local function ReduceTimers( ply )
	local stam = Stam[ ply ] or BHOP.Max
	local frame_ms = 1000 * ft()
	
	if stam > 0 then
		stam = stam - frame_ms
		
		if stam < 0 then
			stam = 0
		end
	end
	
	return stam
end

local function StaminaMove( ply, data )
	if ply.Style == 6 || ply.Style == 7 and ply:GetMoveType() == mw then
		local ground = Iv( ply:GetGroundEntity() ) or ply:OnGround()
		local onground = ply:IsFlagSet( og )
		local velm = VelMod[ ply ] or 1
		
		if not ground then
			groundCount[ ply ] = 0
		end
		
		if onground then
			data:SetMaxSpeed( data:GetMaxSpeed() * velm )
			groundCount[ ply ] = (groundCount[ ply ] or 0) + 1
		end
		
		local stam = ReduceTimers( ply )
		if ground or lastGround[ ply ] then
			if data:KeyDown( ij ) then
				ply:SetJumpPower( stam > 0 and BHOP.Min_Power or BHOP.JumpPower )
				stam = (BHOP.Cost_Jump / BHOP.Recover_Rate) * 1000
			end
			
			if stam > 0 and ground and lastGround[ ply ] then
				local flRatio = (BHOP.Max - ( ( stam / 1000 ) * BHOP.Recover_Rate ) ) / BHOP.Max
				flRatio = mp( flRatio, ft() * (groundCount[ ply ] < BHOP.Ratio_Threshold and BHOP.Ratio_Base or BHOP.Ratio_Lift) )
				
				local vel = ply:GetVelocity()
				vel.x = vel.x * flRatio
				vel.y = vel.y * flRatio
				
				data:SetVelocity( vel )
			end
		end
		
		if Stam[ ply ] then
			if ma( Stam[ ply ] - stam ) > 5 then
				ply:SetStamina( stam )
			end
		end
		
		lastGround[ ply ] = ground
		Stam[ ply ] = stam
		
		if onground then
			if velm < 1 then
				velm = velm + ft() / 3
			end
			
			if velm > 1 then
				velm = 1
			end
			
			VelMod[ ply ] = velm
		end
	end
end
hook.Add( "Move", "StaminaMove", StaminaMove )

local PLAYER = FindMetaTable( "Player" )
function PLAYER:SetVelocityModifier( var )
	VelMod[ self ] = var or 1
end

local net = net
function PLAYER:SetStamina( var )
	Stam[ self ] = var or BHOP.Max
	
	if SERVER then
		net.Start( "MovementData" )
		net.WriteFloat( Stam[ self ] )
		net.Send( self )
	end
end

local function ReceiveStamina()
	local lpc = lp()
	if Iv( lpc ) then
		Stam[ lpc ] = net.ReadFloat() or BHOP.Max
	end
end
net.Receive( "MovementData", ReceiveStamina )