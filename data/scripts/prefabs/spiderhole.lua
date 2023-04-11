local assets =
{
    Asset("ANIM", "data/anim/spider_mound.zip")
}

local prefabs =
{
    "spider_hider",
    "spider_spitter",
}

local function ReturnChildren(inst)
    if inst.components.childspawner then
        for k,child in pairs(inst.components.childspawner.childrenoutside) do
            if child.components.homeseeker then
                child.components.homeseeker:GoHome()
            end
            child:PushEvent("gohome")
        end
    end
end

local function OnWorkFinished(inst)
    inst.AnimState:PlayAnimation("break")
    inst.AnimState:PushAnimation("idle_broken", true)
    inst.broken = true
    inst.components.childspawner:StopSpawning()
    inst:RemoveComponent("childspawner")
    inst:RemoveComponent("workable")
    inst.GroundCreepEntity:SetRadius( 0 )

    inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
end

local function GoToBrokenState(inst)
    inst.AnimState:PushAnimation("idle_broken", true)
    inst:RemoveComponent("workable")
    if inst.components.childspawner then 
        inst.components.childspawner:StopSpawning()
        inst:RemoveComponent("childspawner") 
    end
    inst.GroundCreepEntity:SetRadius( 0 )
end

local function AddChildSpawner(inst)
    inst:AddComponent( "childspawner" )
    inst.components.childspawner:SetRegenPeriod(120)
    inst.components.childspawner:SetSpawnPeriod(240)
    inst.components.childspawner:SetMaxChildren(math.random(2,3))
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_hider"
    inst.components.childspawner:SetRareChild("spider_spitter", 0.33)
    inst.components.childspawner:StartSpawning()
    inst:ListenForEvent("startquake", function() ReturnChildren(inst) end , GetWorld())
end

local function onsave(inst, data)
    data.broken = inst.broken
end

local function onload(inst, data)
    if data then
        inst.broken = data.broken
        if inst.broken then 
            GoToBrokenState(inst)
        else
            AddChildSpawner(inst)
        end
    else
        AddChildSpawner(inst)
    end
end

local function SpawnInvestigators(inst, data)
    if not inst.components.health:IsDead() then
        if inst.components.childspawner then
            local num_to_release = math.min(2, inst.components.childspawner.childreninside)
            local num_investigators = inst.components.childspawner:CountChildrenOutside(function(child)
                return child.components.knownlocations:GetLocation("investigate") ~= nil
            end)
            num_to_release = num_to_release - num_investigators
            for k = 1,num_to_release do
                local spider = inst.components.childspawner:SpawnChild()
                if spider and data and data.target then
                    spider.components.knownlocations:RememberLocation("investigate", Vector3(data.target.Transform:GetWorldPosition() ) )
                end
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics( inst, 2)

    inst.entity:AddGroundCreepEntity()
    inst.GroundCreepEntity:SetRadius( 5 )
    inst:ListenForEvent("creepactivate", SpawnInvestigators)

    inst.broken = false

    anim:SetBank("spider_mound")
    anim:SetBuild("spider_mound")
    anim:PlayAnimation("idle", true)

    inst:AddTag("spiderden")

    inst:AddComponent("health")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("cavespider_den.png")
    


    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(4)

    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            if inst.components.childspawner then
                inst.components.childspawner:ReleaseAllChildren(worker)
            end
        end)

    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab( "cave/objects/spiderhole", fn, assets, prefabs) 