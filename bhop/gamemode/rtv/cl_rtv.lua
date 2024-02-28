if SERVER then return end

local RTV = {}

RTV.VTab = {}
RTV.Voter = nil
RTV.Maps = {}
RTV.Keys = {}
RTV.NKeys = {}
local menuText = "Rock the Vote"

local voted = false

function RTV.CreatePanel()
	if (RTV.Voter and RTV.Voter:IsVisible()) then return end

	timer.Simple(25,function()
		if (RTV.Voter and RTV.Voter:IsVisible()) then 
			RTV.Voter:Remove()
			RTV.Keys = {}
		end
	end)
	
	voted = false
	
	RTV.Voter = vgui.Create( "DFrame" )
	local pn = RTV.Voter -- It gets annoying typing that
	pn:SetSize( 300, 40 + (26*#RTV.Maps) )
	pn:SetPos( 5, ScrH() * 0.4 )
	pn:SetTitle( "" )
	pn:ShowCloseButton(false)
	pn:SetDraggable(false)
	pn.Paint = function( self, w, h )
		surface.SetDrawColor(Color(28, 32, 40))
		surface.DrawRect( 0, 0, w, 30 )
		
		surface.SetDrawColor(Color(32, 37, 46))
		surface.DrawRect( 0, 30, w, h - 30 )

		draw.SimpleText(menuText,"VerdanaUI",w/2,15,Color(236,240,241,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	for k, v in ipairs( RTV.Maps ) do

		local text = vgui.Create( "DLabel", pn )
		text:SetFont( "VerdanaUI_B" )
		text:SetColor( Color( 255, 255, 255, 255 ) )
		text:SetText( tostring(k)..") "..v )
		text:SetPos( 10, 10+(26 * k-1) )
		text:SizeToContents()

		RTV.Keys[k+1] = { text, v == "Extend Current Map" and "EXTEND" or k }

	end

	pn.Think = function( self )

		if not voted and #RTV.Keys > 0 then

			for k, v in pairs( RTV.Keys ) do

				if input.IsKeyDown( k ) and v[1] then

					voted = true
					v[1]:SetColor( Color( 0, 255, 0, 255 ) )
					RunConsoleCommand( "rtv_vote", v[2] )
					surface.PlaySound( "garrysmod/save_load1.wav" )

				end

			end

		end
		
		-- Update number of votes
		for k, v in pairs(RTV.Keys) do
			if (RTV.VTab["MAP_"..v[2]]) then
				local numVotes = ""
				if (RTV.VTab["MAP_"..v[2]] > 0) then
					numVotes = " ("..RTV.VTab["MAP_"..v[2]]..")"
				end
				
				local map = tostring(RTV.Maps[v[2]])
				local n = v[2]
				
				if(tostring(v[2]) == "EXTEND") then
					n = 6
					map = "Extend Current Map"
				end
				
				v[1]:SetText(tostring(n)..") ".. map ..numVotes)
				v[1]:SizeToContents()
			end
		end

	end
end

local curpage = 1
local noinput = false

function RTV.CreateNominatePanel()
	if(!RTV.Nominate || (RTV.Voter and RTV.Voter:IsVisible())) then return end
	
	if (RTV.NVoter and RTV.NVoter:IsVisible()) then
		RTV.NVoter:Remove()
	end
	
	noinput = false
	curpage = 1
	
	local maps = {}
	
	for k, v in pairs(RTV.Nominate) do
		if(k > 6) then break end
		table.insert(maps,v)
	end

	RTV.NKeys = {}
	RTV.NVoter = vgui.Create( "DFrame" )
	local maxp = math.ceil(#RTV.Nominate/6)
	
	local pn = RTV.NVoter -- It gets annoying typing that
	pn:SetSize( 300, 290 )
	pn:SetPos( 5, ScrH() * 0.4 )
	pn:SetTitle( "" )
	pn:ShowCloseButton(false)
	pn:SetDraggable(false)
	pn.Paint = function( self, w, h )
		surface.SetDrawColor(Color(28, 32, 40))
		surface.DrawRect( 0, 0, w, 30 )
		
		surface.SetDrawColor(Color(32, 37, 46))
		surface.DrawRect( 0, 30, w, h - 30 )

		draw.SimpleText("Nominate a map!","VerdanaUI",w/2,15,Color(236,240,241,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	for k, v in ipairs( maps ) do

		local text = vgui.Create( "DLabel", pn )
		text:SetFont( "VerdanaUI_B" )
		text:SetColor( Color( 255, 255, 255, 255 ) )
		text:SetText( tostring(k)..") "..v )
		text:SetPos( 5, 10+(26 * k-1) )
		text:SizeToContents()

		RTV.NKeys[k+1] = { text, v }

	end
	
	local prev = vgui.Create( "DLabel", pn )
		prev:SetFont( "VerdanaUI_B" )
		prev:SetColor( Color( 255, 255, 255, 255 ) )
		prev:SetText( "8) Previous" )
		prev:SetPos( 5, (26 * 8) )
		prev:SizeToContents()
		prev:SetVisible(false)
		
	local next = vgui.Create( "DLabel", pn )
		next:SetFont( "VerdanaUI_B" )
		next:SetColor( Color( 255, 255, 255, 255 ) )
		next:SetText( "9) Next" )
		next:SetPos( 5, (26 * 9) )
		next:SizeToContents()
		
	local exit = vgui.Create( "DLabel", pn )
		exit:SetFont( "VerdanaUI_B" )
		exit:SetColor( Color( 255, 255, 255, 255 ) )
		exit:SetText( "0) Exit" )
		exit:SetPos( 5, (26 * 10) )
		exit:SizeToContents()

	pn.Think = function( self )

		if not noinput and input.IsKeyDown(KEY_8) and curpage > 1 then
			noinput = true
			curpage = curpage - 1
			for k,v in pairs(RTV.NKeys) do
				local m = RTV.Nominate[((curpage-1)*6)+(k-1)]
				v[1]:SetText( tostring(k-1)..") "..m )
				v[1]:SizeToContents()
				RTV.NKeys[k] = {v[1],m}
			end
			next:SetVisible(true)
			if(curpage == 1) then
				prev:SetVisible(false)
			end
			timer.Simple(.2,function() noinput = false end)
		elseif not noinput and input.IsKeyDown(KEY_9) and curpage < maxp then
			noinput = true
			curpage = curpage + 1
			for k,v in pairs(RTV.NKeys) do
				local m = RTV.Nominate[((curpage-1)*6)+(k-1)]
				if(!m) then
					RTV.NKeys[k] = {v[1]}
					v[1]:SetText( "" )
					v[1]:SizeToContents()
				else
					v[1]:SetText( tostring(k-1)..") "..m )
					v[1]:SizeToContents()
					RTV.NKeys[k] = {v[1],m}
				end
			end
			prev:SetVisible(true)
			if(curpage == maxp) then
				next:SetVisible(false)
			end
			timer.Simple(.2,function() noinput = false end)
		elseif not noinput and input.IsKeyDown(KEY_0) then
			noinput = true
			timer.Simple(.2,function()
				if (RTV.NVoter and RTV.NVoter:IsVisible()) then
					RTV.NVoter:Remove()
				end
				noinput = false
			end)
		elseif not noinput and #RTV.NKeys > 0 then

			for k, v in pairs( RTV.NKeys ) do

				if input.IsKeyDown( k ) and v[1] and v[2] then

					noinput = true
					v[1]:SetColor( Color( 0, 255, 0, 255 ) )
					RunConsoleCommand( "rtv_nominate", v[2] )
					timer.Simple(.2,function()
						if (RTV.NVoter and RTV.NVoter:IsVisible()) then
							RTV.NVoter:Remove()
						end
						noinput = false
					end)
				end

			end

		end

	end

end

usermessage.Hook( "RTVoting", function()
	timer.Simple( .1, function()
		if (RTV.NVoter and RTV.NVoter:IsVisible()) then
			RTV.NVoter:Remove()
		end
		RTV.CreatePanel()
	end )
end )

usermessage.Hook( "RTRevoting", function()
	voted = false
	for k, v in pairs( RTV.Keys ) do
		v[1]:SetColor( Color( 255, 255, 255, 255 ) )
	end
end )

usermessage.Hook( "RTNom", function()
	timer.Simple( .5, function()
		RTV.CreateNominatePanel()
	end )
end )

net.Receive( "RTVVTab", function()
	RTV.VTab = net.ReadTable()
end )

net.Receive( "RTVMaps", function()
	RTV.Maps = net.ReadTable()
end )

net.Receive( "RTVNominate", function()
	RTV.Nominate = net.ReadTable()
	table.sort(RTV.Nominate)
end )