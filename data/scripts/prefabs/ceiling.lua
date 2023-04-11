local groundtiles = require "worldtiledefs"

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local map = inst.entity:AddMapCeiling()
	map:SetBloomEffect("data/shaders/wall_bloom.ksh")
	
	inst:AddTag( "ceiling" )
	inst:AddTag( "NOCLICK" )
    inst.entity:SetCanSleep(false)
    inst.persists = false
    
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

	for i, data in ipairs( groundtiles.wall ) do
		local tile_type, props = unpack( data )
		local layer_name = props.name
		local handle =
			MapLayerManager:CreateRenderLayer(
				tile_type, --embedded map array value
				resolvefilepath(GroundAtlas( layer_name )),
				resolvefilepath(GroundImage( layer_name )),
				resolvefilepath(props.noise_texture)
			)
                     
		map:AddUndergroundRenderLayer( handle )
	end

	map:SetImpassableType( GROUND.WALL_ROCKY )--IMPASSABLE )
    return inst
end

return Prefab( "caves/ceiling", fn, assets) 

