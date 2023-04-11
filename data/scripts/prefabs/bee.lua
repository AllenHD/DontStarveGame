local beecommon = require "brains/beecommon"

--[[
Bees.lua

bee
Default bee type. Flies around to flowers and pollinates them, generally gets spawned out of beehives or player-made beeboxes

killerbee
Aggressive version of the bee. Doesn't pollinate anythihng, but attacks anything within range. If it has a home to go to and no target,
it should head back there. Killer bees come out to defend beehives when they, the hive or worker bees are attacked
]]--
local assets=
{
	Asset("ANIM", "data/anim/bee.zip"),
	Asset("ANIM", "data/anim/bee_build.zip"),
	Asset("ANIM", "data/anim/bee_angry_build.zip"),
	Asset("SOUND", "data/sound/bee.fsb"),
}
    
    
local prefabs =
{
	"stinger",
	"honey",
}

local workersounds = 
{
    takeoff = "dontstarve/bee/bee_takeoff",
    attack = "dontstarve/bee/bee_attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/bee/bee_hurt",
    death = "dontstarve/bee/bee_death",
}

local killersounds = 
{
    takeoff = "dontstarve/bee/killerbee_takeoff",
    attack = "dontstarve/bee/killerbee_attack",
    buzz = "dontstarve/bee/killerbee_fly_LP",
    hit = "dontstarve/bee/killerbee_hurt",
    death = "dontstarve/bee/killerbee_death",
}

local function OnWorked(inst, worker)
    local owner = inst.components.homeseeker and inst.components.homeseeker.home
    if owner and owner.components.childspawner then
        owner.components.childspawner:OnChildKilled(inst)
    end
    if worker.components.inventory then
        worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
    end
end

local function OnDropped(inst)
    inst.sg:GoToState("catchbreath")
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.brain then
		inst.brain:Start()
	end
	if inst.sg then
	    inst.sg:Start()
	end
	if inst.components.stackable then
	    while inst.components.stackable:StackSize() > 1 do
	        local item = inst.components.stackable:Get()
	        if item then
	            if item.components.inventoryitem then
	                item.components.inventoryitem:OnDropped()
	            end
	            item.Physics:Teleport(inst.Transform:GetWorldPosition() )
	        end
	    end
	end
end

local function OnPickedUp(inst)
    inst.SoundEmitter:KillSound("buzz")
    inst.sg:GoToState("idle")
end

local function KillerRetarget(inst)
    return FindEntity(inst, 8, function(guy)
        return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") )
            and not guy:HasTag("insect")
            and inst.components.combat:CanTarget(guy)
    end)
end

local function commonfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( .8, .5 )
    inst.Transform:SetFourFaced()
    
    
    ----------
    
    inst:AddTag("bee")
    inst:AddTag("insect")
    inst:AddTag("hit_panic")
    inst:AddTag("smallcreature")
   
    MakeCharacterPhysics(inst, 1, .5)
    inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
    
    inst.AnimState:SetBank("bee")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGbee")
    
	inst:AddComponent("inventoryitem")
	inst:AddComponent("stackable")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
	inst.components.inventoryitem.canbepickedup = false

	---------------------
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddRandomLoot("honey", 1)
	inst.components.lootdropper:AddRandomLoot("stinger", 5)   
	inst.components.lootdropper.numrandomloot = 1
	
	 ------------------
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.NET)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorked)
   
    MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 0))
    MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 0))
    
    ------------------
    inst:AddComponent("health")

    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"

    ------------------
    
    inst:AddComponent("sleeper")
    ------------------
    
    inst:AddComponent("knownlocations")

    ------------------
    
    inst:AddComponent("inspectable")
    
    inst:ListenForEvent("attacked", beecommon.OnAttacked)
    inst:ListenForEvent("worked", beecommon.OnWorked)

    return inst
end

-- local brainfn = loadfile("data/scripts/brains/beebrain.lua")
-- assert(type(brainfn) == "function", brainfn)

local workerbrain = require("brains/beebrain")
local killerbrain = require("brains/killerbeebrain")

local function workerbee()
    local inst = commonfn()
    inst:AddTag("worker")
    inst.AnimState:SetBuild("bee_build")
    inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
	inst:AddComponent("pollinator")
    
    inst:SetBrain(workerbrain)
    inst.sounds = workersounds
    inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    return inst
end

local function killerbee()
    local inst = commonfn()
    inst:AddTag("killer")
    inst:AddTag("scarytoprey")
    inst.AnimState:SetBuild("bee_angry_build")
    inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, KillerRetarget)
    inst:SetBrain(killerbrain)
    inst.sounds = killersounds
    inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    return inst
end 

return Prefab( "forest/monsters/bee", workerbee, assets, prefabs),
       Prefab( "forest/monsters/killerbee", killerbee, assets, prefabs) 
