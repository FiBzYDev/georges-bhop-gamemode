local drawLJ = false

local dist = 0
local syncs = {}
local speed = {}
local sync = 0
local jumptype = ""

net.Receive("LJStats",function()
	timer.Destroy("LJStatsHide")
	jumptype = net.ReadString()
	dist = net.ReadInt(16)
	syncs = net.ReadTable()
	speed = net.ReadTable()
	sync = net.ReadInt(16)/100
	drawLJ = true
	timer.Create("LJStatsHide", 5, 1, function()
		drawLJ = false
	end)
end)

hook.Add("HUDPaintBackground","DrawStats",function()
	if(drawLJ) then
		local nw = surface.GetTextDim("   Strafe   Speed   Sync   ","SPF_N")+10
		
		local h = (16*#syncs)+68
		
		draw.RoundedBox( 8, ScrW()-nw-20, 20, nw, h, Color( 12, 12, 12, 220 ) )

		draw.SimpleText("["..jumptype.."] "..dist.." units.", "SPF_N", ScrW()-nw-15, 30, Color(255,255,255,255), 0, 3)
		
		draw.SimpleText("Sync: "..sync.."%", "SPF_N", ScrW()-nw-15, 30+16, Color(255,255,255,255), 0, 3)
		
		draw.SimpleText("Strafe   Speed   Sync", "SPF_N", ScrW()-nw-15, 30+48, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		for k,v in pairs(syncs) do
			draw.SimpleText("    "..k.."         "..speed[k].."     "..v, "SPF_N", ScrW()-nw-15, 30+48+k*16, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
		
		
	end
end)