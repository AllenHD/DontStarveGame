local cave_prefabs =
{
	"world",
	"cave_exit",
	"slurtle",
	"snurtle",
	"slurtlehole",
	"warningshadow",
	"cavelight",
	"flower_cave",
	"stalagmite",
	"stalagmite_tall",
	"bat",
	"mushtree_tall",
	"mushtree_medium",
	"mushtree_small",
	"cave_banana_tree",
	"spiderhole",
	"ground_chunks_breaking",
    "tentacle_pillar",
    "tentacle_pillar_arm",
    "batcave",
    "rockyherd",
    "cave_fern",
    "monkey",
    "monkeybarrel",
}

local assets =
{
    Asset("SOUND", "data/sound/cave_AMB.fsb"),
    Asset("SOUND", "data/sound/cave_mem.fsb"),
    Asset("IMAGE", "data/images/colour_cubes/caves_default.tex"),
}

local function fn(Sim)
	local inst = SpawnPrefab("world")
	inst:AddTag("cave")

	inst.prefab = "cave"
	--cave specifics
	inst:AddComponent("quaker")
	inst:AddComponent("seasonmanager")
	inst.components.seasonmanager:SetCaves()
	inst:AddComponent("colourcubemanager")

	--add waves
	--local waves = inst.entity:AddWaveComponent()
	--[[waves:SetRegionSize( 32, 16 )
	waves:SetRegionNumWaves( 6 )
	waves:SetWaveTexture( "data/images/wave.tex" )
	waves:SetWaveEffect( "data/shaders/texture.ksh" )
	waves:SetWaveSize( 2048, 512 )--]]


	inst.components.ambientsoundmixer:SetReverbPreset("cave")

    return inst
end

return Prefab( "cave", fn, assets, cave_prefabs) 

