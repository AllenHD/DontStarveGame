local assets=
{
	Asset("ANIM", "data/anim/bishop.zip"),
	--Asset("ANIM", "data/anim/bishop_build.zip"),
	Asset("SOUND", "data/sound/chess.fsb"),
}

local prefabs =
{
	"gears",
    "bishop_charge",
    "purplegem",
}

local loot = 
{
	"gears",
    "gears",
    "purplegem",
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > TUNING.BISHOP_TARGET_DIST*TUNING.BISHOP_TARGET_DIST) then
        return
    end
    
    local newtarget = FindEntity(inst, TUNING.BISHOP_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster") )
                   and not guy:HasTag("chess")
                   and inst.components.combat:CanTarget(guy)
    end)
    return newtarget
end

local function KeepTarget(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local targetPos = Vector3(target.Transform:GetWorldPosition() )
    return homePos and distsq(homePos, targetPos) < MAX_CHASEAWAY_DIST*MAX_CHASEAWAY_DIST
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("chess") end, MAX_TARGET_SHARES)
end

local function WeaponDropped(inst)
    inst:Remove()
end

local function EquipWeapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange+4)
        weapon.components.weapon:SetProjectile("bishop_charge")
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(WeaponDropped)
        weapon:AddComponent("equippable")
        
        inst.components.inventory:Equip(weapon)
    end
end

 
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

    anim:SetBank("bishop")
    anim:SetBuild("bishop")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BISHOP_WALK_SPEED
    
    inst:SetStateGraph("SGbishop")

    inst:AddTag("monster")
    inst:AddTag("chess")
    inst:AddTag("bishop")

    local brain = require "brains/bishopbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "waist"
    inst.components.combat:SetAttackPeriod(TUNING.BISHOP_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BISHOP_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BISHOP_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BISHOP_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BISHOP_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    inst:AddComponent("inventory")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    
    inst:DoTaskInTime(1*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()) ) end)
    inst:DoTaskInTime(1, EquipWeapon)

    
    MakeMediumBurnableCharacter(inst, "waist")
    MakeMediumFreezableCharacter(inst, "waist")

    inst:ListenForEvent("attacked", OnAttacked)
    
    return inst
end

return Prefab("chessboard/bishop", fn, assets, prefabs) 
