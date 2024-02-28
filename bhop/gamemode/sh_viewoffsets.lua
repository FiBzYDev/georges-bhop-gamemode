include("bhop_cfg.lua")

local ut, mm, solid, eye, Iv = util.TraceLine, math.min, MASK_PLAYERSOLID, 12, IsValid

local function View(ply)
	if not Iv( ply ) then return end
	local maxs = ply:Crouching() and BHOP.HullCrouch or BHOP.HullStand
	local v = ply:Crouching() and BHOP.ViewCrouch or BHOP.ViewStand
	local offset = ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset()

	local tracedata = {}
	local s = ply:GetPos()
	s.z = s.z + maxs.z
	tracedata.start = s
	
	local e = Vector( s.x, s.y, s.z )
	e.z = e.z + (eye - maxs.z)
	e.z = e.z + v.z
	tracedata.endpos = e
	tracedata.filter = ply
	tracedata.mask = solid
	
	local trace = ut( tracedata )
	if trace.Fraction < 1 then
		local est = s.z + trace.Fraction * (e.z - s.z) - ply:GetPos().z - eye
		if not ply:Crouching() then
			offset.z = est
			ply:SetViewOffset( offset )
		else
			offset.z = mm( offset.z, est )
			ply:SetViewOffsetDucked( offset )
		end
	else
		ply:SetViewOffset( BHOP.ViewStand )
		ply:SetViewOffsetDucked( BHOP.ViewCrouch )
	end
end
hook.Add( "Move", "View", View )