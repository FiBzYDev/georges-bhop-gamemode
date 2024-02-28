AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Default Player"
PLAYER.AvoidPlayers			= false

function PLAYER:Spawn()
end

function PLAYER:Loadout()
	self.Player:StripWeapons()
	if(!self.Player.stripped) then
		self.Player:Give("weapon_glock")
		self.Player:Give("weapon_usp")
		self.Player:Give("weapon_knife")
		self.Player:Give("weapon_deagle")
		self.Player:SelectWeapon("weapon_"..BHOP.DefaultWeapon)
	end
end

player_manager.RegisterClass( "player_bhop", PLAYER, "player_default" )