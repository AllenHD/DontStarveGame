local Mixer = require("mixer")


local amb = "set_ambience/ambience"
local cloud = "set_ambience/cloud"
local music = "set_music/soundtrack"
local voice = "set_sfx/voice"
local movement ="set_sfx/movement"
local creature ="set_sfx/creature"
local player ="set_sfx/player"
local HUD ="set_sfx/HUD"
local sfx ="set_sfx/sfx"

--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)

TheMixer:AddNewMix("normal", 2, 1,
{ 
	[amb] = .8,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,

})


TheMixer:AddNewMix("high", 2, 3,
{ 
	[amb] = .2,
	[cloud] = 1,
	[music] = .5,
	[voice] = .7,
	[movement] = .7,
	[creature] = .7,
	[player] = .7,
	[HUD] = 1,
	[sfx] = .7,
})

TheMixer:AddNewMix("start", 1, 0,
{
	[amb] = .8,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,

})

TheMixer:AddNewMix("pause", 1, 4,
{
	[amb] = .1,
	[cloud] = .1,
	[music] = 0,
	[voice] = 0,
	[movement] = 0,
	[creature] = 0,
	[player] = 0,
	[HUD] = 1,
	[sfx] = 0,
})


TheMixer:AddNewMix("death", 1, 6,
{
	[amb] = .2,
	[cloud] = .2,
	[music] = 0,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,
})
