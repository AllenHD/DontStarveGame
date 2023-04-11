local function OnNear(inst)
	for k,v in pairs(inst.components.maxlightspawner.lights) do
		v.components.burnable:Ignite()
	end
end

local function OnFar(inst)
	for k,v in pairs(inst.components.maxlightspawner.lights) do
		v.components.burnable:Extinguish()
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst:AddComponent("playerprox")

	inst:AddComponent("maxlightspawner")	
	inst.components.maxlightspawner.angleoffset = 90

	
	inst.components.playerprox:SetOnPlayerNear(OnNear)
	inst.components.playerprox:SetOnPlayerFar(OnFar)
	inst.components.playerprox:SetDist(6,8)

	inst:DoTaskInTime(0, function() inst.components.maxlightspawner:SpawnAllLights() end)
	return inst
end

return Prefab("forest/objects/vertical_maxwelllight", fn) 