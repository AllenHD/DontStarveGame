local assets=
{
	Asset("ANIM", "data/anim/cutstone.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("cutstone")
    inst.AnimState:SetBuild("cutstone")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "stone"
	inst.components.repairer.value = TUNING.REPAIR_CUTSTONE


	return inst
end

return Prefab( "common/inventory/cutstone", fn, assets) 
