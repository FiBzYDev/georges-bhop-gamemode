gtimer = {}
gtimer.style = 1

local drawWR = false

include('sh_timer.lua')

chat.AddText( BHOP.Orange, "[",BHOP.TimerColor,"Timer",BHOP.Orange, "] Loaded Timer" )

net.Receive("ChatMsg_W",function()
	local text = net.ReadString()
	chat.AddText(BHOP.Orange,"[",BHOP.TimerColor,"Timer",BHOP.Orange,"] "..text)
end)

function gtimer.StartTimer(time)
	gtimer.start = time
end

function gtimer.StopTimer(time)
	gtimer.start = nil
	gtimer.finish = time
end

function gtimer.ResetTimer(time)
	gtimer.start = nil
	gtimer.finish = nil
end

function gtimer.SetPB(time)
	gtimer.pb = time
end

local function GetTime(input,_)
	if not input then input = 0 end
	local h = math.floor(input / 3600)
	local m = math.floor((input / 60) % 60)
	local ms = ( input - math.floor( input ) ) * 100
	local s = math.floor(input % 60)
	return string.format("%02i:%02i:%02i.%02i",h,m,s,ms)
end

local function GetTimeleft(input)
	local t = string.FormattedTime(input)
	local h,m,s,ms
	if(t.h<10) then
		h = "0"..tostring(t.h)
	else
		h = tostring(t.h)
	end
	if(t.m<10) then
		m = "0"..tostring(t.m)
	else
		m = tostring(t.m)
	end
	if(t.s<10) then
		s = "0"..tostring(t.s)
	else
		s = tostring(t.s)
	end
	return h..":"..m..":"..s
end

function gtimer.timeleft(time)
	chat.AddText( BHOP.White, "[",BHOP.TimerColor,"Timer",BHOP.White, "]",BHOP.ChatBox," There is "..GetTimeleft(time).." left on this map.")
end

function gtimer.GetDisplayPB()
	if(!gtimer.pb) then return "00:00:00.00" end
	return GetTime(gtimer.pb)
end

function gtimer.GetDisplayTime(_)
        if(gtimer.start || gtimer.finish) then
                if(gtimer.finish) then
                        local time=gtimer.style == 10 and gtimer.finish * 0.5 or gtimer.finish
                        return GetTime(gtimer.finish,ms)
                else
                        local time=gtimer.style == 10 and ((CurTime()-gtimer.start) * 0.5) or (CurTime()-gtimer.start)
                        return GetTime(time,ms)
                end
        else
                return "00:00:00.00"
        end
end

