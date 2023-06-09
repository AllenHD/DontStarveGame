
local assets =
{
	Asset("IMAGE", "data/images/colour_cubes/day05_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/dusk03_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/night03_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/snow_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/snowdusk_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/night04_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/insane_day_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/insane_dusk_cc.tex"),
	Asset("IMAGE", "data/images/colour_cubes/insane_night_cc.tex"),

    Asset("ANIM", "data/anim/snow.zip"),
    Asset("ANIM", "data/anim/lightning.zip"),
    Asset("ANIM", "data/anim/splash_ocean.zip"),
    Asset("ANIM", "data/anim/frozen.zip"),

    Asset("SOUND", "data/sound/forest_stream.fsb"),
	Asset("IMAGE", "data/levels/textures/snow.tex"),
	Asset("IMAGE", "data/images/wave.tex"),
}

local forest_prefabs = 
{
	"world",
	"adventure_portal",
	"resurrectionstone",
    "deerclops",
	"knight",
	"bishop",
    "gravestone",
    "flower",
    "animal_track",
    "dirtpile",
    "beefaloherd",
    "beefalo",
    "penguinherd",
    "penguin",
    "koalefant_summer",
    "koalefant_winter",
    "beehive",
	"wasphive",
    "walrus_camp",
    "pighead",
    "mermhead",
    "rabbithole",
    "carrot_planted",
    "tentacle",
	"wormhole",
    "cave_entrance",
	"teleportato_base",
	"teleportato_ring",
	"teleportato_box",
	"teleportato_crank",
	"teleportato_potato",
	"pond", 
	"marsh_tree", 
	"marsh_bush", 
	"reeds", 
	"mist",
	"snow",
	"rain",
	"maxwellthrone",
	"maxwellendgame",
	"maxwelllight",
	"maxwelllock",
	"maxwellphonograph",
	"puppet_wilson",
	"puppet_willow",
	"puppet_wendy",
	"puppet_wickerbottom",
	"puppet_wolfgang",
	"puppet_wx78",
	"puppet_wes",
	"marblepillar",
	"marbletree",
	"statueharp",
	"statuemaxwell",
	"eyeplant",
	"lureplant",
	"purpleamulet",
	"monkey",
}

local function fn(Sim)

	local inst = SpawnPrefab("world")
	inst.prefab = "forest"
	
	
	--add waves
	local waves = inst.entity:AddWaveComponent()
	waves:SetRegionSize( 32, 16 )
	waves:SetRegionNumWaves( 6 )
	waves:SetWaveTexture( "data/images/wave.tex" )
	waves:SetWaveEffect( "data/shaders/texture.ksh" )
	waves:SetWaveSize( 2048, 512 )

	inst:AddComponent("seasonmanager")
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
	inst:AddComponent("hounded")
	inst:AddComponent("basehassler")
	inst:AddComponent("hunter")
	
    inst.components.butterflyspawner:SetButterfly("butterfly")

	inst:AddComponent("frograin")

	inst:AddComponent("lureplantspawner")
	inst:AddComponent("penguinspawner")

	inst:AddComponent("colourcubemanager")
	inst.Map:SetOverlayTexture( "data/levels/textures/snow.tex" )
    return inst
end

return Prefab( "forest", fn, assets, forest_prefabs) 

