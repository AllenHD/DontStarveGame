local shader_filename = "data/shaders/minimap.ksh"
local fs_shader = "data/shaders/minimapfs.ksh"
local atlas_filename = "data/minimap/minimap_atlas.tex"
local atlas_info_filename = "data/minimap/minimap_data.xml"

local MINIMAP_GROUND_PROPERTIES =
{
	{ GROUND.ROAD,       { name = "map_edge",      noise_texture = "levels/textures/mini_cobblestone_noise.tex" } },
	{ GROUND.MARSH,      { name = "map_edge",      noise_texture = "levels/textures/mini_marsh_noise.tex" } },
	{ GROUND.ROCKY,      { name = "map_edge",	   noise_texture = "levels/textures/mini_rocky_noise.tex" } },
	{ GROUND.SAVANNA,    { name = "map_edge",      noise_texture = "levels/textures/mini_grass2_noise.tex" } },
	{ GROUND.GRASS,      { name = "map_edge",      noise_texture = "levels/textures/mini_grass_noise.tex" } },
	{ GROUND.FOREST,     { name = "map_edge",      noise_texture = "levels/textures/mini_forest_noise.tex" } },
	{ GROUND.DIRT,       { name = "map_edge",      noise_texture = "levels/textures/mini_dirt_noise.tex" } },
	{ GROUND.WOODFLOOR,  { name = "map_edge",      noise_texture = "levels/textures/mini_woodfloor_noise.tex" } },
	{ GROUND.CARPET,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_carpet_noise.tex" } },
	{ GROUND.CHECKER,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_checker_noise.tex" } },

	-- { GROUND.WALL_MARSH, { name = "map_edge",      noise_texture = "levels/textures/mini_marsh_wall_noise.tex" } },
	-- { GROUND.WALL_ROCKY, { name = "map_edge",      noise_texture = "levels/textures/mini_rocky_wall_noise.tex" } },
	-- { GROUND.WALL_DIRT,  { name = "map_edge",      noise_texture = "levels/textures/mini_dirt_wall_noise.tex" } },

	{ GROUND.CAVE,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_cave_noise.tex" } },
	{ GROUND.FUNGUS,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_noise.tex" } },
	{ GROUND.SINKHOLE, 	 { name = "map_edge",      noise_texture = "levels/textures/mini_sinkhole_noise.tex" } },
	{ GROUND.UNDERROCK,  { name = "map_edge",      noise_texture = "levels/textures/mini_rock_noise.tex" } },
	{ GROUND.MUD, 	 	 { name = "map_edge",      noise_texture = "levels/textures/mini_mud_noise.tex" } },

	-- { GROUND.WALL_CAVE,    { name = "map_edge",      noise_texture = "levels/textures/mini_cave_wall_noise.tex" } },
	-- { GROUND.WALL_FUNGUS,  { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_wall_noise.tex" } },
	-- { GROUND.WALL_SINKHOLE,{ name = "map_edge",      noise_texture = "levels/textures/mini_sinkhole_wall_noise.tex" } },
}

local assets =
{
	Asset( "ATLAS", atlas_info_filename ),
	Asset( "IMAGE", atlas_filename ),
	
	Asset( "ATLAS", "data/images/hud.xml" ),
	Asset( "IMAGE", "data/images/hud.tex" ),

	Asset( "SHADER", shader_filename ),
	Asset( "SHADER", fs_shader ),
}
    
local function GroundImage( name )
	return "levels/tiles/" .. name .. ".tex"
end

local function GroundAtlas( name )
	return "levels/tiles/" .. name .. ".xml"
end

local function AddAssets( layers )
	for k, data in pairs( layers ) do
		local tile_type, properties = unpack( data )
		table.insert( assets, Asset( "IMAGE", "data/"..properties.noise_texture ) )
		table.insert( assets, Asset( "IMAGE", "data/"..GroundImage( properties.name ) ) )
		table.insert( assets, Asset( "FILE", "data/"..GroundAtlas( properties.name ) ) )
	end
end

AddAssets( MINIMAP_GROUND_PROPERTIES )

local function fn(Sim)
	local inst = CreateEntity()
	local uitrans = inst.entity:AddUITransform()
	local minimap = inst.entity:AddMiniMap()
    inst:AddTag("minimap")

	minimap:SetEffects( shader_filename, fs_shader )
	minimap:SetAtlasInfo( atlas_info_filename )

	for i, data in pairs( MINIMAP_GROUND_PROPERTIES ) do
		local tile_type, layer_properties = unpack( data )
		local handle =
			MapLayerManager:CreateRenderLayer(
				tile_type,
				resolvefilepath(GroundAtlas( layer_properties.name )),
				resolvefilepath(GroundImage( layer_properties.name )),
				resolvefilepath(layer_properties.noise_texture)
			)
		minimap:AddRenderLayer( handle )
	end

	return inst
end

return Prefab( "common/interface/hud/minimap", fn, assets) 

