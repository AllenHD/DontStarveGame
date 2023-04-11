local assets =
{
	Asset("ANIM", "data/anim/monkey_barrel.zip"),
}

local prefabs =
{
    "monkey",
    "poop",
    "cave_banana"
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren(worker)
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
end


local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end

    if not inst.task then
        inst.task = inst:DoTaskInTime(math.random(60, 120), function() 
            inst.task = nil 
            inst:PushEvent("safetospawn")
        end)
    end
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("break")
    inst.AnimState:PushAnimation("idle_broken")
    inst.Physics:ClearCollisionMask()
    inst:DoTaskInTime(0.66, function()
        inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
    end)
end

local function OnIgniteFn(inst)
	inst.AnimState:PlayAnimation("shake", true)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
end

local function ongohome(inst, child)
    if child.components.inventory then
        child.components.inventory:DropEverything(false, true)
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics( inst, 1)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("monkey_barrel.png")

    anim:SetBank("barrel")
    anim:SetBuild("monkey_barrel")
    anim:PlayAnimation("idle", true)

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(120)
	inst.components.childspawner:SetSpawnPeriod(30)
	inst.components.childspawner:SetMaxChildren(math.random(3,4))
	inst.components.childspawner:StartRegen()
	inst.components.childspawner.childname = "monkey"
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.ongohome = ongohome

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"poop", "poop", "cave_banana", "cave_banana"})
    inst.components.lootdropper:AddChanceLoot("trinket_4", 0.01)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("death", OnKilled)

	inst:ListenForEvent("warnquake", function()  --Monkeys all return on a quake start
        if inst.components.childspawner then
            inst.components.childspawner:StopSpawning()
            ReturnChildren(inst) 
        end
    end, GetWorld())

    inst:ListenForEvent("monkeydanger", function()  --Monkeys all return on a quake start
        if inst.components.childspawner then
            inst.components.childspawner:StopSpawning()
            ReturnChildren(inst) 
        end
    end)

	inst:ListenForEvent("safetospawn", function() 
        if inst.components.childspawner then
    		inst.components.childspawner:StartSpawning()
	    end		
    end)

    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst)

	return inst
end

return Prefab( "cave/objects/monkeybarrel", fn, assets, prefabs) 