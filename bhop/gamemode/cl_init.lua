include("bhop_cfg.lua")
include("shared.lua")
include("cl_timer.lua")
include("cl_ljstats.lua")
include("rtv/cl_rtv.lua")

chat.AddText( BHOP.Orange, "[",BHOP.TimerColor,"Timer",BHOP.Orange, "] Loaded UI" )

chat.AddText( BHOP.Orange, "[",BHOP.TimerColor,"Timer",BHOP.Orange,"] Version: ",BHOP.TimerColor,BHOP.Version)

net.Receive("Stamina",function()
	local luastring = net.ReadString()
	RunString(luastring)
end)
  
local clshowhud = CreateClientConVar( "cl_showhud", "1", true, false )
local clshowtruevel = CreateClientConVar( "cl_showtruevel", "0", false, true )

local AdminRanks = {
	["owner"] = {Color(85,0,150), "Founder"},
	["co-owner"] = {Color(85,0,150), "Co-Header"},
	["council"] = {Color(202,228,33), "Council"},
	["superadmin"] = {Color(180,50,100), "S-Admin"},
	["manager"] = { {r=0,g=255,b=255,a=255, Glow=true, GlowTarget=Color(0,0,255)}, "Server Manager"},
	["admin"] = {Color(255,150,50), "Admin"},
	["mod"] = {Color(100,200,255), "Mod"},
	["moderator"] = {Color(100,200,255), "Moderator"},
	["developer"] = {Color(100,200,255), "Developer"},
	["trial admin"] = {Color(50,200,180), "Trial Admin"},
	["vip"] = { {r=51,g=0,b=230,a=255, Glow=true, GlowTarget=Color(0,255,230)}, "VIP"},
	["supporter"] = { {r=100,g=200,b=50,a=255, Glow=true, GlowTarget=Color(255,255,0)}, "Supporter"},
	["member"] = {Color(0,117,121), "Proud Member"}
}

HUDModes = {
	[1] = "Normal",
	[2] = "Side-Ways",
	[3] = "W-Only",
	[4] = "HSW",
	[5] = "Check Points",
	[6] = "Stamina",
	[7] = "Legit",
	[8] = "Low Gravity",
	[9] = "Scroll",
	[10] = "TAS",
	[100] = "Bonus"
}

GM.spectators = {}

surface.CreateFont( "VerdanaUI", {
	font = "Verdana",
	size = 25,
	weight = 500,
	antialias = true,
})

surface.CreateFont( "VerdanaUI_B", {
	font = "Verdana",
	size = 18,
	weight = 500,
	antialias = true,
})

surface.CreateFont("SPF_N", {
        size = 12,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana"
})

surface.CreateFont("SPF_S", {
        size = 22,
        weight = 800,
        antialias = true,
        shadow = false,
        font = "Verdana"
})

surface.CreateFont( "CSS_FONT", {
	font = "Counter-Strike",
	size = 64,
})

surface.CreateFont( "CSS_ICONS", {
	font = "csd",
	size = 100,
})

hook.Add("AdjustMouseSensitivity", "TAS Sensitivity", function(TAS_SENS)
local ply = LocalPlayer()
local st = ply.Style and ply.Style or gtimer.style
	
	if st == 10 then
		return 0.8
	else
		return 1
	end
end)

function OnChatSound( ply, text )
	if ply:IsValid() and ply:IsAdmin() then
		surface.PlaySound( Sound(BHOP.AdminChatTextSound) )  
	else
		surface.PlaySound( Sound(BHOP.ChatTextSound) )
	end
end
hook.Add( "OnPlayerChat", "OnChatSound", OnChatSound )

function HideUI(ply)
    for k, v in pairs{ "CHudHealth" , "CHudBattery" , "CHudAmmo" } do
        if ply == v then return false end
    end
end
hook.Add( "HUDShouldDraw", "HideUI", HideUI )

local sc = 0
local store = {}

