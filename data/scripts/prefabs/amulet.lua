local assets=
{
	Asset("ANIM", "data/anim/amulets.zip"),
	Asset("ANIM", "data/anim/torso_amulets.zip"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

---RED
local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:IsHurt())
    and (owner.components.hunger and owner.components.hunger.current > 5 )then
        owner.components.health:DoDelta(TUNING.REDAMULET_CONVERSION)
        owner.components.hunger:DoDelta(-TUNING.REDAMULET_CONVERSION)
        inst.components.finiteuses:Use(1)
    end
end

local function onequip_red(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")
    inst.task = inst:DoPeriodicTask(30, function() healowner(inst, owner) end)
end

local function onunequip_red(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.task then inst.task:Cancel() inst.task = nil end
end

---BLUE
local function onequip_blue(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "blueamulet")

    inst.freezefn = function(attacked, data)
        if data.attacker.components.freezable then
            data.attacker.components.freezable:AddColdness(0.67)
            data.attacker.components.freezable:SpawnShatterFX()
            inst.components.fueled:DoDelta(-(inst.components.fueled.maxfuel * 0.03))
        end 
    end

    inst:ListenForEvent("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StartConsuming()        
    end

end

local function onunequip_blue(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst:RemoveEventCallback("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end
end

---PURPLE
local function induceinsanity(val, owner)
    if owner.components.sanity then
        owner.components.sanity.inducedinsanity = val
    end
    if owner.components.sanitymonsterspawner then
        --Ensure the popchangetimer fully ticks over by running max tick time twice.
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
    end

    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 100)

    for k,v in pairs(ents) do
        if (v:HasTag("rabbit") or v:HasTag("manrabbit")) and v.CheckTransformState ~= nil then
            v.CheckTransformState(v)
        end
    end

end

local function onequip_purple(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "purpleamulet")
    if inst.components.fueled then
        inst.components.fueled:StartConsuming()        
    end
    induceinsanity(true, owner)
end

local function onunequip_purple(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end
    induceinsanity(nil, owner)
end

---GREEN
local function onequip_green(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "greenamulet")
end

local function onunequip_green(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

---ORANGE
local function onequip_orange(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")
end

local function onunequip_orange(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

---YELLOW
local function onequip_yellow(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "yellowamulet")
end

local function onunequip_yellow(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
end


---COMMON FUNCTIONS

local function onfinished(inst)
    inst:Remove()
end

local function unimplementeditem(inst)
    local player = GetPlayer()
    player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_UNIMPLEMENTED"))
    if player.components.health.currenthealth > 1 then
        player.components.health:DoDelta(-player.components.health.currenthealth * 0.5)
    end

    if inst.components.useableitem then
        inst.components.useableitem:StopUsingItem()
    end
end

local function commonfn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("amulets")
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    
	inst:AddComponent("dapperness")
	inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL    
    
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    
    return inst
end

local function red(inst)
    local inst = commonfn(inst)
        inst.AnimState:PlayAnimation("redamulet")
        inst.components.inventoryitem.keepondeath = true
        inst.components.equippable:SetOnEquip( onequip_red )
        inst.components.equippable:SetOnUnequip( onunequip_red )
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetOnFinished( onfinished )
        inst.components.finiteuses:SetMaxUses(TUNING.REDAMULET_USES)
        inst.components.finiteuses:SetUses(TUNING.REDAMULET_USES)
    return inst
end

local function blue(inst)
    local inst = commonfn(inst)
        inst.AnimState:PlayAnimation("blueamulet")
        inst.components.equippable:SetOnEquip( onequip_blue )
        inst.components.equippable:SetOnUnequip( onunequip_blue )
        inst:AddComponent("heater")
        inst.components.heater.iscooler = true
        inst.components.heater.equippedheat = TUNING.BLUEGEM_COOLER

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "MAGIC"
        inst.components.fueled:InitializeFuelLevel(TUNING.BLUEAMULET_FUEL)
        inst.components.fueled:SetDepletedFn(onfinished)
    return inst
end

local function purple(inst)
    local inst = commonfn(inst)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "MAGIC"
        inst.components.fueled:InitializeFuelLevel(TUNING.PURPLEAMULET_FUEL)
        inst.components.fueled:SetDepletedFn(onfinished)

        inst.AnimState:PlayAnimation("purpleamulet")
        inst.components.equippable:SetOnEquip( onequip_purple )
        inst.components.equippable:SetOnUnequip( onunequip_purple )
    return inst
end

local function green(inst)
    local inst = commonfn(inst)
        inst.AnimState:PlayAnimation("greenamulet")
        inst.components.inspectable.nameoverride = "unimplemented"
        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(unimplementeditem)
        inst.components.equippable:SetOnEquip( onequip_green )
        inst.components.equippable:SetOnUnequip( onunequip_green )
    return inst
end

local function orange(inst)
    local inst = commonfn(inst)
        inst.AnimState:PlayAnimation("orangeamulet")
        inst.components.inspectable.nameoverride = "unimplemented"
        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(unimplementeditem)
        inst.components.equippable:SetOnEquip( onequip_orange )
        inst.components.equippable:SetOnUnequip( onunequip_orange )
    return inst
end

local function yellow(inst)
    local inst = commonfn(inst)
        inst.AnimState:PlayAnimation("yellowamulet")
        inst.components.inspectable.nameoverride = "unimplemented"
        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(unimplementeditem)
        inst.components.equippable:SetOnEquip( onequip_yellow )
        inst.components.equippable:SetOnUnequip( onunequip_yellow )
    return inst
end


return Prefab( "common/inventory/amulet", red, assets),
Prefab("common/inventory/blueamulet", blue, assets),
Prefab("common/inventory/purpleamulet", purple, assets),
Prefab("common/inventory/orangeamulet", orange, assets),
Prefab("common/inventory/greenamulet", green, assets),
Prefab("common/inventory/yellowamulet", yellow, assets)