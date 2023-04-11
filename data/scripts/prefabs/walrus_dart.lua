local assets=
{
	Asset("ANIM", "data/anim/blow_dart.zip"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("blow_dart")
    anim:SetBuild("blow_dart")
    anim:PlayAnimation("dart_walrus")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetRange(TUNING.WALRUS_DART_RANGE)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

return Prefab( "common/inventory/walrus_dart", fn, assets) 