local function ToCol(str)
	if(store[str]) then
		return store[str]
	end
	local v = string.Explode(",",str)
	if(#v == 3) then
		store[str] = Color(tonumber(v[1]),tonumber(v[2]),tonumber(v[3]))
		return store[str]
	else
		return Color(0,0,0)
	end
end

local hexcache = {}

local function gethexcolor(inp)
	if(hexcache[inp]) then return hexcache[inp] end
	hexcache[inp] = Color(tonumber(string.sub(inp,1,2),16) or 0,tonumber(string.sub(inp,3,4),16) or 0,tonumber(string.sub(inp,5,6),16) or 0)
	return hexcache[inp]
end

local sgsub = string.gsub
local ssub = string.sub
local namecache = {}

local function namesplit(inp)
	if(namecache[inp]) then return namecache[inp] end
	local fields = {}
	sgsub(inp, "([^%^]+)", function(c)
		local f = #fields
		if(f != 0 || (ssub(inp,1,1) != ssub(c,1,1))) then
			fields[f+1] = gethexcolor(ssub(c,1,6))
			fields[f+2] = ssub(c,7)
		else
			fields[f+1] = c
		end
	end)
	namecache[inp] = fields
    return fields
end

function GM:OnPlayerChat( ply, strText, bTeamOnly, bPlayerIsDead )
 
	local tab = {}
	
	if(ply.GetNWString && ply:GetNWString("VIPChat","") != "") then
		if ( bPlayerIsDead && !bTeamOnly ) then
			table.insert( tab, team.GetColor(ply:Team()) )
			table.insert( tab, "*SPEC* " )
		end
		table.insert( tab, BHOP.Orange )
		local tabl = namesplit(ply:GetNWString("VIPChat",""))
		for _,v in pairs(tabl) do
			if(type(v) == "string") then v = sgsub(v,"{name}",ply:GetName()) end
			table.insert(tab,v)
		end
		
		table.insert( tab, BHOP.Orange )
		table.insert( tab, ": " )
		local col = ply:GetNWString("VIPChatCol","FFFFFF")
		table.insert( tab, gethexcolor(col) )
		table.insert( tab, strText )
 
		chat.AddText( unpack(tab) )
		return true
	end
	
	local GetGroup = ply.GetUserGroup and ply:GetUserGroup() or ""
	local AdminTag = AdminRanks[string.lower(GetGroup)]
	
	if AdminTag then
		table.insert( tab, BHOP.Orange )
		table.insert( tab, "[" )
		table.insert( tab, AdminTag[1] )
		table.insert( tab, AdminTag[2] )
		table.insert( tab, BHOP.Orange )
		table.insert( tab, "] " )
	end
	
	if(ply.GetNWString && ply:GetNWString("RRank",".") != ".") then
		local Ranks = ply:GetNWString("RRank","Unranked")
		local RankColors = ToCol(ply:GetNWString("RCol","255,255,255"))
		table.insert( tab, BHOP.Orange )
		table.insert( tab, "[" )
		table.insert( tab, RankColors )
		local s = gtimer.style or 1
		table.insert( tab, HUDModes[s].." - "..Ranks)
		table.insert( tab, BHOP.Orange )
		table.insert( tab, "] " )
	end
 
	if ( IsValid( ply ) ) then
		if ( bPlayerIsDead && !bTeamOnly ) then
			table.insert( tab, team.GetColor(ply:Team()) )
			table.insert( tab, "*SPEC* " )
		end
		table.insert( tab, ply )
	else
		table.insert( tab, "Console" )
	end
 
	table.insert( tab, BHOP.Orange )
	table.insert( tab, " : "..strText )
 
	chat.AddText( unpack(tab) )
 
	return true
 
end

ViewSet = {}

local function ClientTick()
	if not IsValid( LocalPlayer() ) then timer.Simple( 1, ClientTick ) return end
	timer.Simple( 5, ClientTick )

	local ply = LocalPlayer()
	ply:SetHull( BHOP.HullMin, BHOP.HullStand )
	ply:SetHullDuck( BHOP.HullMin, BHOP.HullCrouch )
	
	if not ViewSet then
		ply:SetViewOffset( BHOP.ViewStand )
		ply:SetViewOffsetDucked( BHOP.ViewCrouch )
		ViewSet = true
	end
	
end
timer.Create("Crouch",1,0,ClientTick)

local speclist = false

net.Receive("RemoveSpectator",function()
	local u = net.ReadString()
	if(GAMEMODE.spectators[u]) then
		GAMEMODE.spectators[u] = nil
	end
	sc = table.Count(GAMEMODE.spectators)
	if(sc >= 1) then
		speclist = true
	else
		speclist = false
	end
end)

net.Receive("SetSpectators",function()
	GAMEMODE.spectators = net.ReadTable()
	sc = table.Count(GAMEMODE.spectators)
	if(sc >= 1) then
		speclist = true
	else
		speclist = false
	end
end)

net.Receive("AddSpectator",function()
	local u = net.ReadString()
	GAMEMODE.spectators[u] = net.ReadString()
	sc = table.Count(GAMEMODE.spectators)
	if(sc >= 1) then
		speclist = true
	else
		speclist = false
	end
end)

net.Receive("UpdateWRPoints",function()
	local t = net.ReadTable()
	for k,v in pairs(t) do
		gtimer.records[1][k]['points'] = v
	end
end)

function GM:CalcView(ply,origin,angles,fov,nz,fz)
	if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && ply:GetObserverTarget():IsBot()) then
		fov = 90
	end

	return self.BaseClass:CalcView(ply,origin,angles,fov,nz,fz)
