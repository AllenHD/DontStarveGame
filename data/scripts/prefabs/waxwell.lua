
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "data/anim/waxwell.zip"),
	Asset("SOUND", "data/sound/maxwell.fsb")    
}

local prefabs = 
{
}

local start_inv = 
{
	"nightsword",
	"armor_sanity",
	"purplegem",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
}

local function custom_init(inst)
	inst.components.sanity.dapperness = TUNING.DAPPERNESS_HUGE
	inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .5 )
	inst.soundsname = "maxwell"
end


return MakePlayerCharacter("waxwell", prefabs, assets, custom_init, start_inv) 