gtimer.load = false
net.Receive("LoadWRs",function()
	gtimer.load = true
	gtimer.records = net.ReadTable()
	gtimer.minp = 1
	gtimer.maxp = {}
	gtimer.maxp[1] = 1
	gtimer.maxp[2] = 1
	gtimer.maxp[3] = 1
	gtimer.maxp[4] = 1
	gtimer.maxp[5] = 1
	gtimer.maxp[100] = 1
	for k,v in pairs(gtimer.records) do
		gtimer.maxp[k] = math.ceil(#v/10)
	end
end)

local wrtext = ""

net.Receive("OpenOWR",function()
	gtimer.records[101] = net.ReadTable()
	wrtext = net.ReadString()
	gtimer.maxp[101] = math.ceil(#gtimer.records[101]/10)
	gtimer.OpenWR(101)
end)

net.Receive("ModifyWR",function()
	if(gtimer.load) then
		local r = net.ReadInt(16)
		local s = net.ReadInt(8)
		local t = net.ReadFloat()
		local n = net.ReadString()
		if(!gtimer.records[s]) then
			gtimer.records[s] = {}
		end
		if(r != -1) then
			table.remove(gtimer.records[s],r)
		end
		table.insert(gtimer.records[s],{['name'] = n,['time'] = t})
		table.SortByMember(gtimer.records[s], 'time', function(a, b) return a > b end)
		gtimer.maxp[s] = math.ceil(#gtimer.records[s]/10)
	end
end)

local noinput = false
local curpage = 1

local vstyle = 1

function gtimer.OpenWR(id)
	vstyle = id
	curpage = 1
	drawWR = true
	noinput = false
end

function gtimer.CloseWR()
	drawWR = false
end

function surface.GetTextDim(text,font)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	
	return w, h
end

local mat = Material(BHOP.PlacingZoneMaterial)
local Col = BHOP.PlacingColor

hook.Add("PostDrawOpaqueRenderables","DrawPreview",function()
	if(!LocalPlayer():TimerAdmin()) then return end
	if(gtimer.editstep == 2 && gtimer.editpos) then
		local h = gtimer.height or BHOP.ZoneHeight
		local e = gtimer.editpos
		local p = LocalPlayer():GetPos()
		local min = Vector(math.min(e.x,p.x),math.min(e.y,p.y),math.min(e.z,p.z))
		local max = Vector(math.max(e.x,p.x),math.max(e.y,p.y),math.max(e.z,p.z)+h)
		
		local C1, C2, C3, C4, C5, C6, C7, C8 = Vector(min.x, min.y, min.z), Vector(min.x, max.y, min.z), Vector(max.x, max.y, min.z), Vector(max.x, min.y, min.z), Vector(min.x, min.y, max.z), Vector(min.x, max.y, max.z), Vector(max.x, max.y, max.z), Vector(max.x, min.y, max.z) 
		local ww = BHOP.PlacingWith
		
		render.SetMaterial(mat)
		render.DrawBeam(C1, C2, ww, 0, 1, Col) 
		render.DrawBeam(C2, C3, ww, 0, 1, Col)
		render.DrawBeam(C3, C4, ww, 0, 1, Col)
		render.DrawBeam(C4, C1, ww, 0, 1, Col)
		render.DrawBeam(C5, C6, ww, 0, 1, Col) 
		render.DrawBeam(C6, C7, ww, 0, 1, Col)
		render.DrawBeam(C7, C8, ww, 0, 1, Col)
		render.DrawBeam(C8, C5, ww, 0, 1, Col)
		render.DrawBeam(C5, C1, ww, 0, 1, Col) 
		render.DrawBeam(C6, C2, ww, 0, 1, Col)
		render.DrawBeam(C7, C3, ww, 0, 1, Col)
		render.DrawBeam(C8, C4, ww, 0, 1, Col)
	end
end)

local hideall = false

hook.Add("InitPostEntity","savehide",function()
	if(tonumber(cookie.GetNumber("PlayersHiddenGT", 0)) == 1) then
		hideall = true
	end
end)

hook.Add("PrePlayerDraw", "dumbhide", function(ply)
	ply:SetNoDraw(hideall)
	if(hideall) then return true end
end)

function gtimer.ToggleHide()
	local text = ""
	if(hideall) then
		text = "Players are now shown."
		cookie.Set("PlayersHiddenGT", "0")
		hideall = false
	else
		text = "Players are now hidden."
		cookie.Set("PlayersHiddenGT", "1")
		hideall = true
	end
	chat.AddText(BHOP.White,"[",BHOP.TimerColor,"Timer",BHOP.White,"] "..text)
	if(hideall) then
		for _,v in pairs(player.GetAll()) do
			v:SetNoDraw(true)
			v.nd = true
		end
		for _,v in pairs(ents.FindByClass("env_spritetrail")) do
			v:SetNoDraw(true)
		end
		for _,v in pairs(ents.FindByClass("beam")) do
			v:SetNoDraw(true)
		end
	else
		for _,v in pairs(player.GetAll()) do
			v:SetNoDraw(false)
			v.nd = false
		end
		for _,v in pairs(ents.FindByClass("env_spritetrail") ) do
			v:SetNoDraw(false)
		end
		for _,v in pairs(ents.FindByClass("beam")) do
			v:SetNoDraw(false)
		end
	end
end

local off = false

function gtimer.ToggleTrueVel()
	local text = ""
	if(off) then
		text = "Showing velocity."
		RunConsoleCommand("cl_showtruevel", "0")
		off = false
	else
		text = "Showing true velocity."
		RunConsoleCommand("cl_showtruevel", "1")
		off = true
	end
	chat.AddText(BHOP.White,"[",BHOP.TimerColor,"Timer",BHOP.White,"] "..text)
end

hook.Add("OnEntityCreated", "dumbshittytrails", function(ent)
	if hideall && (ent:GetClass() == "env_spritetrail" or ent:GetClass() == "beam") then
		ent:SetNoDraw(true)
	end
end)

hook.Add("HUDPaintBackground","DrawMenu",function()
	if(drawWR) then

		local NW = surface.GetTextDim("1. 10:00:00.00 - GGGGGGGGGGGGGGGGGGGGG","SPF_N")+10
		
		draw.RoundedBox(8, 20, ScrH()-6-128-450, NW, 250, BHOP.TransparentBlack)
		
		local recs = {}
		
		local maxpage = curpage * 10
		local minpage = maxpage - 9
			
			--this ancient code is probably going to never be overly changed, lets face it, im 2layz
			if(gtimer.records[vstyle]) then
				for k,v in pairs(gtimer.records[vstyle]) do
					if(k < minpage) then continue end
					if(k > maxpage) then break end
					recs[k] = v
				end
			end
			if(vstyle == 100) then
				draw.SimpleText("Bonus World Records", "SPF_N", 25, ScrH()-6-128-440, BHOP.Orange, 0, 3)
			elseif(vstyle == 101) then
				draw.SimpleText(wrtext, "SPF_N", 25, ScrH()-6-128-440, BHOP.Orange, 0, 3)
			else
				draw.SimpleText("World Records - "..gtimer.Styles[vstyle].name, "SPF_N", 25, ScrH()-6-128-440, BHOP.Orange, 0, 3)
			end
			local i = 0
			for k,v in pairs(recs) do
				if(curpage==1) then
					i = k
				else
					i = k-((curpage-1)*10)
				end
				draw.SimpleText(k..". "..GetTime(v['time']).." - "..string.sub(v['name'],1,20), "SPF_N", 25, (ScrH()-6-128-440)+16+16*i, BHOP.Orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
				
			if(gtimer.minp && curpage > gtimer.minp) then
				draw.SimpleText("8. Previous", "SPF_N", 25, (ScrH()-6-128-440)+160+22+16, BHOP.Orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			elseif(gtimer.maxp && curpage < gtimer.maxp[vstyle]) then
				draw.SimpleText("9. Next", "SPF_N", 25, (ScrH()-6-128-440)+160+22+32, BHOP.Orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
			
			draw.SimpleText("0. Exit", "SPF_N", 25, (ScrH()-6-128-440)+160+22+16*3, BHOP.Orange, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				
			if(!noinput) then
				if(gtimer.minp && curpage > gtimer.minp && input.IsKeyDown(KEY_8)) then
					noinput = true
					timer.Simple(.2,function() curpage = curpage - 1 end)
					timer.Simple(.5,function() noinput = false end)
				elseif(gtimer.maxp && curpage < gtimer.maxp[vstyle] && input.IsKeyDown(KEY_9)) then
					noinput = true
					timer.Simple(.2,function() curpage = curpage + 1 end)
					timer.Simple(.5,function() noinput = false end)
				elseif(input.IsKeyDown(KEY_0)) then
					noinput = true
					timer.Simple(.2,function() gtimer.CloseWR() end)
				end
			end
	end
end)

usermessage.Hook( "SetStyle", function(umsg)
	gtimer.style = umsg:ReadShort()
	gtimer.SetCheckStyle(LocalPlayer(),gtimer.style)
end)

chat.AddText( BHOP.Orange, "[",BHOP.TimerColor,"Timer",BHOP.Orange, "]",BHOP.ChatBox," Loaded Bots" )

local pm = FindMetaTable("Player")

pm.OldNick = pm.OldNick or pm.Nick

function pm:Nick()
	if(self:IsBot() && tonumber(self:GetNWInt("BOTStyle",0)) != 0) then
		local s = tonumber(self:GetNWInt("BOTStyle",0))
		if(!gtimer.records || !gtimer.records[s] || !gtimer.records[s][1]) then
			return "["..HUDModes[s].."] NO RECORD"
		else
			return "["..HUDModes[s].."] "..string.sub(gtimer.records[s][1]["name"],1,15).." - "..GetTime(gtimer.records[s][1]["time"])
		end
	end
	
	return self:OldNick()
end

local sync = false

net.Receive("SyncMeter",function()
	sync = true

	local e = net.ReadEntity()
	local s = net.ReadDouble()

	e.strafeavg = s
end)

hook.Add("HUDPaint","Sync",function()
	local me = LocalPlayer()
	local ot = me:GetObserverTarget()
	local t = nil
	if ot == me or not ot then
		t = me
	else
		t = ot
	end
	if me:GetNWInt("SyncToggle") == 1 then
		if t.strafeavg then
			local ShowSync = Format("%.2f",t.strafeavg*100)
			draw.SimpleText("Sync: " ..ShowSync,"VerdanaUI",ScrW()-75,ScrH()/2-95,BHOP.White,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
end)