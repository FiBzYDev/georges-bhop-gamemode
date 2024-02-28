util.AddNetworkString("ModifyWR")
util.AddNetworkString("LoadWRs")
util.AddNetworkString("OpenOWR")
util.AddNetworkString("ChatMsg_W")

resource.AddFile(BHOP.DownLoadZoneDirectory)

gtimer = {}
gtimer.areas = {}
gtimer.careas = {}
gtimer.spawnpos = false

local CSt = {}
local WRFrames = {}
local WRFr = {}
local NewWR = {}
local WRBot = {}
local SaveWR = {}

local recording = {}
local RecordP = {}
local StoreFrames = {} --local is better
local Frames = {}
local botpb = {}
local bottime = {}

local LastWep = {}

include('sh_timer.lua')

local botstyles = {}
for k,v in pairs(gtimer.Styles) do
	table.insert(botstyles,k)
end
table.insert(botstyles,100)

function GM:SaveBots()
	for _,s in pairs(botstyles) do
		if(SaveWR && SaveWR[s] && WRFr && WRFr[s]) then
			file.Write("botfiles/"..game.GetMap().."_"..s..".txt", "THISISABOTFILE\n")
			local write = util.TableToJSON(WRFr[s])
			write = util.Compress(write)
			file.Append("botfiles/"..game.GetMap().."_"..s..".txt",write)
			SaveWR[s] = false
		end
	end
end

function GM:ReadWRRun()
	for k,v in pairs(botstyles) do
		WRFrames[v] = 0
		if(!file.IsDir("botfiles","DATA")) then
			file.CreateDir("botfiles","DATA")
		end
		if(file.Exists("botfiles/"..game.GetMap().."_"..v..".txt","DATA")) then
			local str = file.Read("botfiles/"..game.GetMap().."_"..v..".txt","DATA")
			str = string.gsub(str,"THISISABOTFILE\n","")
			str = util.Decompress(str)
			str = util.JSONToTable(str)
			WRFr[v] = str
			WRFrames[v] = #WRFr[v][1]
		end
		self:SpawnBot(v)
	end
end

function GM:SpawnBot(style)
	for k,v in pairs(player.GetAll()) do
		local dont = false
		for _,s in pairs(botstyles) do
			if(WRBot[s] == v) then
				dont = true
				break
			end
		end
		if(v:IsBot() && !dont) then
			WRBot[style] = v
			v:SetNWInt("BOTStyle",style)
			v.Style = style
			if(style == 100) then
				v.bonus = true
			end
			if(gtimer.records and gtimer.records[style] && gtimer.records[style][1]) then -- Another day saved by itzaname!
				if(style == 100) then
					v.bpb = gtimer.records[style][1]['time']
					v:SendPB(v.bpb)
				else
					v.pb = {}
					v.pb[style] = gtimer.records[style][1]['time']
					v:SendPB(v.pb[style])
				end
				botpb[v] = gtimer.records[style][1]['time']
			end
			if(v:GetMoveType() != 0) then
				v:SetMoveType(0)
				v:SetCollisionGroup(1)
				v:SetGravity(0)
			end
		end
	end
	if(WRBot[style] && WRBot[style]:IsValid()) then return end
	RunConsoleCommand("bot")
	timer.Simple(0.5,function()
		for k,v in pairs(player.GetAll()) do
			local dont = false
			for _,s in pairs(botstyles) do
				if(WRBot[s] == v) then
					dont = true
					break
				end
			end
			if(v:IsBot() && !dont) then
				WRBot[style] = v
				v:SetNWInt("BOTStyle",style)
				v.Style = style
				if(style == 100) then
					v.bonus = true
				end
				if(gtimer.records[style] && gtimer.records[style][1]) then
					if(style == 100) then
						v.bpb = gtimer.records[style][1]['time']
						v:SendPB(v.bpb)
					else
						v.pb = {}
						v.pb[style] = gtimer.records[style][1]['time']
						v:SendPB(v.pb[style])
					end
					botpb[v] = gtimer.records[style][1]['time']
				end
				if(v:GetMoveType() != 0) then
					v:SetMoveType(0)
					v:SetCollisionGroup(1)
					v:SetGravity(0)
				end
			end
		end
	end)
end

function gtimer.AddText(p,text)
	p:SendLua('chat.AddText(BHOP.Orange,"[",BHOP.TimerColor,"Timer",BHOP.Orange,"] '..text..'")')
end

function gtimer.SetRecord(p,r)
	RecordP[p] = r
end

function gtimer.Chat(text)
	net.Start("ChatMsg_W")
	net.WriteString(text)
	net.Broadcast()
end

local pm = FindMetaTable("Player")

function pm:StartTimer()
	if(self.gtimer) then return end
	if(!self:IsBot() && self:GetVelocity():Length2D() > 300) then return end
	if(game.GetMap() == "bhop_it_nine-up" || game.GetMap() == "bhop_thc_egypt") then self:SetName("jump3") end
	if(self.Style == 5) then
		self.cppos = nil
		self.cpang = nil
	end
	Frames[self] = 0
	RecordP[self] = true
	recording[self] = true
	
	self.gtimer = CurTime()
	if(self:IsBot()) then bottime[self] = self.gtimer end
	self:SendLua("gtimer.StartTimer("..self.gtimer..")")
	self:SendStart(self.gtimer)
	if self.Style != 8 then self:SetGravity(1) end
end

local function GetTime(input,_) --incase i called it with the ms arg anywhere
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
	local sms = math.Round(t.ms)
	if(sms<10) then
		ms = "0"..tostring(sms)
	else
		ms = tostring(sms)
	end
	return h..":"..m..":"..s.."."..ms
end

