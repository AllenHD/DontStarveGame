local assets =
{
	Asset("ANIM", "data/anim/gears.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("gears")
    inst.AnimState:SetBuild("gears")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
 
    inst:AddComponent("inspectable")  
    
    inst:AddComponent("inventoryitem")      
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "GEARS"
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible.sanityvalue = TUNING.SANITY_HUGE

    
    
    return inst
end

return Prefab("common/inventory/gears", fn, assets) 
