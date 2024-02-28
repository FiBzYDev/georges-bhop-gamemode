local walls = {
"cave_toggle10",
"cave_toggle06",
"cave_toggle01",
"vr_toggle1",
"vr_toggle2",
"vr_toggle6",
"vr_toggle7",
"labs_tog023",
"labs_tog024",
"labs_tog025",
"labs_tog019",
"labs_tog020",
"labs_tog021"
}

local teles = {
Vector(-8532, -1412, 64),
Vector(-9872, -1516, -92),
Vector(-7312, -9780, -91),
Vector(-9744, -7596, -300),
Vector(8232, 4792, -768),
Vector(4824, -3536, 5292),
Vector(9040, 4392, -144),
Vector(9040, 4392, -320),
Vector(8656, 5064, 80),
Vector(7760, 5064, -144),
Vector(8720, 5064, -399.91)
}

local enable = {
"vr_toggle3",
"vr_toggle4",
"vr_toggle5",
"labs_tog09",
"labs_tog010"
}

local brush = {
"labs_tog02",
"labs_tog04",
"labs_tog07",
"labs_tog012",
"labs_tog013",
"labs_tog016"
}

HOOKS["InitPostEntity"] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(teles,v:GetPos())) then
			v:Remove()
		end
		if(v:GetPos() == Vector(8028, -8192, 5116)) then
			v:Fire("Enable")
		end
	end
	for k,v in pairs(ents.FindByClass("func_wall_toggle")) do
		if(table.HasValue(walls,v:GetName())) then
			v:Remove()
		end
		if(table.HasValue(enable,v:GetName())) then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if(table.HasValue(brush,v:GetName())) then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		if(v:GetPos() == Vector(6912, 7504, -128)) then
			v:Fire("Open")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		if(v:GetPos() == Vector(6912, 6168, 168)) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if(v:GetPos() == Vector(8032, -8192, 5116)) then
			v:Remove()
		end
	end
end