function pm:StopTimer(finish,bonus,rig)
	if(!self.gtimer || self.finishtime) then return end
	RecordP[self] = false
	self.finishtime = CurTime() - self.gtimer
	if(self:IsBot()) then
		self.finishtime = rig
	end
	self:SendLua("gtimer.StopTimer("..self.finishtime..")")
	self:SendEnd(self.finishtime)
	if(finish) then
		self.finishtime=(self.Style == 10 and not self.bonus) and (self.finishtime * 0.5) or self.finishtime
		--print'rekr'
		--print(self.Style)
		--print(self.finishtime)
		local d = self.finishtime
		local r = false
		local pb = self:GetPB(self.Style,bonus)
		local ispb = false
		local u = self:UniqueID()
		
		local cond = false
		if(bonus && !self.bpb) then
			cond = true
		elseif(!bonus && (!self.pb || !self.pb[self.Style])) then
			cond = true
		end
		
		if(cond || pb == 0) then
			local b = 0
			if(bonus) then
				b = 1
			end
			sql.Query("INSERT INTO bh_worldrecords (`unique_id`,`name`,`map_name`,`time`,`type`,`bonus`) VALUES ('"..u.."',"..sql.SQLStr(self:Nick())..",'"..game.GetMap().."','"..self.finishtime.."','"..self.Style.."','"..b.."')")
			ispb = true
			if(bonus) then
				self.bpb = self.finishtime
				self:SendLua("gtimer.SetPB("..tonumber(self.bpb)..")")
			else
				self.pb[self.Style] = self.finishtime
				self:SendLua("gtimer.SetPB("..tonumber(self.pb[self.Style])..")")
			end
			self:SendPB(self.finishtime)
		elseif(self.finishtime < pb) then
			local b = 0
			if(bonus) then
				b = 1
			end
			sql.Query("UPDATE bh_worldrecords SET `time`='"..self.finishtime.."',`name`="..sql.SQLStr(self:Nick()).." WHERE `type`='"..self.Style.."' AND `unique_id`='"..u.."' AND `bonus`='"..b.."' AND `map_name`='"..game.GetMap().."'")
			ispb = true
			if(bonus) then
				self.bpb = self.finishtime
				self:SendLua("gtimer.SetPB("..tonumber(self.bpb)..")")
			else
				self.pb[self.Style] = self.finishtime
				self:SendLua("gtimer.SetPB("..tonumber(self.pb[self.Style])..")")
			end
			self:SendPB(self.finishtime)
		end
		
		--[[if(tonumber(self:GetPData("Complete_map_"..game.GetMap(),0)) == 0) then
			local pts = GAMEMODE:GetPoints(game.GetMap())
			if(pts != 0) then
				self:SetPData("Complete_map_"..game.GetMap(),1)
				local p = self.Points
				self.Points = self.Points + pts
				if(p == 0) then
					sql.Query("INSERT INTO timer_points (uniqueid,points) VALUES ('"..u.."','"..self.Points.."')")
				else
					sql.Query("UPDATE timer_points SET points='"..self.Points.."' WHERE uniqueid='"..u.."'")
				end
				
				self:SetNWInt("Points",self.Points)
				
			end
		end]]
		
		local rem = 0
		local pos = 0
		
		if(!gtimer.records) then
			gtimer.records = {}
		end
		
		local ps = self.Style
		
		if(bonus) then
			ps = 100
		end
		
		if(!gtimer.records[ps]) then
			gtimer.records[ps] = {}
		end
		
		if(ispb) then
			for k,v in pairs(gtimer.records[ps]) do
				if(v['unique_id'] == u) then
					rem = k
				end
			end
			if(rem != 0) then
				table.remove(gtimer.records[ps],rem)
			end
			if(rem == 0) then
				rem = -1
			end
			local i = {['unique_id'] = u,['name'] = self:Nick(),['time'] = self.finishtime}
			local is = {}
			table.insert(gtimer.records[ps],i)
			table.SortByMember(gtimer.records[ps], 'time', function(a, b) return a > b end)
			for k,v in pairs(gtimer.records[ps]) do
				if(v['unique_id'] == u) then
					pos = k
				end
			end
			net.Start("ModifyWR")
			net.WriteInt(tonumber(rem),16)
			net.WriteInt(ps,8)
			net.WriteFloat(self.finishtime)
			net.WriteString(tostring(self:Nick()))
			net.Broadcast()
			
			if(ps == 1) then
				GAMEMODE:UpdatePoints()
			end
			
			if(pos == 1 && StoreFrames[self]) then
				WRFr[ps] = StoreFrames[self]
				WRFrames[ps] = #WRFr[ps][1]
				NewWR[ps] = true
				SaveWR[ps] = true
			
				GAMEMODE:SpawnBot(ps)
				if(WRBot[ps] && WRBot[ps]:IsValid()) then
					if(bonus) then
						WRBot[ps].bpb = self.finishtime
						WRBot[ps].bonus = true
					else
						WRBot[ps].pb = {}
						WRBot[ps].pb[ps] = self.finishtime
					end
					WRBot[ps]:SendPB(self.finishtime)
					botpb[WRBot[ps]] = self.finishtime
				end
			end
			
			if(!self.rrank) then
				GAMEMODE:LoadRank(self,u)
			end
		end
		StoreFrames[self] = nil
		Frames[self] = 0
		
		if(pb) then
			d = d - pb
		end
		
		if(d > 0) then
			d = "+"..GetTime(d)
		else
			d = "-"..GetTime(-1*d)
		end
		
		if(ispb) then
			if(bonus) then
				gtimer.Chat(self:Nick().." has finished the Bonus in "..GetTime(self.finishtime).." ("..d..") ["..pos.."/"..#gtimer.records[ps].."]")
			else
				gtimer.Chat(self:Nick().." has finished on "..gtimer.Styles[ps].name.." in "..GetTime(self.finishtime).." ("..d..") ["..pos.."/"..#gtimer.records[ps].."]")
			end
		else
			if(bonus) then
				gtimer.Chat(self:Nick().." has finished the Bonus in "..GetTime(self.finishtime).." ("..d..")")
			else
				gtimer.Chat(self:Nick().." has finished on "..gtimer.Styles[ps].name.." in "..GetTime(self.finishtime).." ("..d..")")
			end
		end
	end
end

function pm:GetPB(id,bonus)
	if(bonus) then
		return self.bpb and self.bpb or 0
	end
	return self.pb[id] and self.pb[id] or 0
end

function pm:ResetTimer()
	if(!self.gtimer) then return end
	
	self.gtimer = nil
	self.finishtime = nil
	Frames[self] = 0
	StoreFrames[self] = nil
	self:SendLua("gtimer.ResetTimer()")
	self:SendRestart()
	if self.Style != 8 then self:SetGravity(1) end
end

hook.Add( "KeyPress", "Timer_SuperEditor", function(ply,key)
	if(ply.editmode && key == IN_ATTACK) then
		if(!ply.za1) then
			local p = ply:GetPos()
			ply.za1 = p
			if(!ply.zheight) then
				ply.zheight = BHOP.ZoneHeight
			end
			ply:SendLua("gtimer.editpos = Vector("..p.x..","..p.y..","..p.z..")")
			ply:SendLua("gtimer.height = "..ply.zheight)
			ply:SendLua("gtimer.editstep = 2")
		else
			local p = ply:GetPos()
			local p2 = ply.za1
			
			ply:SendLua("gtimer.editpos = nil")
			ply:SendLua("gtimer.editstep = 0")
			local mi = math.Round(math.min(p.x,p2.x))..","..math.Round(math.min(p.y,p2.y))..","..math.Round(math.min(p.z,p2.z))
			local ma = math.Round(math.max(p.x,p2.x))..","..math.Round(math.max(p.y,p2.y))..","..math.Round(math.max(p.z,p2.z))+ply.zheight
			local t = ply.type
			if(ply.bedit) then
				t = ply.type + 4
			end
			if(ply.customz) then
				if(!ply.cdata) then
					ply.cdata = ""
				end
				sql.Query("INSERT INTO customzones (`map_name`,`type`,`min`,`max`,`data`) VALUES ('"..game.GetMap().."','"..t.."','"..mi.."','"..ma.."','"..ply.cdata.."')")
			
				local r = sql.Query("SELECT `id` FROM customzones WHERE `min`='"..mi.."' AND `map_name`='"..game.GetMap().."'")
				if(r && r[1]) then
					gtimer.AddText(ply,"Successfuly created "..gtimer.customz[ply.type].Name.." with id "..r[1]['id'])
					gtimer.CreateCustomArea(ply.type,mi,ma,tonumber(r[1]['id']),ply.cdata)
				else
					gtimer.AddText(ply,"Oops! Try again!")
				end
				ply.cdata = ""
			else
				sql.Query("INSERT INTO timerareas (`map_name`,`type`,`min`,`max`) VALUES ('"..game.GetMap().."','"..t.."','"..mi.."','"..ma.."')")
			
				local r = sql.Query("SELECT `id` FROM timerareas WHERE `min`='"..mi.."' AND `map_name`='"..game.GetMap().."'")
				if(r && r[1]) then
					gtimer.AddText(ply,"Successfuly created a"..gtimer.areatypes[ply.type].." with id "..r[1]['id'])
					gtimer.CreateArea(ply.type,mi,ma,tonumber(r[1]['id']),ply.bedit)
				else
					gtimer.AddText(ply,"Oops! Try again!")
				end
				ply.bedit = false
			end
			ply.za1 = nil
			ply.editmode = false
		end
	end
end)

local cache = {}
local function SendOWR(ply,map,s)
	if(map == game.GetMap()) then
		ply:SendLua("gtimer.OpenWR("..s..")")
		return
	end
	if(cache[map] && cache[map][s]) then
		local text = ""
		if(s == 100) then
			text = "Bonus World Records - "..map
		else
			text = "World Records - "..gtimer.Styles[s].name.." - "..map
		end
		net.Start("OpenOWR")
		net.WriteTable(cache[map][s])
		net.WriteString(text)
		net.Send(ply)
	else
		local q = ""
		if(s == 100) then
			q = "SELECT * FROM bh_worldrecords WHERE `map_name`='"..map.."' AND `bonus`='1' ORDER BY `time`"
		else
			q = "SELECT * FROM bh_worldrecords WHERE `map_name`='"..map.."' AND `type`='"..s.."' AND `bonus`='0' ORDER BY `time`"
		end
		local data = sql.Query(q)
		if(!data || !data[1]) then
			gtimer.AddText(ply,"No WRs found on "..map..".")
			return
		end
		if(!cache[map]) then cache[map] = {} end
		cache[map][s] = data
		local text = ""
		if(s == 100) then
			text = "Bonus World Records - "..map
		else
			text = "World Records - "..gtimer.Styles[s].name.." - "..map
		end
		net.Start("OpenOWR")
		net.WriteTable(data)
		net.WriteString(text)
		net.Send(ply)
	end
end

concommand.Add("bh_restart",function(p,cmd,args) 
	p:SetTeam(TEAM_BHOP)
	p:KillSilent()
	p:Spawn()
end)

local function FindPlayer(text)
	local p = {}
	for k,v in pairs(player.GetAll()) do
		if(string.find(string.lower(v:Nick()),text)) then
			table.insert(p,v)
		end
	end
	if(#p < 1) then return "No matching players found." end
	if(#p > 1) then return "More than one matching player found." end
	return p[1]
end

local aslots = 3


local onground = {}

hook.Add("OnPlayerHitGround","timer_cponground",function(ply)
	onground[ply] = false
	timer.Simple(0.1,function()
		if(ply:OnGround()) then
			onground[ply] = true
		end
	end)
end)

hook.Add("SetupMove","timer_cpcheckground",function(ply)
	if(onground[ply] && !ply:OnGround()) then
		onground[ply] = false
	end
end)

hook.Add("PlayerSay","Timer_Say",function(ply,text,p)
	local t = string.lower(text)
	
	for k,v in pairs(gtimer.Styles) do
		if(t == v.cmd) then
			if(ply:Team() != TEAM_SPECTATOR) then
				gtimer.SetStyle(ply,k)
				if(ply.bonus || ply.gtimer || ply.finishtime) then
					ply:SetTeam(TEAM_BHOP)
					ply:KillSilent()
					ply:Spawn()
					if(LastWep[ply] && LastWep[ply] != ply:GetActiveWeapon():GetClass()) then
						ply:Give(LastWep[ply])
						ply:SelectWeapon(LastWep[ply])
					end
					if(ply.bonus) then
						timer.Simple(0.02,function()
							ply:ResetTimer()
							gtimer.SetBonus(ply,false)
							ply.bonus = false
						end)
					end
				end
				gtimer.AddText(ply,"Switched to "..gtimer.Styles[k].name)
			end
			return ""
		end
	end	

	if(t == "!cp" || t == "/cp") then
		gtimer.AddText(ply,"CheckPoint style is not enabled on this map!")
		return ""
	elseif(t == "/r" || t == "!r" || t == "/restart" || t == "!restart") then
		if(ply:Team() != TEAM_SPECTATOR) then
			ply:SetTeam(TEAM_BHOP)
			ply:KillSilent()
			ply:Spawn()
			local c = ply:GetActiveWeapon()
			if(!ply.stripped && LastWep[ply] && IsValid(c) && LastWep[ply] != c:GetClass()) then
				ply:Give(LastWep[ply])
				ply:SelectWeapon(LastWep[ply])
			end
			timer.Simple(0.02,function()
				ply:ResetTimer()
				gtimer.SetBonus(ply,false)
				ply.bonus = false
			end)
		end
		return ""
	elseif(t == "/hide" || t == "!hide" || t == "!show" || t == "/show") then
		ply:SendLua("gtimer.ToggleHide()")
		return ""
	elseif(t == "/b" || t == "!b" || t == "!bonus" || t == "/bonus") then
		if(!gtimer.bonuspos) then
			gtimer.AddText(ply,"There is no Bonus for this map.")
			return ""
		end
		if(ply:Team() != TEAM_SPECTATOR) then
			ply:SetTeam(TEAM_BHOP)
			ply:KillSilent()
			ply:Spawn()
			ply:SetGroundEntity(nil)
			ply:RemoveFlags(FL_ONGROUND)
			ply:SetPos(gtimer.bonuspos[1])
			ply:SetEyeAngles(Angle(0,gtimer.bonuspos[2].y,0))
			local c = ply:GetActiveWeapon()
			if(!ply.stripped && LastWep[ply] && IsValid(c) && LastWep[ply] != c:GetClass()) then
				ply:Give(LastWep[ply])
				ply:SelectWeapon(LastWep[ply])
			end
			timer.Simple(0.02,function()
				ply:ResetTimer()
				gtimer.SetBonus(ply,true)
				ply.bonus = true
			end)
			
		end
		return ""
	elseif(t == "!help" || t == "/help" || t == "!help 1" || t == "/help 1") then
		gtimer.AddText(ply,"Commands:")
		gtimer.AddText(ply,"!normal | !sw | !w | !hsw - Changes your style.")
		gtimer.AddText(ply,"!wr | !wrsw | !wrw | !wrhsw - Opens World Records pages.")
		gtimer.AddText(ply,"!r or !restart - Respawns you at the beginning of the map.")
		gtimer.AddText(ply,"!b - Respawns you at the bonus.")
		gtimer.AddText(ply,"Type !help 2 for the next page of commands.")
		
		return ""
	elseif(t == "!help 2" || t == "/help 2") then
		gtimer.AddText(ply,"Commands (Page 2):")
		gtimer.AddText(ply,"!spec - Toggles spectator.")
		gtimer.AddText(ply,"!hide - Toggles player visibility.")
		gtimer.AddText(ply,"!ranks - Shows available ranks and your rank.")
		return ""
	elseif(t == "!truevel" || t == "/truevel" || t == "/normalvel" || t == "/normalvel") then
		ply:SendLua("gtimer.ToggleTrueVel()")
		return ""
	elseif(t == "/wr" || t == "!wr") then
		ply:SendLua("gtimer.OpenWR(1)")
		return ""
	elseif(t == "/wrsw" || t == "!wrsw") then
		ply:SendLua("gtimer.OpenWR(2)")
		return ""
	elseif(t == "/wrw" || t == "!wrw") then
		ply:SendLua("gtimer.OpenWR(3)")
		return ""
	elseif(t == "/wrhsw" || t == "!wrhsw") then
		ply:SendLua("gtimer.OpenWR(4)")
		return ""
	elseif((t == "/wrcp" || t == "!wrcp")) then
		if(gtimer.cpenable) then
			ply:SendLua("gtimer.OpenWR(5)")
			return ""
		end
		gtimer.AddText(ply,"CheckPoint style is not enabled on this map!")
		return ""
	elseif((t == "/wrstam" || t == "!wrstam")) then
		ply:SendLua("gtimer.OpenWR(6)")
		return ""
	elseif((t == "/wrlegit" || t == "!wrlegit")) then
		ply:SendLua("gtimer.OpenWR(7)")
		return ""
	elseif((t == "/wrlg" || t == "!wrlg")) then
		ply:SendLua("gtimer.OpenWR(8)")
		return ""
	elseif((t == "/wrscroll" || t == "!wrscroll")) then
		ply:SendLua("gtimer.OpenWR(9)")
		return ""
	elseif(t == "/bwr" || t == "!bwr") then
		ply:SendLua("gtimer.OpenWR(100)")
		return ""
	elseif(string.sub(t,1,6) == "/wrcp " || string.sub(t,1,6) == "!wrcp ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		if(!gtimer.HasCPStyle(a[1])) then
			gtimer.AddText(ply,"CheckPoint style is not enabled on that map!")
			return ""
		end
		SendOWR(ply,a[1],5)
		return ""
	elseif(string.sub(t,1,4) == "/wr " || string.sub(t,1,4) == "!wr ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],1)
		return ""
	elseif(string.sub(t,1,6) == "/wrsw " || string.sub(t,1,6) == "!wrsw ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],2)
		return ""
	elseif(string.sub(t,1,5) == "/wrw " || string.sub(t,1,5) == "!wrw ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],3)
		return ""
	elseif(string.sub(t,1,7) == "/wrhsw " || string.sub(t,1,7) == "!wrhsw ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],4)
		return ""
	elseif(string.sub(t,1,8) == "/wrstam " || string.sub(t,1,8) == "!wrstam ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],6)
		return ""
	elseif(string.sub(t,1,9) == "/wrlegit " || string.sub(t,1,9) == "!wrlegit ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],7)
		return ""
	elseif(string.sub(t,1,6) == "/wrlg " || string.sub(t,1,6) == "!wrlg ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],8)
		return ""
	elseif(string.sub(t,1,10) == "/wrscroll " || string.sub(t,1,10) == "!wrscroll ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],9)
		return ""
	elseif(string.sub(t,1,5) == "/bwr " || string.sub(t,1,5) == "!bwr ") then
		local a = string.Explode(" ",t)
		table.remove(a,1)
		if(#a != 1) then
			gtimer.AddText(ply,"Incorrect number of arguments.")
			return ""
		end
		if(!table.HasValue(RTV.GetMaps(),a[1])) then
			gtimer.AddText(ply,"Map not found.")
			return ""
		end
		SendOWR(ply,a[1],100)
		return ""
	elseif(string.sub(t,1,11) == "!setzheight" && ply:TimerAdmin()) then	
		local args = string.Explode(" ",t)
		if(#args != 2) then
			gtimer.AddText(ply,"Incorrect arguments for !setzheight")
			return ""
		end
		ply.zheight = args[2]
		return ""
	elseif(string.sub(t,1,8) == "!addarea" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if(#args == 1) then
			gtimer.AddText(ply,"Incorrect arguments for !addarea")
			return ""
		end
		if(ply.editmode) then
			gtimer.AddText(ply,"Currently using !addarea")
			return ""
		end
		table.remove(args,1)
		if(#args > 2) then
			gtimer.AddText(ply,"Incorrect arguments for !addarea")
			return ""
		end
		if(type(tonumber(args[1])) != "number" || tonumber(args[1]) == 0) then
			gtimer.AddText(ply,"Incorrect arguments for !addarea")
			return ""
		end
		if(args[2] && args[2] != "b") then
			gtimer.AddText(ply,"Incorrect arguments for !addarea")
			return ""
		end
		if(tonumber(args[1]) > 3) then
			gtimer.AddText(ply,"Incorrect arguments for !addarea")
			return ""
		end
		ply:SendLua("gtimer.editstep = 1")
		ply.editmode = true
		ply.type = tonumber(args[1])
		ply.bedit = false
		if(args[2]) then
			ply.bedit = true
		end
		return ""
	elseif(string.sub(t,1,6) == "!addcz" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if(#args == 1) then
			gtimer.AddText(ply,"Incorrect arguments for !addcz")
			return ""
		end
		if(ply.editmode) then
			gtimer.AddText(ply,"Currently using !addcz")
			return ""
		end
		table.remove(args,1)
		if(#args > 2) then
			gtimer.AddText(ply,"Incorrect arguments for !addcz")
			return ""
		end
		if(type(tonumber(args[1])) != "number" || tonumber(args[1]) == 0) then
			gtimer.AddText(ply,"Incorrect arguments for !addcz")
			return ""
		end
		if(!gtimer.customz[tonumber(args[1])]) then
			gtimer.AddText(ply,"No zone type with ID "..tonumber(args[1]))
			return ""
		end

		ply:SendLua("gtimer.editstep = 1")
		ply.editmode = true
		ply.type = tonumber(args[1])
		ply.customz = true
		ply.cdata = args[2]
		return ""
	elseif(string.sub(t,1,6) == "!delcz" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if(#args == 1) then
			gtimer.AddText(ply,"Incorrect arguments for !delcz")
			return ""
		end
		if(ply.editmode) then
			gtimer.AddText(ply,"Currently using !addcz")
			return ""
		end
		table.remove(args,1)
		if(#args > 1) then
			gtimer.AddText(ply,"Incorrect arguments for !delcz")
			return ""
		end
		if(type(tonumber(args[1])) != "number" || tonumber(args[1]) == 0) then
			gtimer.AddText(ply,"Incorrect arguments for !delcz")
			return ""
		end
		local i = tonumber(args[1])
		local a = nil
		local r = 0
		
		if(gtimer.careas) then
			a = gtimer.careas[i]
		end
		if(a && a:IsValid()) then
			sql.Query("DELETE FROM customzones WHERE `id`='"..i.."'")
			table.remove(gtimer.careas,i)
			a:Remove()
		else
			gtimer.AddText(ply,"No custom zone with id "..args[1].." found")
		end
		return ""
	elseif(string.sub(t,1,10) == "!setczdata" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if(#args == 1) then
			gtimer.AddText(ply,"Incorrect arguments for !setczdata")
			return ""
		end
		if(ply.editmode) then
			gtimer.AddText(ply,"Currently using !addcz")
			return ""
		end
		table.remove(args,1)
		if(#args > 2) then
			gtimer.AddText(ply,"Incorrect arguments for !setczdata")
			return ""
		end
		if(type(tonumber(args[1])) != "number" || tonumber(args[1]) == 0) then
			gtimer.AddText(ply,"Incorrect arguments for !setczdata")
			return ""
		end
		local i = tonumber(args[1])
		local a = nil
		local r = 0
		
		if(gtimer.careas) then
			a = gtimer.careas[i]
		end
		if(a && a:IsValid()) then
			a.data = args[2]
			a:Spawn()
			sql.Query("UPDATE customzones SET `data`='"..args[2].."' WHERE `id`='"..i.."'")
		else
			gtimer.AddText(ply,"No custom zone with id "..args[1].." found")
		end
		return ""
	elseif(t == "!listczids" && ply:TimerAdmin()) then
		gtimer.AddText(ply,"Custom Zone IDS:")
		for k,v in pairs(gtimer.careas) do
			if(IsValid(gtimer.careas[k])) then
				gtimer.AddText(ply,k.." = "..gtimer.customz[v.ztype].Name)
			end
		end
		return ""
	elseif(t == "!cpsave" || t == "/cpsave") then
		if(ply.InSpawn) then
			gtimer.AddText(ply,"Checkpoint Saving Failed.")
			return ""
		end
		if(ply.Style == 5 && !ply.bonus) then
			if(onground[ply]) then
				ply.cppos = ply:GetPos()
				ply.cpang = ply:EyeAngles()
				gtimer.AddText(ply,"Checkpoint Saved!")
			else
				gtimer.AddText(ply,"Checkpoint Saving Failed.")
			end
		else
			ply.cppos = ply:GetPos()
			ply.cpang = ply:EyeAngles()
			ply.cpvel = ply:GetVelocity()
			gtimer.AddText(ply,"Checkpoint Saved!")
		end
		return ""
	elseif(t == "!cpload" || t == "/cpload") then
		if(!ply.cppos) then
			gtimer.AddText(ply,"No checkpoint found!")
			return ""
		end
		if(ply.Style == 5 && !ply.bonus) then
			ply:SetPos(ply.cppos)
			ply:SetEyeAngles(ply.cpang)
			ply:SetLocalVelocity(Vector(0,0,0))
			gtimer.AddText(ply,"Checkpoint Loaded!")
		else
			if(ply.InSpawn) then
				gtimer.AddText(ply,"Checkpoint Loading Failed!")
				return ""
			end
			ply:StopTimer(false)
			ply:SetPos(ply.cppos)
			ply:SetEyeAngles(ply.cpang)
			ply:SetLocalVelocity(ply.cpvel)
			gtimer.AddText(ply,"Checkpoint Loaded!")
		end
		return ""
	elseif(t == "!listareaids" && ply:TimerAdmin()) then
		gtimer.AddText(ply,"Area IDS:")
		for k,v in pairs(gtimer.areas) do
			if(IsValid(gtimer.areas[k])) then
				if(gtimer.areas[k].bonus) then
					gtimer.AddText(ply,k.." = A"..gtimer.areatypes[v.ztype].." for bonus")
				else
					gtimer.AddText(ply,k.." = A"..gtimer.areatypes[v.ztype])
				end
			end
		end
		return ""
	elseif(t == "!setspawn" && ply:TimerAdmin()) then
		local pos = ply:GetPos()
		local p = Vector(math.Round(pos.x),math.Round(pos.y),math.Round(pos.z))
		local ang = ply:GetAngles()
		local a = Angle(math.Round(ang.p),math.Round(ang.y),math.Round(ang.r))
		if(!gtimer.spawnpos) then	
			sql.Query("INSERT INTO timerareas (`map_name`,`type`,`min`,`max`) VALUES('"..game.GetMap().."','4','"..p.x..","..p.y..","..p.z.."','"..a.p..","..a.y..","..a.r.."')")
		else
			sql.Query("UPDATE timerareas SET `min`='"..p.x..","..p.y..","..p.z.."', `max`='"..a.p..","..a.y..","..a.r.."' WHERE `map_name`='"..game.GetMap().."' AND `type`='4'")
		end
		for k,v in pairs(gtimer.Spawns) do
			v:SetPos(p)
			v:SetAngles(a)
		end
		gtimer.spawnpos = true
		gtimer.AddText(ply,"Spawn Set!")
		return ""
	elseif(t == "!remove" || t == "/remove") then
		ply:StripWeapons()
		ply.stripped = true
		return ""
	elseif(t == "!strip" || t == "/strip") then
		ply:StripWeapons()
		ply.stripped = true
		return ""
	elseif(t == "!usp" || t == "/usp") then
		ply:Give("weapon_usp")
		ply.stripped = false
		return ""
	elseif(t == "!glock" || t == "/glock") then
		ply:Give("weapon_glock")
		ply.stripped = false
		return ""
	elseif(t == "!crowbar" || t == "/crowbar") then
		ply:Give("weapon_crowbar")
		ply.stripped = false
		return ""
	elseif(t == "!p90" || t == "/p90") then
		ply:Give("weapon_p90")
		ply.stripped = false
		return ""
	elseif(t == "!setbspawn" && ply:TimerAdmin()) then
		local pos = ply:GetPos()
		local p = Vector(math.Round(pos.x),math.Round(pos.y),math.Round(pos.z))
		local ang = ply:GetAngles()
		local a = Angle(math.Round(ang.p),math.Round(ang.y),math.Round(ang.r))
		if(!gtimer.bonuspos) then	
			sql.Query("INSERT INTO timerareas (`map_name`,`type`,`min`,`max`) VALUES('"..game.GetMap().."','8','"..p.x..","..p.y..","..p.z.."','"..a.p..","..a.y..","..a.r.."')")
		else
			sql.Query("UPDATE timerareas SET `min`='"..p.x..","..p.y..","..p.z.."', `max`='"..a.p..","..a.y..","..a.r.."' WHERE `map_name`='"..game.GetMap().."' AND `type`='8'")
		end
		gtimer.bonuspos = {p,a}
		gtimer.AddText(ply,"Bonus Spawn Set!")
		return ""
	elseif(string.sub(t,1,8) == "!delarea" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if(#args == 1) then
			gtimer.AddText(ply,"Incorrect arguments for !delarea")
			return ""
		end
		if(ply.editmode) then
			gtimer.AddText(ply,"Currently using !addarea")
			return ""
		end
		table.remove(args,1)
		if(#args > 1) then
			gtimer.AddText(ply,"Incorrect arguments for !delarea")
			return ""
		end
		if(type(tonumber(args[1])) != "number" || tonumber(args[1]) == 0) then
			gtimer.AddText(ply,"Incorrect arguments for !delarea")
			return ""
		end
		local i = tonumber(args[1])
		local a = nil
		local r = 0
		
		if(gtimer.areas) then
			a = gtimer.areas[i]
		end
		if(a && a:IsValid()) then
			sql.Query("DELETE FROM timerareas WHERE `id`='"..i.."'")
			table.remove(gtimer.areas,i)
			a:Remove()
		else
			gtimer.AddText(ply,"No area with id "..args[1].." found")
		end
		return ""
	elseif(string.sub(t,1,11) == "!removetime" && ply:TimerAdmin()) then
		local args = string.Explode(" ",t)
		if #args < 2 then
			gtimer.AddText(ply,"Incorrect arguments for !removetime [style] [nr]")
			return ""
		else
			local s1 = tonumber(args[2])
			local s2 = tonumber(args[3])
			if not s1 or not s2 then
				gtimer.AddText(ply,"Incorrect arguments for !removetime (have to be both numbers)")
				return ""
			end
			
			if s1 < 1 or (s1 > 5 and s1 != 100) then
				gtimer.AddText(ply,"Incorrect style number entered (1 = Normal, 2 = SW, 3 = W-Only, 4 = HSW, 5 = Bonus, 100 = Bonus)")
				return ""
			end
			
			local suid, tuid = nil, nil
			for i,d in pairs(gtimer.records[s1]) do
				if i == s2 then
					if d['unique_id'] and type(d['unique_id']) == "string" then
						suid = tonumber(d['unique_id'])
					end
					tuid = i
					break
				end
			end
			
			if not suid then
				gtimer.AddText(ply,"No time found for this style")
				return ""
			else
				gtimer.AddText(ply,"Record found")
				sql.Query( "DELETE FROM bh_worldrecords WHERE map_name = '" .. game.GetMap() .. "' AND unique_id = " .. suid .. " AND type = " .. s1 )
				if tuid then table.remove(gtimer.records[s1], tuid) end
				gtimer.AddText(ply,"Record removed from table")
				
				if s2 == 1 then					
					if WRBot[ s1 ] and WRBot[ s1 ]:IsValid() then
						WRBot[ s1 ]:Kick("Bot deleted")
					end
					
					for _,v in pairs(player.GetAll()) do
						if v:IsBot() and IsValid(v) then
							if v.Style == s1 then
								v:Kick("Bot deleted")
							end
						end
					end

					if(file.Exists("botfiles/"..game.GetMap().."_"..s1..".txt","DATA")) then
						file.Delete("botfiles/"..game.GetMap().."_"..s1..".txt")
						gtimer.AddText(ply,"Bot deleted")
					end
				end
				
				net.Start("LoadWRs")
				net.WriteTable(gtimer.records)
				net.Send(ply)
				
				return ""
			end
		end
	end
end)

function gtimer.SetBonus(ply,bonus)
	if(bonus) then
		local pb = tonumber(ply:GetPB(ply.Style,true))
		ply:SendLua("gtimer.SetPB("..pb..")")
		ply:SendLua("LocalPlayer().bonus = true")
		ply:SendPB(pb)
		umsg.Start("SetStyle",ply)
		umsg.Short(100)
		umsg.End()
		ply:SendStyle(100)
		CSt[ply] = 100
		gtimer.SetCheckStyle(ply,100)
		if(ply.Style == 5) then
			ply.cppos = nil
			ply.cpang = nil
		end
	else
		local pb = tonumber(ply:GetPB(ply.Style,false))
		ply:SendLua("gtimer.SetPB("..pb..")")
		ply:SendLua("LocalPlayer().bonus = false")
		ply:SendPB(pb)
		umsg.Start("SetStyle",ply)
		umsg.Short(ply.Style)
		umsg.End()
		ply:SendStyle(ply.Style)
		CSt[ply] = ply.Style
		gtimer.SetCheckStyle(ply,ply.Style)
		if(ply.Style == 5) then
			ply.cppos = nil
			ply.cpang = nil
		end
	end
end

function gtimer.SetStyle(ply,id)
	if(ply.Style == 5) then
		ply.cppos = nil
		ply.cpang = nil
		ply.cpvel = nil
	end
	ply.Style = id
	if(ply.Style == 5) then
		ply.cppos = nil
		ply.cpang = nil
		ply.cpvel = nil
	end
	ply:SendLua("gtimer.SetPB("..tonumber(ply.pb[id])..")")
	ply:SendPB(ply.pb[id])
	umsg.Start("SetStyle",ply)
		umsg.Short(id)
	umsg.End()
	ply:SendStyle(id)
	CSt[ply] = id
	gtimer.SetCheckStyle(ply,id)
end

local admins = {}

hook.Add("PlayerInitialSpawn","Timer_ISpawn",function(ply)
	local u = ply:UniqueID()
	GAMEMODE:LoadRank(ply,u)
	ply.Style = 1
	ply.pb = {}
	for style,_ in pairs(gtimer.Styles) do
		for k,v in pairs(gtimer.records[style] or {}) do
			if(tostring(v['unique_id']) == tostring(u)) then
				ply.pb[style] = tonumber(v['time'])
			end
		end
		if(!ply.pb[style]) then
			ply.pb[style] = 0
		end
	end
	for k,v in pairs(gtimer.records[100] or {}) do
		if(tostring(v['unique_id']) == tostring(u)) then
			ply.bpb = tonumber(v['time'])
		end
	end
	if(!ply.bpb) then
		ply.bpb = 0
	end
	ply:SendLua("gtimer.SetPB("..tonumber(ply.pb[1])..")")
	net.Start("LoadWRs")
	net.WriteTable(gtimer.records)
	net.Send(ply)
	if(table.HasValue(admins,ply:SteamID())) then
		ply:SetNWInt("TAdmin",1)
	end
end)

hook.Add("PlayerSpawn","Timer_Spawn",function(ply)
	ply:ResetTimer()
end)

local function ToVec(str)
	local v = string.Explode(",",str)
	if(#v == 3) then
		return Vector(v[1],v[2],v[3])
	else
		return Vector(0,0,0)
	end
end

local function ToAng(str)
	local v = string.Explode(",",str)
	if(#v == 3) then
		return Angle(tonumber(v[1]),tonumber(v[2]),tonumber(v[3]))
	else
		return Angle(0,0,0)
	end
end

function gtimer.CreateArea(type,min,max,id,bonus)
	local mi = nil
	local ma = nil
	if(type == 4) then
		if(bonus) then
			mi = ToVec(min)
			ma = ToAng(max)
			gtimer.bonuspos = {mi,ma}
			return
		end
		mi = ToVec(min)
		ma = ToAng(max)
		for k,v in pairs(gtimer.Spawns) do
			v:SetPos(mi)
			v:SetAngles(ma)
		end
		gtimer.spawnpos = true
		return
	else
		mi = ToVec(min)
		ma = ToVec(max)
	end
	local a = ents.Create("timer_area")
	a:SetPos((mi+ma)/2)
	a.min = mi
	a.max = ma
	a.ztype = type
	a.bonus = bonus
	a:Spawn()
	gtimer.areas[tonumber(id)] = a
end

function gtimer.CreateCustomArea(type,min,max,id,data)
	local mi = ToVec(min)
	local ma = ToVec(max)
	local a = ents.Create("custom_zone")
	a:SetPos((mi+ma)/2)
	a.min = mi
	a.max = ma
	a.ztype = type
	a.data = data
	a:Spawn()
	gtimer.careas[tonumber(id)] = a
end

hook.Add("InitPostEntity", "Timer_Spawns", function() 
	local self = gtimer
	if ( !IsTableOfEntitiesValid( self.Spawns ) ) then
		self.LastSpawnPoint = 0
		self.Spawns = ents.FindByClass( "info_player_start" )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_deathmatch" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_combine" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_rebel" ) )
		
		-- CS Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_counterterrorist" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_terrorist" ) )
		
		-- DOD Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_axis" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "gmod_player_start" ) )
		
		-- TF Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_teamspawn" ) )
		
		-- INS Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "ins_spawnpoint" ) )  

		-- AOC Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "aoc_spawnpoint" ) )

		-- Dystopia Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "dys_spawn_point" ) )

		-- PVKII Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_pirate" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_viking" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_knight" ) )

		-- DIPRIP Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "diprip_start_team_blue" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "diprip_start_team_red" ) )
 
		-- OB Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_red" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_blue" ) )        
 
		-- SYN Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_coop" ) )
 
		-- ZPS Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_human" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_zombie" ) )      
 
		-- ZM Maps
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_deathmatch" ) )
		self.Spawns = table.Add( self.Spawns, ents.FindByClass( "info_player_zombiemaster" ) ) 

	end
	
	gtimer = self
	
	local a = sql.Query("SELECT * FROM timerareas WHERE `map_name`='"..game.GetMap().."' ORDER BY `id`")
	if(!a || type(a) ~= "table" || !a[1]) then a = {} end
	for k,v in pairs(a) do
		local b = false
		local t = tonumber(v['type'])
		if t > 4 then
			b = true
			t = t - 4
		end
		gtimer.CreateArea(t,v['min'],v['max'],tonumber(v['id']),b)
	end
	
	GAMEMODE:ReadWRRun()
	
	local z = sql.Query("SELECT * FROM customzones WHERE `map_name`='"..game.GetMap().."' ORDER BY `id`")
	if(!z || type(z) ~= "table" || !z[1]) then return end
	for k,v in pairs(z) do
		gtimer.CreateCustomArea(tonumber(v['type']),v['min'],v['max'],tonumber(v['id']),v['data'])
	end
end)

hook.Add("Initialize","Timer_LoadRecords",function()
	if(!sql.TableExists("bh_worldrecords")) then
		sql.Query("CREATE TABLE bh_worldrecords (map_name varchar(255), name varchar(255) DEFAULT '', unique_id int, time int, type int, bonus int, points int)")
	end
	if(!sql.TableExists("timerareas")) then
		sql.Query("CREATE TABLE timerareas (id integer primary key not null, map_name varchar(255), type int, min varchar(255), max varchar(255))")
	end
	if(!sql.TableExists("customzones")) then
		sql.Query("CREATE TABLE customzones (id integer primary key not null, map_name varchar(255), type int, min varchar(255), max varchar(255), data varchar(255))")
	end
	local r = sql.Query("SELECT * FROM bh_worldrecords WHERE `map_name`='"..game.GetMap().."' ORDER BY `time`")
	gtimer.records = {}
	gtimer.records = {}
	for k,v in pairs(r or {}) do
		if(tonumber(v['bonus']) == 1) then
			v['type'] = 100
		end
		if(!gtimer.records[tonumber(v['type'])]) then
			gtimer.records[tonumber(v['type'])] = {}
		end
		table.insert(gtimer.records[tonumber(v['type'])],{['name'] = tostring(v['name']), ['unique_id'] = tostring(v['unique_id']), ['time'] = tonumber(v['time']), ['type'] = tonumber(v['type']), ['points'] = tonumber(v['points'])})
	end
	GAMEMODE:LoadRanks()
	
	local s = file.Read("timeradmin.txt")
	admins = string.Explode("\r\n",s)
end)

hook.Add("SetupMove","AC +LEFT +RIGHT",function(ply,data)
	if(data:KeyDown(IN_LEFT) || data:KeyDown(IN_RIGHT)) then
		ply:StopTimer(false,ply.bonus)
		gtimer.AddText(ply,"You can't use +Left/+Right!")
		end
end)

local floor = math.floor
local wrframes = {}
local startfreeze = {}
local endfreeze = {}
local timescale = {}
for k,v in pairs(botstyles) do
        startfreeze[v] = 500
        endfreeze[v] = 0
        wrframes[v] = 1
        timescale[v] = v == 10 and 1.78 or 1
end
 
local dontbcheck = {}

hook.Add("SetupMove","wrbot",function(ply,data)
        if(ply:Team() == TEAM_SPECTATOR && ply:GetObserverTarget() && ply:GetObserverTarget():IsValid() && ply:GetObserverTarget():Team() == TEAM_BHOP && ply:GetObserverMode() != OBS_MODE_ROAMING) then
                local o = ply:GetObserverTarget()
                data:SetOrigin(o:GetPos())
                if(ply:GetObserverMode() == OBS_MODE_IN_EYE) then
                        ply:SetEyeAngles(o:EyeAngles())
                end
                return
        end
        local bot = false
        for k,v in pairs(botstyles) do
                if(ply == WRBot[v] && WRFr && WRFr[v]) then
                        if(NewWR[v]) then
                                NewWR[v] = false
                                wrframes[v] = 1
                                startfreeze[v] = 500
                                endfreeze[v] = 0
                                ply:ResetTimer()
                        end
                       
                        local fr = WRFr[v]
                       
                        if floor(wrframes[v] * timescale[v]) >= WRFrames[v] && endfreeze[v] < 1 then
                                dontbcheck[ply] = false
                                endfreeze[v] = 200
                                wrframes[v] = WRFrames[v]
                        end
               
                        local o = Vector(fr[1][floor(wrframes[v] * timescale[v])],fr[2][floor(wrframes[v] * timescale[v])],fr[3][floor(wrframes[v] * timescale[v])])
                        local a = Angle(fr[4][floor(wrframes[v] * timescale[v])],fr[5][floor(wrframes[v] * timescale[v])],0)
 
                        data:SetOrigin(o)
                        ply:SetEyeAngles(a)
                        if(fr[7][wrframes[v]]) then
                                if(!ply:HasWeapon(fr[7][wrframes[v]])) then
                                        ply:Give(fr[7][wrframes[v]])
                                end
                                ply:SelectWeapon(fr[7][wrframes[v]])
                        end
                        if(endfreeze[v] == 0 && startfreeze[v] == 0) then
                                wrframes[v] = wrframes[v] + 1
                        elseif(startfreeze[v] > 0) then
                                startfreeze[v] = startfreeze[v] - 1
                                if(startfreeze[v] == 0) then
                                        ply:StartTimer()
                                end
                        elseif(endfreeze[v] > 0) then
                                if(!dontbcheck[ply]) then
                                        local pb = botpb[ply]
                                        local t = (CurTime() - bottime[ply])
                                        if(bottime[ply] && t >= pb) then ply:StopTimer(false,false,pb) dontbcheck[ply] = true end
                                end
                                endfreeze[v] = endfreeze[v] - 1
                                if(endfreeze[v] == 0) then
                                        wrframes[v] = 1
                                        startfreeze[v] = 500
                                        ply:ResetTimer()
                                end
                        end
                        bot = true
                end
        end
        if(!bot && RecordP[ply] && Frames[ply]) then
                if(!StoreFrames[ply]) then
                        Frames[ply] = 0
                        StoreFrames[ply] = {}
                        StoreFrames[ply][1] = {}
                        StoreFrames[ply][2] = {}
                        StoreFrames[ply][3] = {}
                        StoreFrames[ply][4] = {}
                        StoreFrames[ply][5] = {}
                        StoreFrames[ply][6] = {}
                        StoreFrames[ply][7] = {}
                        LastWep[ply] = "weapon_glock"
                        recording[ply] = true
                end
                if(recording[ply]) then
                        local o = data:GetOrigin()
                        local a = data:GetAngles()
                        StoreFrames[ply][1][Frames[ply]] = o.x
                        StoreFrames[ply][2][Frames[ply]] = o.y
                        StoreFrames[ply][3][Frames[ply]] = o.z
                        StoreFrames[ply][4][Frames[ply]] = a.p
                        StoreFrames[ply][5][Frames[ply]] = a.y
                        if(CSt[ply] && WRFr[CSt[ply]] && Frames[ply] > WRFrames[CSt[ply]] + 15) then
                                recording[ply] = false
                        end
                        Frames[ply] = Frames[ply] + 1
                end
        end
end)
 
hook.Add("StartCommand","wrbot2",function(ply,data)
        local bot = false
        for k,v in pairs(botstyles) do
                if(ply == WRBot[v]) then
                        data:ClearButtons()
                        data:ClearMovement()
                        bot = true
                        if(WRFr && WRFr[v] && tonumber(WRFr[v][6][wrframes[v]])) then
                                if(ply:GetMoveType() == 0) then
                                        data:SetButtons(tonumber(WRFr[v][6][wrframes[v]])) --only place this actually works
                                end
                        end
                end
        end
        if(!botbot && recording[ply] && RecordP[ply] && StoreFrames[ply] && Frames[ply]) then
                StoreFrames[ply][6][Frames[ply]] = data:GetButtons() --may aswell record it in here too
        end
end)
 
timer.Create("BotShit",1,0,function()
        for k,v in pairs(botstyles) do
                if(WRBot[v] && WRBot[v]:IsValid()) then
                        if(WRBot[v]:GetMoveType() == 2) then
                                WRBot[v]:SetMoveType(0)
                        end
                else
                        GAMEMODE:SpawnBot(v)
                end
        end
end)

util.AddNetworkString("SyncMeter")

local Sync = {}

Sync.SyncMeter = true


function Sync.SetupMove(p,mv,cmd)
	if not p.lastang then
		p.lastang = p:EyeAngles()
		p.lastkey = 0
		p.lastdir = 0
		p.strafes = 0
		p.strafeavg = 0
		p.gstrafes = 0
		return
	end

	if not (p:Alive() and p:Team()!=TEAM_SPECTATOR and p:Health()>0) then return end
	if !p:OnGround() and p:GetMoveType()!=MOVETYPE_LADDER and p:GetMoveType()!=MOVETYPE_NOCLIP and p:WaterLevel()<1 then
	else
		return
	end

	local ang = p:EyeAngles()
	local oldang = p.lastang
	local dir = 0
	local olddir = p.lastdir
	local key = 0

	if ang.y > oldang.y then
		dir = -1
	elseif ang.y < oldang.y then
		dir = 1
	end
	if cmd:GetSideMove() > 0 then
		key = 1
	elseif cmd:GetSideMove() < 0 then
		key = -1
	end

	if dir!=0 then
		p.strafes = p.strafes + 1
		if dir==key then
			p.gstrafes = p.gstrafes + 1
		end
		p.strafeavg = p.gstrafes / p.strafes
	end

	p.lastdir = dir
	p.lastang = ang
	p.lastkey = key
end
function Sync.ResetSync(p)
	p.lastang = p:EyeAngles()
	p.lastkey = 0
	p.lastdir = 0
	p.strafes = 0
	p.strafeavg = 0
	p.gstrafes = 0
end
if Sync.SyncMeter then
	hook.Add("SetupMove","Strafe_Meter",Sync.SetupMove)
	hook.Add("PlayerSpawn","ResetSync",Sync.ResetSync)
end

function Sync.SendSync()
	for _,p in pairs(player.GetAll()) do
		if p.strafeavg then
			net.Start("SyncMeter")
				net.WriteEntity(p)
				net.WriteDouble(p.strafeavg)
			net.Broadcast()
		end
	end
end
if Sync.SyncMeter then
	timer.Create("SendSync",1,0,Sync.SendSync)
end

function Sync.ResetSync(p)
	p.lastang = p:EyeAngles()
	p.lastkey = 0
	p.lastdir = 0
	p.strafes = 0
	p.strafeavg = 0
	p.gstrafes = 0
end

function Sync.Cmd(p,m)
	if m =="!r" or m == "/r" or m == "!restart" or m == "/restart" or m == "!b" or m == "/b" or m == "!bonus" or m == "/bonus" then
		Sync.ResetSync(p)
		return
	end
	if m == "!sync" or m == "/sync" or m == "!sink" or m == "/sink" then

   		if p:GetNWInt("SyncToggle") == 0  then
   			p:SetNWInt("SyncToggle", 1)
   			text = "Enabled."
   		elseif p:GetNWInt("SyncToggle") == 1  then
   			p:SetNWInt("SyncToggle", 0)
   			text = "Disabled."
   		end

   		gtimer.AddText(p, "Sync " .. text )

   		return ""

   	end
end
hook.Add("PlayerSay","ChatCmds",Sync.Cmd)