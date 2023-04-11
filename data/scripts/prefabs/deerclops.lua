local brain = require "brains/deerclopsbrain"

local assets =
{
	Asset("ANIM", "data/anim/deerclops_basic.zip"),
	Asset("ANIM", "data/anim/deerclops_actions.zip"),
	Asset("ANIM", "data/anim/deerclops_build.zip"),
	Asset("SOUND", "data/sound/deerclops.fsb"),
}

local prefabs =
{
	"meat",
	"deerclops_eyeball",
}

local TARGET_DIST = 30


local function CalcSanityAura(inst, observer)
	
	if inst.components.combat.target then
		return -TUNING.SANITYAURA_HUGE
	else
		return -TUNING.SANITYAURA_LARGE
	end
	
	return 0
end

local function RetargetFn(inst)
    return FindEntity(inst, TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy)
               and not guy:HasTag("prey")
               and not guy:HasTag("smallcreature")
               and (inst.components.knownlocations:GetLocation("targetbase") == nil or guy.components.combat.target == inst)
    end)
end


local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function AfterWorking(inst)
    inst.structuresDestroyed = inst.structuresDestroyed + 1
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function OnEntitySleep(inst)
    if inst.shouldGoAway then
        inst:Remove()
    end
    inst.structuresDestroyed = 0
end

local function OnSave(inst, data)
    data.structuresDestroyed = inst.structuresDestroyed
    data.shouldGoAway = inst.shouldGoAway
end
        
local function OnLoad(inst, data)
    if data and data.structuresDestroyed and data.shouldGoAway then
        inst.structuresDestroyed = data.structuresDestroyed
        inst.shouldGoAway = data.shouldGoAway
    end
end

local function OnSeasonChange(inst, data)
    inst.shouldGoAway = GetSeasonManager():GetSeason() ~= SEASONS.WINTER
    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end


local loot = {"meat", "meat", "meat", "meat", "meat", "meat", "meat", "meat", "deerclops_eyeball"}

local function fn(Sim)
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
    local s  = 1.65
    inst.Transform:SetScale(s,s,s)
	shadow:SetSize( 6, 3.5 )
    inst.Transform:SetFourFaced()
    
    inst.structuresDestroyed = 0
    inst.shouldGoAway = false
	
	MakeCharacterPhysics(inst, 1000, .5)

	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("deerclops")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    anim:SetBank("deerclops")
    anim:SetBuild("deerclops_build")
    anim:PlayAnimation("idle_loop", true)
    
    ------------------------------------------

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3  
    
    ------------------------------------------
    inst:SetStateGraph("SGdeerclops")

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura


    MakeLargeBurnableCharacter(inst, "deerclops_body")
    MakeHugeFreezableCharacter(inst, "deerclops_body")

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DEERCLOPS_HEALTH)

    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.DEERCLOPS_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(8)
    inst.components.combat:SetAreaDamage(6, 0.8)
    inst.components.combat.hiteffectsymbol = "deerclops_body"
    inst.components.combat:SetAttackPeriod(TUNING.DEERCLOPS_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    
    ------------------------------------------
 
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    
    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("knownlocations")
    inst:SetBrain(brain)
    
    inst:ListenForEvent("working", AfterWorking)
	inst:ListenForEvent("entitysleep", OnEntitySleep)
	inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld() )
    inst:ListenForEvent("attacked", OnAttacked)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab( "common/monsters/deerclops", fn, assets, prefabs) 
