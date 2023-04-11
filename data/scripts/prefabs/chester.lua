require "prefabutil"
local brain = require "brains/chesterbrain"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
    Asset("ANIM", "data/anim/chester.zip"),
    Asset("ANIM", "data/anim/ui_chest_3x2.zip"),
}

local prefabs =
{
    "chester_eyebone",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
end

local function ShouldKeepTarget(inst, target)
    return false -- chester can't attack, and won't sleep if he has a target
end


local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end 

local function OnClose(inst) 
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("close")
    end
end 

-- eye bone was killed/destroyed
local function OnStopFollowing(inst) 
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion") 
end

local function OnStartFollowing(inst) 
    --print("chester - OnStartFollowing")
    inst:AddTag("companion") 
end

local slotpos = {}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
    end
end

local function create_chester()
    --print("chester - create_chester")

    local inst = CreateEntity()
    
    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("chester")
    inst:AddTag("notraptrigger")

    inst.entity:AddTransform()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "chester.png" )

    --print("   AnimState")
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("chester")
    inst.AnimState:SetBuild("chester")

    --print("   sound")
    inst.entity:AddSoundEmitter()

    --print("   shadow")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 2, 1.5 )

    --print("   Physics")
    MakeCharacterPhysics(inst, 75, .5)
    
    --print("   Collision")
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.Transform:SetFourFaced()


    --print("   Userfuncs")

    ------------------------------------------

    --print("   combat")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    --inst:ListenForEvent("attacked", OnAttacked)

    --print("   health")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")


    --print("   inspectable")
    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = GetStatus

    --print("   locomotor")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

    --print("   follower")
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    --print("   knownlocations")
    inst:AddComponent("knownlocations")

    --print("   burnable")
    MakeSmallBurnableCharacter(inst, "chester_body")
    
    --("   container")
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,-180,0)

    --print("   sleeper")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    --print("   sg")
    inst:SetStateGraph("SGchester")
    inst.sg:GoToState("idle")

    --print("   brain")
    inst:SetBrain(brain)    

    --print("chester - create_chester END")
    return inst
end

return Prefab( "common/chester", create_chester, assets, prefabs) 
