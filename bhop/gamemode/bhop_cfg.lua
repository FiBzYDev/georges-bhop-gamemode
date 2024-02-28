AddCSLuaFile()

_G.BHOP ={}

-- Bhop Settings

BHOP.SpeedGain = 32.8
BHOP.AirAccelerate = 500
BHOP.CrouchingAirAccelerate = 500
BHOP.LegitSpeedCap = 400
BHOP.JumpZoneSpeedCap = 290
BHOP.JumpPower = 290
BHOP.WalkSpeed = 250
BHOP.GunWalkSpeed = 250
BHOP.SneakSpeed = 130
BHOP.StepSize = 18

-- Miscellaneous

BHOP.Version = "7.1.2"
BHOP.PlayerModel = "models/player/phoenix.mdl"
BHOP.BotPlayerModel = "models/player/riot.mdl"
BHOP.ChatTextSound = "common/talk.wav"
BHOP.AdminChatTextSound = "common/talk.wav"
BHOP.DefaultWeapon = "glock"
BHOP.APIKey = "198FEA5C229DACEBCCA130CE0C9C0164"

-- Crouch Settings

BHOP.HullMin = Vector( -16, -16, 0 )
BHOP.HullCrouch = Vector( 16, 16, 45 )
BHOP.HullStand = Vector( 16, 16, 62 )
BHOP.ViewCrouch = Vector( 0, 0, 47 )
BHOP.ViewStand = Vector( 0, 0, 64 )
BHOP.CrouchedWalkSpeed = 0.6
BHOP.CrouchedSpeed = 0.4
BHOP.UnCrouchedSpeed = 0.2

--Stamina Settings

BHOP.Max = 100
BHOP.Cost_Jump = 25
BHOP.Recover_Rate = 19
BHOP.Ratio_Threshold = 100
BHOP.Ratio_Base = 70
BHOP.Ratio_Lift = 0
BHOP.Min_Power = 268.4

-- HUD Color Settings

BHOP.HUD_Icon_normal = Color(30, 144, 255, 120)
BHOP.Orange = Color(255, 255, 255, 255) -- Color(255, 176, 0, 255)
BHOP.OrangeDim = Color(255, 176, 0, 120)
BHOP.LightOrange = Color(188, 112, 0, 128)
BHOP.Red = Color(192, 28, 0, 140)
BHOP.Black = Color(0, 0, 0, 255)
BHOP.TransparentBlack = Color(0, 0, 0, 196)
BHOP.TransparentLightBlack = Color(0, 0, 0, 90)

BHOP.Title = Color(28, 32, 40)
BHOP.Back = Color(32, 37, 46)
BHOP.Speed = Color(74, 82, 102)
BHOP.SpeedBack = Color(64, 69, 87)
BHOP.White = Color(255, 255, 255)
BHOP.TimerColor = Color(0,191,255)

-- Zone Settings

BHOP.ZoneMaterial = "sprites/trails/ultima"
BHOP.DownLoadZoneDirectory = "materials/sprites/trails/ultima.vmt"
BHOP.StartColor = Color(255, 255, 255) --Color(0, 255, 0)
BHOP.EndColor = Color(255, 255, 255) --Color(255, 0, 0)
BHOP.BonusColor = Color(255, 255, 255) --Color(0, 0, 255)
BHOP.FreeStyleColor = Color(255, 255, 255) --Color(154, 180, 205)
BHOP.PlacingZoneMaterial = "sprites/laserbeam"
BHOP.PlacingColor = Color(0, 255, 0, 255)
BHOP.PlacingWith = 5
BHOP.ZoneWith = 5
BHOP.ZoneTextureWith = 100
BHOP.ZoneHeight = 128