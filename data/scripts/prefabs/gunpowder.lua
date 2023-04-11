local assets =
{
	Asset("ANIM", "data/anim/gunpowder.zip"),
    Asset("ANIM", "data/anim/explode.zip"),
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
    local explode = PlayFX(pos,"explode", "explode", "small")
    explode.AnimState:SetBloomEffectHandle( "data/shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gunpowder")
    inst.AnimState:SetBuild("gunpowder")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
	MakeSmallBurnable(inst, 3+math.random()*3)
    MakeSmallPropagator(inst)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/gunpowder", fn, assets) 

