local assets=
{
	Asset("ANIM", "data/anim/spider_spit.zip"),
}

local prefabs =
{
    "spider_web_spit_creep",
    "splash_spiderweb"
}

local function OnHit(inst, owner, target)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    inst:Remove()
    -- local impactfx = SpawnPrefab("impact")
    -- if impactfx then
    --     local follower = impactfx.entity:AddFollower()
    --     follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
    --     impactfx:FacePoint(Vector3(owner.Transform:GetWorldPosition()))
    -- end
    

    --inst.SoundEmitter:PlaySound("")
    --spawn hit effect

    -----------------------
    --spawn in web creation prefab *Looks really bad right now. Revisit this later.*
    -- local web = SpawnPrefab("spider_web_spit_creep")
    -- web.Transform:SetPosition(pt.x, pt.y, pt.z)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("spider_spit")
    anim:SetBuild("spider_spit")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

return Prefab( "common/inventory/spider_web_spit", fn, assets, prefabs) 
