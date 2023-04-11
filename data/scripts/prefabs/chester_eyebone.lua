
local assets=
{
    Asset("ANIM", "data/anim/chester_eyebone.zip"),
}

local SPAWN_DIST = 30

local trace = function() end

local function GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

local function SpawnChester(inst)
    trace("chester_eyebone - SpawnChester")

    local pt = Vector3(inst.Transform:GetWorldPosition())
    trace("    near", pt)
        
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt then
        trace("    at", spawn_pt)
        local chester = SpawnPrefab("chester")
        if chester then
            chester.Physics:Teleport(spawn_pt:Get())
            chester:FacePoint(pt)
            return chester
        end
    else
        -- this is not fatal, they can try again in a new location by picking up the bone again
        trace("chester_eyebone - SpawnChester: Couldn't find a suitable spawn point for chester")
    end
end


local function StopRespawn(inst)
    trace("chester_eyebone - StopRespawn")
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindChester(inst, chester)
    chester = chester or TheSim:FindFirstEntityWithTag("chester")
    if chester then

        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.components.inventoryitem:ChangeImageName("chester_eyebone")
        inst:ListenForEvent("death", function() inst:OnChesterDeath() end, chester)

        if chester.components.follower.leader ~= inst then
            chester.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnChester(inst)
    trace("chester_eyebone - RespawnChester")

    StopRespawn(inst)

    local chester = TheSim:FindFirstEntityWithTag("chester")
    if not chester then
        chester = SpawnChester(inst)
    end
    RebindChester(inst, chester)
end

local function StartRespawn(inst, time)
    StopRespawn(inst)

    local respawntime = time or 0
    if respawntime then
        inst.respawntask = inst:DoTaskInTime(respawntime, function() RespawnChester(inst) end)
        inst.respawntime = GetTime() + respawntime
        inst.AnimState:PlayAnimation("dead", true)
        inst.components.inventoryitem:ChangeImageName("chester_eyebone_closed")
    end
end

local function OnChesterDeath(inst)
    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME)
end

local function FixChester(inst)
	inst.fixtask = nil
	--take an existing chester if there is one
	if not RebindChester(inst) then
        inst.AnimState:PlayAnimation("dead", true)
        inst.components.inventoryitem:ChangeImageName("chester_eyebone_closed")
		
		if inst.components.inventoryitem.owner then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, function() FixChester(inst) end)	
	end
end

local function OnSave(inst, data)
    trace("chester_eyebone - OnSave")
    local time = GetTime()
    if inst.respawntime and inst.respawntime > time then
        data.respawntimeremaining = inst.respawntime - time
    end
end


local function OnLoad(inst, data)
    if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end

local function GetStatus(inst)
    trace("smallbird - GetStatus")
    if inst.respawntask then
        return "WAITING"
    end
end


local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --so I can find the thing while testing
    --local minimap = inst.entity:AddMiniMapEntity()
    --minimap:SetIcon( "treasure.png" )

    inst:AddTag("chester_eyebone")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("eyebone")
    inst.AnimState:SetBuild("chester_eyebone")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    

    inst.components.inventoryitem:ChangeImageName("chester_eyebone")    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("leader")

    

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnChesterDeath = OnChesterDeath

	inst.fixtask = inst:DoTaskInTime(1, function() FixChester(inst) end)

    return inst
end

return Prefab( "common/inventory/chester_eyebone", fn, assets) 