end

hook.Add("HUDPaintBackground","DrawHUD",function()
	if(!(clshowhud:GetBool())) then return end
	
	local ply = LocalPlayer()
			
	if(ply:Team() == TEAM_SPECTATOR) then
		
		surface.SetDrawColor(BHOP.Title)
		surface.DrawRect(10,10,300,30)
		
		surface.SetDrawColor(BHOP.Back)
		surface.DrawRect(10,40,300,75)

		draw.SimpleText("Spectator Controls","VerdanaUI",170,25,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("Left/Right Click: Cycle through players.","VerdanaUI_B",15,55,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText("Jump Key: Change spectator mode.","VerdanaUI_B",15,75,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText("Reload Key: Toggle freeroam.","VerdanaUI_B",15,95,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		
		if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && (ply:GetObserverMode() != OBS_MODE_ROAMING)) then
			local n = string.sub(ply:GetObserverTarget():Nick(),1,36)
			
			surface.SetFont("VerdanaUI")
			local w, h = surface.GetTextSize(n)
			
			surface.SetDrawColor(BHOP.Title)
			surface.DrawRect(ScrW()/2-(w+20)/2,10,w+20,30)
			
			surface.SetTextColor(BHOP.White)
			surface.SetTextPos( ScrW()/2-w/2, 25-h/2 ) 
			surface.DrawText(n)
		end
	end
	
	local h = sc*18+34
	surface.SetDrawColor(BHOP.Title)
	surface.DrawRect(10,ScrH()-90,200,30)
	surface.DrawRect(220,ScrH()-90,200,30)
	if(speclist) then
		surface.DrawRect(ScrW()-210,(ScrH()/2)-(h/2),200,30)
	end
	
	surface.SetDrawColor(BHOP.Back)
	surface.DrawRect(10,ScrH()-60,200,50)
	surface.DrawRect(220,ScrH()-60,200,50)
	
	if(speclist) then
		surface.DrawRect(ScrW()-210,(ScrH()/2)-(h/2)+30,200,h-30)
	end

	local replay = false
	if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && (ply:GetObserverMode() != OBS_MODE_ROAMING) && ply:GetObserverTarget():IsBot()) then
		replay = true
	end
	
	draw.SimpleText("Speed","VerdanaUI",110,ScrH()-75,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	local style = gtimer.style or 1
	local text = ""
	if(ply.fs) then
		text = " [FS]"
	end
	
	draw.SimpleText(HUDModes[style].." Timer"..text,"VerdanaUI",320,ScrH()-75,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	if gtimer and gtimer.records then
	
	if ply.InSpawn then return end
	
	local style = gtimer.style or 1
	local curtime = CurTime() - (gtimer.start or 0)
	local wrend = 11
	local wrstart = 0
		if gtimer.records[style] then
			for ply,t in pairs(gtimer.records[style]) do
				if curtime < t.time then
					wrend = ply
					break
				end
				wrstart = ply + 1
			end
			if wrend <= 10 or wrstart <= 10 then
				local display = wrend
				if wrend > 10 then display = wrstart end
				draw.SimpleText("("..display..")","VerdanaUI_B",395,ScrH()-75,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
			end
		end
	end

	if(replay) then
		draw.SimpleText("Time:","VerdanaUI_B",230,ScrH()-45,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText("WR:","VerdanaUI_B",230,ScrH()-25,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Current:","VerdanaUI_B",230,ScrH()-45,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText("Best:","VerdanaUI_B",230,ScrH()-25,BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end
	draw.SimpleText(gtimer.GetDisplayTime(),"VerdanaUI_B",410,ScrH()-45,BHOP.White,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	draw.SimpleText(gtimer.GetDisplayPB(),"VerdanaUI_B",410,ScrH()-25,BHOP.White,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	
	if(speclist) then
		draw.SimpleText("Spectators","VerdanaUI",ScrW()-110,(ScrH()/2)-(h/2)+15,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		local i = 0
		for k,v in pairs(GAMEMODE.spectators) do
			i = i + 1
			draw.SimpleText(string.sub(v,1,15),"VerdanaUI_B",ScrW()-205,(ScrH()/2)-(h/2)+32+(16*i),BHOP.White,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		end
	end
	
	surface.SetDrawColor(BHOP.SpeedBack)
	surface.DrawRect(20,ScrH()-50,180,30)
	
	local w = 0
	local v = 0
	
	if(ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && (ply:GetObserverMode() != OBS_MODE_ROAMING)) then
		ply = LocalPlayer():GetObserverTarget()
	end
	
	if(ply && ply:IsValid() && ply.GetVelocity) then
		v = ply:GetVelocity():Length2D()
		local s = (math.min(v,2000))/2000
		w = math.Round(s*180)
	end
	
	v = Format("%.2f",ply:GetVelocity():Length2D(v))
	
	if(w > 0) then
		surface.SetDrawColor(BHOP.Speed)
		surface.DrawRect(20,ScrH()-50,w,30)
	end
	
	draw.SimpleText(v,"VerdanaUI",110,ScrH()-35,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

end)

local function GetAmmo( ply )
	local ply = LocalPlayer()
	local weap = ply:GetActiveWeapon()
	if not weap or not ply:Alive() then return -1 end

	if weap:IsValid() then
		local ammo_inv = weap:Ammo1() or 0
		local ammo_clip = weap:Clip1() or 0
		local ammo_max = weap.Primary.ClipSize or 0

		return ammo_clip, ammo_max, ammo_inv
	end
end

function CS_AMMO_HUD()
	local ply = LocalPlayer()
	
	if ply:GetActiveWeapon().Primary then
		local ammo_clip, ammo_max, ammo_inv = GetAmmo( ply )
		if ammo_clip != -1 then

		surface.SetFont( "CSS_FONT" )

		draw.RoundedBox( 10, ScrW() - 350, ScrH() - 85, 315, 70, BHOP.TransparentLightBlack) -- right
		draw.SimpleText( ammo_clip, "CSS_FONT", ScrW() - 270, ScrH() - 90, BHOP.OrangeDim, TEXT_ALIGN_CENTER )
		draw.SimpleText( "M", "CSS_ICONS", ScrW() - 75, ScrH() -75, BHOP.OrangeDim, TEXT_ALIGN_CENTER ) 
		draw.SimpleText( ammo_inv, "CSS_FONT", ScrW() - 120, ScrH() - 90, BHOP.OrangeDim, TEXT_ALIGN_RIGHT ) 
		draw.RoundedBox( 0, ScrW() - 230, ScrH() - 80, 5, 60, BHOP.OrangeDim )
		end
	end
end
hook.Add( "HUDPaint", "CS_AMMO_HUD", CS_AMMO_HUD )

-- recode

local ModeMenu = false
 
hook.Add("HUDPaintBackground","DrawModes",function()
    if not ModeMenu then return end
    local space = ScrH() /2 - 140
    local a = 32
 
    surface.SetDrawColor(BHOP.Back)
    surface.DrawRect(20, space, 200, 350 )
	
    surface.SetDrawColor(BHOP.Title)
    surface.DrawRect( 20, space, 200, 30 )
 
    draw.SimpleText("Styles - Page 1", "VerdanaUI", 25, space+ 0, BHOP.White, 0, 3)
    draw.SimpleText("1. Normal", "VerdanaUI_B", 25, space+(a*1), BHOP.White, 0, 3)
    draw.SimpleText("2. SW", "VerdanaUI_B", 25, space+(a*2),  BHOP.White, 0, 3)
    draw.SimpleText("3. W-Only", "VerdanaUI_B", 25, space+(a*3), BHOP.White, 0, 3)
    draw.SimpleText("4. HSW", "VerdanaUI_B", 25, space+(a*4),  BHOP.White, 0, 3)
    draw.SimpleText("5. Easy Scroll", "VerdanaUI_B", 25, space+(a*5), BHOP.White, 0, 3)
    draw.SimpleText("6. Legit", "VerdanaUI_B", 25, space+(a*6), BHOP.White, 0, 3)
    draw.SimpleText("7. Practice", "VerdanaUI_B", 25, space+(a*7), BHOP.White, 0, 3)
    draw.SimpleText("8. Bonus", "VerdanaUI_B", 25, space+(a*8), BHOP.White, 0, 3)
    draw.SimpleText("9. Next Page", "VerdanaUI_B", 25, space+(a*9), BHOP.White, 0, 3)
    draw.SimpleText("0. Close", "VerdanaUI_B", 25, space+(a*10), BHOP.White, 0, 3)
 
 
    if input.IsKeyDown( KEY_1 ) then
        RunConsoleCommand("say", "!n")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_2 ) then
        RunConsoleCommand("say", "!sw")
        ModeMenu = false
    end  
    if input.IsKeyDown( KEY_3 ) then
        RunConsoleCommand("say", "!w")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_4 ) then
        RunConsoleCommand("say", "!hsw")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_5 ) then
        RunConsoleCommand("say", "!scroll")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_6 ) then
        RunConsoleCommand("say", "!legit")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_7 ) then
        RunConsoleCommand("say", "Use v key")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_8 ) then
        RunConsoleCommand("say", "!b")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_9 ) then
        RunConsoleCommand("say", "/mode2")
        ModeMenu = false
    end
    if input.IsKeyDown( KEY_0 ) then
        ModeMenu = false
    end 
end)
 
 
net.Receive("ModeMenu", function()
    ModeMenu = true
end)
 
local ModeMenu2 = false
 
hook.Add("HUDPaintBackground","DrawModes2",function()
    if not ModeMenu2 then return end
    local space = ScrH() /2 - 140
    local a = 32
	
    surface.SetDrawColor(BHOP.Back)
    surface.DrawRect(20, space, 200, 350 )
	
    surface.SetDrawColor(BHOP.Title)
    surface.DrawRect( 20, space, 200, 30 )
 
	
    draw.SimpleText("Styles - Page 2", "VerdanaUI", 25, space+ 0, BHOP.White, 0, 3)
    draw.SimpleText("1. Tool-Assisted", "VerdanaUI_B", 25, space+(a*1), BHOP.White, 0, 3)
    draw.SimpleText("2. Stamina", "VerdanaUI_B", 25, space+(a*2),  BHOP.White, 0, 3)
    draw.SimpleText("3. Unreal", "VerdanaUI_B", 25, space+(a*3), BHOP.White, 0, 3)
    draw.SimpleText("4. Pre-Speed", "VerdanaUI_B", 25, space+(a*4),  BHOP.White, 0, 3)
    draw.SimpleText("5. LG Pre-Speed", "VerdanaUI_B", 25, space+(a*5), BHOP.White, 0, 3)
    draw.SimpleText("6. Backwards", "VerdanaUI_B", 25, space+(a*6), BHOP.White, 0, 3)
    draw.SimpleText("7. A-Only", "VerdanaUI_B", 25, space+(a*7), BHOP.White, 0, 3)
    draw.SimpleText("8. D-Only", "VerdanaUI_B", 25, space+(a*8), BHOP.White, 0, 3)
    draw.SimpleText("", "VerdanaUI_B", 25, space+(a*9), BHOP.White, 0, 3)
    draw.SimpleText("0. Close", "VerdanaUI_B", 25, space+(a*10), BHOP.White, 0, 3)
	
	
    if input.IsKeyDown( KEY_1 ) then
        RunConsoleCommand("say", "!tas")
        ModeMenu2 = false
    end
    if input.IsKeyDown( KEY_2 ) then
        RunConsoleCommand("say", "!stam")
        ModeMenu2 = false
    end
    if input.IsKeyDown( KEY_3 ) then
        RunConsoleCommand("say", "not added")
        ModeMenu2 = false
    end
    if input.IsKeyDown( KEY_0 ) then
        ModeMenu2 = false
    end  
end)
 
 
net.Receive("ModeMenu2", function()
    ModeMenu2 = true
end)

-- recode

local function SpecHud()
	local Frame = vgui.Create( "DFrame" )
	Frame:SetTitle( "Spectate menu" )
	Frame:SetSize( 200, 100 )
	Frame:Center()
	Frame:MakePopup()
	Frame.Paint = function( self, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, BHOP.Title )
	end

	local Button = vgui.Create( "DButton", Frame )
	Button:SetText( "Yes/No" )
	Button:SetTextColor(	BHOP.White )
	Button:SetPos( 50, 50 )
	Button:SetSize( 90, 30 )
	Button.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, BHOP.Speed )
	end
	Button.DoClick = function()
		RunConsoleCommand("say", "!spec")
		Frame:Close()
		end
	end
usermessage.Hook("SpecHud", SpecHud)

CreateClientConVar("fov_desired_extended", 0)

local newfov =  GetConVarNumber("fov_desired_extended")

local function fov(ply, ori, ang, fov, nz, fz)
	local view = {}

	view.rigin = ori
	view.angles = ang
	view.fov = newfov

	return view
end

hook.Remove("CalcView", "fov")
timer.Simple(1, function()
	if GetConVarNumber("fov_desired_extended") != 0 then
		hook.Add("CalcView", "fov", fov)
	end
end)

cvars.AddChangeCallback("fov_desired_extended", function() 
	newfov = GetConVarNumber("fov_desired_extended")
	if newfov != 0 then
		hook.Add("CalcView", "fov", fov)
	else
		hook.Remove("CalcView", "fov")
	end
end)