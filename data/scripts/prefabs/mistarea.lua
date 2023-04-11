local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	local pt = inst.Transform:GetWorldPosition()
	local mist = SpawnPrefab( "mist" )
	mist.Transform:SetPosition( pt.x, 0, pt.z )
	mist.components.emitter.area_emitter = CreateAreaEmitter( node.poly, node.cent )	
	if node.area == nil then
		node.area = 1
	end	
	mist.components.emitter.density_factor = math.ceil(node.area / 4)/31
	mist.components.emitter:Emit()
end


return Prefab("common/forest/mistarea", fn) 