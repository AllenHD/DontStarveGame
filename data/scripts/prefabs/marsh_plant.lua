local assets =
{
	Asset("ANIM", "data/anim/marsh_plant.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    anim:SetBuild("marsh_plant")
    anim:SetBank("marsh_plant")
    anim:PlayAnimation("idle", true)
    
    inst:AddComponent("inspectable")
    return inst
end

return Prefab( "marsh/objects/marsh_plant", fn, assets) 
