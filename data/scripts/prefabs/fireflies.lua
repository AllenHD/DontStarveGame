local assets =
{
	Asset("ANIM", "data/anim/fireflies.zip"),
}

local INTENSITY = .5



local function fadein(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
    inst.Light:Enable(true)
    inst.Light:SetIntensity(0)
    inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end, function() inst:RemoveTag("NOCLICK") end)
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pst")
    inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end, function() inst:AddTag("NOCLICK") inst.Light:Enable(false) end)
end

local function updatelight(inst)
    if GetClock():IsNight() and not inst.components.playerprox:IsPlayerClose() and not inst.components.inventoryitem.owner then
        if not inst.lighton then
            fadein(inst)
        end
        inst.lighton = true
    else
        if inst.lighton then
            fadeout(inst)
        end
        inst.lighton = false
    end
end

local function ondropped(inst)
    inst.components.workable:SetWorkLeft(1)
    fadein(inst)
    inst.lighton = true
    inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
end

local function getstatus(inst)
    if inst.components.inventoryitem.owner then
        return "HELD"
    end
end


local function onfar(inst) 
    updatelight(inst) 
end

local function onnear(inst) 
	updatelight(inst) 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.entity:SetSleepRadius(16)
    inst.entity:AddPhysics()
 
    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(INTENSITY)
    light:SetRadius(1)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(false)
    
    inst.AnimState:SetBloomEffectHandle( "data/shaders/anim.ksh" )
    
    inst.AnimState:SetBank("fireflies")
    inst.AnimState:SetBuild("fireflies")

    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddComponent("playerprox")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(function(inst, worker)
        if worker.components.inventory then
            worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
            fadeout(inst)
        end
    end)

    inst:AddComponent("fader")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem.canbepickedup = false

    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)


    inst:ListenForEvent( "daytime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "nighttime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())

    updatelight(inst)
    
    return inst
end

return Prefab( "common/objects/fireflies", fn, assets) 

