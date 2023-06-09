local groundtiles = require "worldtiledefs"

local common_prefabs =
{

	"evergreen",
    "evergreen_normal",
    "evergreen_short",
    "evergreen_tall",
	"evergreen_sparse",
    "evergreen_sparse_normal",
    "evergreen_sparse_short",
    "evergreen_sparse_tall",
   	"evergreen_burnt",
   	"evergreen_stump",

    "sapling",
    "berrybush",
    "berrybush2",
    "grass",
    "rock1",
    "rock2",
    "rock_flintless",
    
    "tallbirdnest",
    "hound",
    "firehound",
    "icehound",
    "krampus",
    "mound",

    "pigman",
    "pighouse",
    "pigking",
    "mandrake",
    "chester",
    
    "goldnugget",
    "crow",
    "robin",
	"robin_winter",
    "butterfly",
    "flint",
    "log",
    "spiderden",
    "spawnpoint",
    "fireflies",
    "turf_road",
    "turf_rocky",
    "turf_marsh",
    "turf_savanna",
    "turf_dirt",
    "turf_forest",
    "turf_grass",
    "turf_cave",
    "turf_fungus",
    "turf_sinkhole",
    "turf_underrock",
    "turf_mud",
    "skeleton",
	"insanityrock",
	"sanityrock",
	"basalt",
	"basalt_pillar",
	"houndmound",
	"houndbone",
	"pigtorch",
	"red_mushroom",
	"green_mushroom",
	"blue_mushroom",
	"mermhouse",
	"flower_evil",
	"blueprint",
	"lockedwes",
	"wormhole_limited_1",
    "diviningrod",
    "diviningrodbase",
    
}

local assets =
{
    Asset("SOUND", "data/sound/sanity.fsb"),
}

for k,v in pairs(groundtiles.assets) do
	table.insert(assets, v)
end


--er.... huh?
function PlayCreatureSound(inst, sound, creature)
    local creature = creature or inst.soundgroup or inst.prefab
    inst.SoundEmitter:PlaySound("dontstarve/creatures/" .. creature .. "/" .. sound)
end

local function fn(Sim)

	local inst = CreateEntity()

	
	inst:AddTag( "ground" )
	inst:AddTag( "NOCLICK" )
    inst.entity:SetCanSleep(false)
    inst.persists = false




	local trans = inst.entity:AddTransform()
	local map = inst.entity:AddMap()
	local pathfinder = inst.entity:AddPathfinder()
	local groundcreep = inst.entity:AddGroundCreep()
	local sound = inst.entity:AddSoundEmitter()

	for i, data in ipairs( groundtiles.ground ) do
		local tile_type, props = unpack( data )
		local layer_name = props.name
		local handle =
			MapLayerManager:CreateRenderLayer(
				tile_type, --embedded map array value
				resolvefilepath(GroundAtlas( layer_name )),
				resolvefilepath(GroundImage( layer_name )),
				resolvefilepath(props.noise_texture)
			)

		map:AddRenderLayer( handle )
		-- TODO: When this object is destroyed, these handles really should be freed. At this time, this is not an
		-- issue because the map lifetime matches the game lifetime but if this were to ever change, we would have
		-- to clean up properly or we leak memory
	end

	for i, data in ipairs( groundtiles.creep ) do
		local tile_type, props = unpack( data )
		local handle = MapLayerManager:CreateRenderLayer( 
				tile_type,
				resolvefilepath(GroundAtlas( props.name )),
				resolvefilepath(GroundImage( props.name )),
				resolvefilepath(props.noise_texture ) )
		groundcreep:AddRenderLayer( handle )
	end

	local underground_layer = groundtiles.underground[1][2]
	local underground_handle = MapLayerManager:CreateRenderLayer( 
				GROUND.UNDERGROUND,
				resolvefilepath(GroundAtlas( underground_layer.name )),
				resolvefilepath(GroundImage( underground_layer.name )),
				resolvefilepath(underground_layer.noise_texture) )
	map:SetUndergroundRenderLayer( underground_handle )
	
    map:SetImpassableType( GROUND.IMPASSABLE )

	--common stuff
	inst:AddComponent("clock")
	
	inst:AddComponent("groundcreep")
	inst:AddComponent("ambientsoundmixer")
	inst:AddComponent("age")

	inst.IsCave = function() return inst:HasTag("cave") end
    return inst
end

return Prefab( "world", fn, assets, common_prefabs) 

