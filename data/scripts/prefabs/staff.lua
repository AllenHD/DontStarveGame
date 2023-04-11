local assets=
{
	Asset("ANIM", "data/anim/staffs.zip"),
	Asset("ANIM", "data/anim/swap_staffs.zip"), 
}

local prefabs = 
{
    "ice_projectile",
    "fire_projectile",
    "staffcastfx"
}

---------RED STAFF---------

local function onattack_red(inst, attacker, target)

    if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else            
            target.components.burnable:Ignite()
        end   
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
        if target.sg and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
    end

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
end

local function onlight(inst, target)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

---------BLUE STAFF---------

local function onattack_blue(inst, attacker, target)

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end
    
    if target.components.freezable then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable and target.components.burnable:IsBurning() then
        target.components.burnable:Extinguish()
    end
    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
        if target.sg and not target.sg:HasStateTag("frozen") and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
    end
end

---------PURPLE STAFF---------

local function getrandomposition(inst)
    local ground = GetWorld()
    local centers = {}
    for i,node in ipairs(ground.topology.nodes) do
        table.insert(centers, {x = node.x, z = node.y})
    end
    local pos = centers[math.random(#centers)]
    return Point(pos.x, 0, pos.z)
end

local function canteleport(inst, caster, target)
    if target then
        return target.components.locomotor ~= nil
    end

    return true
end

local function teleport_thread(inst, caster, teletarget, loctarget)
    local ground = GetWorld()

    local t_loc = nil
    if loctarget then
        t_loc = loctarget:GetPosition()
    else
        t_loc = getrandomposition()
    end

    local teleportee = teletarget
    local pt = teleportee:GetPosition()
    if teleportee.components.locomotor then
        teleportee.components.locomotor:StopMoving()
    end

    inst.components.finiteuses:Use(1)

    if ground.topology.level_type == "cave" then
        TheCamera:Shake("FULL", 0.3, 0.02, .5, 40)
        ground.components.quaker:MiniQuake(3, 5, 1.5, teleportee)     
        return
    end

    if teleportee.components.health then
        teleportee.components.health:SetInvincible(true)
    end
    
    GetSeasonManager():DoLightningStrike(pt)
    teleportee:Hide()

    if teleportee == GetPlayer() then
        TheFrontEnd:Fade(false, 2)
        Sleep(3)
    end
    
    if caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    end
    if ground.components.seasonmanager then
        ground.components.seasonmanager:ForcePrecip()
    end

    teleportee.Transform:SetPosition(t_loc.x, 0, t_loc.z)

    if teleportee == GetPlayer() then
        TheCamera:Snap()
        TheFrontEnd:DoFadeIn(1)
        Sleep(1)
    end
    if loctarget and loctarget.onteleto then loctarget.onteleto(loctarget) end
    GetSeasonManager():DoLightningStrike(t_loc)
    teleportee:Show()
    if teleportee.components.health then
        teleportee.components.health:SetInvincible(false)
    end

    if teleportee == GetPlayer() then
        teleportee.sg:GoToState("wakeup")
        teleportee.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
    end
end

local function teleport_func(inst, target)
    local mindistance = 30
    local caster = inst.components.inventoryitem.owner
    local tar = target or caster
    local pt = tar:GetPosition()
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 9000, {"telebase"})

    if #ents <= 0 then
        --There's no bases, active or inactive. Teleport randomly.
        inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
        return
    end

    local targets = {}
    for k,v in pairs(ents) do
        local v_pt = v:GetPosition()
        if distsq(pt, v_pt) >= mindistance * mindistance then
            table.insert(targets, {base = v, distance = distsq(pt, v_pt)}) 
        end
    end

    table.sort(targets, function(a,b) return (a.distance) < (b.distance) end)
    for i = 1, #targets do
        local teletarget = targets[i]
        if teletarget.base and teletarget.base.canteleto(teletarget.base) then
            inst.task = inst:StartThread(function()  teleport_thread(inst, caster, tar, teletarget.base) end)
            return
        end
    end

    inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
end


---------COMMON FUNCTIONS---------

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

local function commonfn(colour)

    local onequip = function(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", colour.."staff")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
    end

    local onunequip = function(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("staffs")
    anim:SetBuild("staffs")
    anim:PlayAnimation(colour.."staff")
    -------   
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    
    return inst
end


---------COLOUR SPECIFIC CONSTRUCTIONS---------

local function red()
    local inst = commonfn("red")

    inst:AddTag("firestaff")
    inst:AddTag("rangedfireweapon")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_red)
    inst.components.weapon:SetProjectile("fire_projectile")

    inst:AddComponent("lighter")
    inst.components.lighter:SetOnLightFn(onlight)

    inst.components.finiteuses:SetMaxUses(TUNING.FIRESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.FIRESTAFF_USES)

    return inst
end

local function blue()
    local inst = commonfn("blue")
    
    inst:AddTag("icestaff")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_blue)
    inst.components.weapon:SetProjectile("ice_projectile")

    inst.components.finiteuses:SetMaxUses(TUNING.ICESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.ICESTAFF_USES)
    
    return inst
end

local function purple()
    local inst = commonfn("purple")
    inst.fxcolour = {92/255, 0, 197/255}
    inst.components.finiteuses:SetMaxUses(TUNING.TELESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.TELESTAFF_USES)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(teleport_func)
    inst.components.spellcaster.inventoryonly = false
    inst.components.spellcaster:SetSpellTestFn(canteleport)
    -- inst:AddComponent("useableitem")
    -- inst.components.useableitem:SetOnUseFn(teleport_func)

    return inst
end

local function yellow()
    local inst = commonfn("yellow")
    inst.fxcolour = {1, 230/255, 0}
    inst.components.inspectable.nameoverride = "unimplemented"
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(unimplementeditem)
    return inst
end

local function orange()
    local inst = commonfn("orange")
    inst.fxcolour = {1, 145/255, 0}
    inst.components.inspectable.nameoverride = "unimplemented"
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(unimplementeditem)
    return inst
end

local function green()
    local inst = commonfn("green")
    inst.fxcolour = {7/255, 196/255, 0}
    inst.components.inspectable.nameoverride = "unimplemented"
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(unimplementeditem)
    return inst
end

return Prefab( "common/inventory/icestaff", blue, assets, prefabs),
Prefab("common/inventory/firestaff", red, assets, prefabs),
Prefab("common/inventory/telestaff", purple, assets, prefabs),
Prefab("common/inventory/orangestaff", orange, assets, prefabs),
Prefab("common/inventory/greenstaff", green, assets, prefabs),
Prefab("common/inventory/yellowstaff", yellow, assets, prefabs)