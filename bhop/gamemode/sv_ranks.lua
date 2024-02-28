local ranks = {}
local maps = {}
local pr = {}

print("LOADED DATABASE")

util.AddNetworkString("UpdateWRPoints")

local function ToCol(str)
	local v = string.Explode(",",str)
	if(#v == 3) then
		return Color(tonumber(v[1]),tonumber(v[2]),tonumber(v[3]))
	else
		return Color(0,0,0)
	end
end

function GM:LoadRanks()
	if(!sql.TableExists("bh_timer_ranks")) then
		sql.Query("CREATE TABLE bh_timer_ranks (name varchar(255),position int,color varchar(255))")
	end
	local r = sql.Query("SELECT * FROM bh_timer_ranks ORDER BY position")
	r = r or {}
	for k,v in pairs(r) do
		ranks[tonumber(v['position'])] = {["name"] = v['name'], ["color"] = ToCol(v['color'])}
		pr[k] = {["name"] = v['name'], ["color"] = ToCol(v['color']), ["pos"] = v['position']}
	end
end

function GM:CreateRank(name,pos,col)
	ranks[pos] = {["name"] = name, ["color"] = col}
	sql.Query("INSERT INTO bh_timer_ranks (name,position,color) VALUES ("..sql.SQLStr(name)..",'"..pos.."','"..col.r..","..col.g..","..col.b.."')")
end

function GM:RemoveRank(name)
	local r = nil
	for k,v in pairs(ranks) do
		if(v['name'] == name) then
			r = k
		end
	end
	if(r) then
		table.remove(ranks,r)
		sql.Query("DELETE FROM bh_timer_ranks WHERE name="..sql.SQLStr(name))
		return true
	else
		return false
	end
end

local pm = FindMetaTable("Player")

function pm:GetMyRank(r)
	local rank = nil
	for k,v in pairs(ranks) do
		if(r <= k && (!rank || rank > k)) then
			rank = k
		end
	end
	if(!rank || !ranks[rank]) then return end
	self.rrank = rank
	local rname = ranks[rank]["name"]
	local col = ranks[rank]["color"]
	self:SetNWString("RRank",rname)
	self:SetNWString("RCol",col.r..","..col.g..","..col.b)
end

function GM:UpdatePoints()
	local sum = 0
	local t = 0
	for k,v in pairs(gtimer.records[1]) do
		sum = sum + v['time']
		t = t + 1
	end
	local avg = sum/t
	local q = "UPDATE bh_worldrecords SET points = CASE unique_id "
	local pts = {}
	for k,v in pairs(gtimer.records[1]) do
		v['points'] = (((t-k)*avg)/10)
		pts[k] = v['points']
		q = q.."WHEN "..v['unique_id'].." THEN "..v['points'].." "
	end
	q = q .. "END WHERE `type`='1' AND `bonus`='0' AND `map_name`='"..game.GetMap().."'"
	sql.Query(q)
	net.Start("UpdateWRPoints")
	net.WriteTable(pts)
	net.Broadcast()
end

function GM:LoadRank(ply,uid)
	local s = sql.Query("SELECT count(*) AS rank FROM (SELECT SUM(points) AS points FROM bh_worldrecords WHERE type='1' AND `bonus`='0' GROUP BY unique_id ORDER BY SUM(points)) AS t1 WHERE points>=(SELECT SUM(Points) FROM bh_worldrecords WHERE unique_id="..uid.." AND type='1' AND `bonus`='0')")
	if(s) then PrintTable(s[1]) end
	local rank = nil
	if(s && s[1]) then
		rank = tonumber(s[1]['rank'])
	end
	if(rank && rank != 0) then
		ply.nrank = rank
		ply:GetMyRank(rank)
	else
		ply:SetNWString("RRank","Unranked")
	end
end

hook.Add("PlayerSay","timer_ranks_say",function(ply,text,p)
	local t = string.lower(text)
	if(string.sub(t,1,8) == "!addrank" && ply:TimerAdmin()) then
		local e = string.Explode(" ",text)
		if(#e == 1) then
			gtimer.AddText(ply,"Wrong number of arguments for !addrank")
			return ""
		end
		table.remove(e,1)
		if(#e != 3) then
			gtimer.AddText(ply,"Wrong number of arguments for !addrank")
			return ""
		end
		GAMEMODE:CreateRank(e[1],tonumber(e[2]),ToCol(e[3]))
		return ""
	elseif(t == "!ranks") then
		if(!ply.nrank) then
			gtimer.AddText(ply,"You are not ranked.")
		else
			gtimer.AddText(ply,"You are rank "..ply.nrank..".")
		end
		gtimer.AddText(ply,"Ranks printed in console!")
		ply:SendLua('MsgC(Color(255,255,255),"\\n\\nRank, Position Required \\n\\n")')
		for k,v in pairs(pr) do
			local c = v["color"]
			ply:SendLua('MsgC(Color('..c.r..','..c.g..','..c.b..'),"'..v["name"]..'",Color(255,255,255),", '..v["pos"]..'\\n")')
		end
		return ""
	elseif(t == "!printmaps" && ply:TimerAdmin()) then
		gtimer.AddText(ply,"Total maps printed in console!")
		local total = 0
		for k,v in pairs(maps) do
			total = total + 1
			ply:PrintMessage(HUD_PRINTCONSOLE,k..", "..v)
		end
		ply:PrintMessage(HUD_PRINTCONSOLE,"Total: "..total)
		return ""
	elseif(string.sub(t,1,8) == "!delrank" && ply:TimerAdmin()) then
		local e = string.Explode(" ",text)
		if(#e == 1) then
			gtimer.AddText(ply,"Wrong number of arguments for !delrank")
			return ""
		end
		table.remove(e,1)
		if(#e != 1) then
			gtimer.AddText(ply,"Wrong number of arguments for !delrank")
			return ""
		end
		GAMEMODE:RemoveRank(e[1])
		return ""
	end
end)
