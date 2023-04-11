local assets =
{
    --Asset("ANIM", "data/anim/arrow_indicator.zip"),
}

local prefabs = 
{
    "rocky",
}

local function CanSpawn(inst)
    return inst.components.herd and not inst.components.herd:IsFull()
end

local function OnSpawned(inst, newent)
    if inst.components.herd then
        inst.components.herd:AddMember(newent)
        newent.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)
    end
end

local function OnEmpty(inst)
    inst:Remove()
end

local function OnFull(inst)
    --TODO: mark some beefalo for death
end
   
local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("herd")
    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("rocky")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(OnEmpty)
    inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd.maxsize = 6
    
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetRandomTimes(TUNING.ROCKY_SPAWN_DELAY, TUNING.ROCKY_SPAWN_VAR)
    inst.components.periodicspawner:SetPrefab("rocky")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
    inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
    inst.components.periodicspawner:SetDensityInRange(20, 6)
    inst.components.periodicspawner:Start()
    inst.components.periodicspawner:SetOnlySpawnOffscreen(true)
    
    return inst
end

return Prefab( "cave/rockyherd", fn, assets, prefabs) 
