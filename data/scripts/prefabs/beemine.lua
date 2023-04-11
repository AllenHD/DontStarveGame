local assets=
{
	Asset("ANIM", "data/anim/bee_mine.zip"),
	Asset("ANIM", "data/anim/bee_mine_maxwell.zip"),
    Asset("SOUND", "data/sound/bee.fsb"),
}

local prefabs = 
{
    "bee",
	"mosquito",
}

local function SpawnBees(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_explo")
    local target = inst.components.mine and inst.components.mine:GetTarget()
    if target and target:IsValid() then
        for i = 1, TUNING.BEEMINE_BEES do
            local bee = SpawnPrefab(inst.beeprefab)
            if bee then
                local pos = Vector3(inst.Transform:GetWorldPosition() )
                local dist = math.random()
                local angle = math.random()*2*PI
                pos.x = pos.x + dist*math.cos(angle)
                pos.z = pos.z + dist*math.sin(angle)
                bee.Physics:Teleport(pos:Get() )
                if bee.components.combat then
                    bee.components.combat:SetTarget(target)
                end
            end
        end
        target:PushEvent("coveredinbees")
    end
    inst:RemoveComponent("mine")
end

local function OnExplode(inst)
    inst.AnimState:PlayAnimation("explode")
    inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_launch")
    inst:DoTaskInTime(9*FRAMES, SpawnBees)
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function onhammered(inst, worker)
	if inst.components.mine then
	    inst.components.mine:Explode(worker)
	end
end

local function MineRattle(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_rattle")
    inst.rattletask = inst:DoTaskInTime(4 + math.random(), MineRattle)
end

local function StartRattling(inst)
    inst.rattletask = inst:DoTaskInTime(1, MineRattle)
end

local function StopRattling(inst)
    if inst.rattletask then
        inst.rattletask:Cancel()
        inst.rattletask = nil
    end
end

local function MakeBeeMineFn(name, alignment, skin, spawnprefab, inventory)
	local function fn()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		MakeInventoryPhysics(inst)
		
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "beemine.png" )
	   
		anim:SetBank(skin)
		anim:SetBuild(skin)
		anim:PlayAnimation("idle")
		
		inst:AddTag("mine")
		inst:AddComponent("mine")
		inst.components.mine:SetOnExplodeFn(OnExplode)
		inst.components.mine:SetAlignment(alignment)
		inst.components.mine:SetRadius(TUNING.BEEMINE_RADIUS)
		inst.components.mine:StartTesting()
		inst.beeprefab = spawnprefab
		
		inst:AddComponent("inspectable")
		if inventory then
			inst:AddComponent("inventoryitem")
			inst.components.inventoryitem.nobounce = true
			inst.components.inventoryitem:SetOnPutInInventoryFn(StopRattling)
			inst.components.inventoryitem:SetOnDroppedFn(StartRattling)
		end
		
		inst:AddComponent("lootdropper")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(1)
		inst.components.workable:SetOnFinishCallback(onhammered)

		StartRattling(inst)
		
		--inst:AddComponent("trap")
		
		return inst
	end
	return fn
end

local function BeeMine(name, alignment, skin, spawnprefab, inventory)
	return Prefab( "common/inventory/"..name, MakeBeeMineFn(name, alignment, skin, spawnprefab, inventory), assets, prefabs)
end

return BeeMine("beemine", "player", "bee_mine", "bee", true),
	   BeeMine("beemine_maxwell", "nobody", "bee_mine_maxwell", "mosquito", false) 
