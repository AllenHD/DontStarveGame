
function MakeHat(name)

    local fname = "hat_"..name
    local symname = name.."hat"
    local texture = symname..".tex"
    local prefabname = symname
    local assets=
    {
        Asset("ANIM", "data/anim/"..fname..".zip"),
        --Asset("IMAGE", texture),
    }

    local function onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        
        if owner:HasTag("player") then
			owner.AnimState:Hide("HEAD")
			owner.AnimState:Show("HEAD_HAIR")
		end
        
		if inst.components.fueled then
			inst.components.fueled:StartConsuming()        
		end
    end

    local function onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

		if owner:HasTag("player") then
	        owner.AnimState:Show("HEAD")
			owner.AnimState:Hide("HEAD_HAIR")
		end

		if inst.components.fueled then
			inst.components.fueled:StopConsuming()        
		end
    end
    
    local function opentop_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")
        
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")

		if inst.components.fueled then
			inst.components.fueled:StartConsuming()        
		end
    end


    local function simple()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

        inst.components.equippable:SetOnEquip( onequip )

        inst.components.equippable:SetOnUnequip( onunequip )

        return inst
    end

    local function bee()
        local inst = simple()
		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
		inst.components.armor:SetTags({"bee"})
		return inst
    end
   
   
    local function generic_perish(inst)
        inst:Remove()
    end
   
    local function earmuffs()
        local inst = simple()
        inst:AddComponent("insulator")
        inst.components.insulator.insulation = TUNING.INSULATION_SMALL
        inst.components.equippable:SetOnEquip( opentop_onequip )
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
		inst.AnimState:SetRayTestOnBB(true)
		return inst
    end
   
    local function winter()
        local inst = simple()
		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = TUNING.DAPPERNESS_TINY
        inst:AddComponent("insulator")
        inst.components.insulator.insulation = TUNING.INSULATION_MED
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WINTERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
		return inst
    end

    local function football()
        local inst = simple()
		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
		return inst
    end

    local function feather_equip(inst, owner)
        onequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY_FEATHERHAT)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX_FEATHERHAT)
        end
    end
    local function feather_unequip(inst, owner)
        onunequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX)
        end
    end
    local function feather()
        local inst = simple()
        
		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL
        
        inst.components.equippable:SetOnEquip( feather_equip )
        inst.components.equippable:SetOnUnequip( feather_unequip )
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.FEATHERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
		return inst
    end

    local function beefalo_equip(inst, owner)
        onequip(inst, owner)
        owner:AddTag("beefalo")
    end
    local function beefalo_unequip(inst, owner)
        onunequip(inst, owner)
        owner:RemoveTag("beefalo")
    end
    local function beefalo()
        local inst = simple()
        inst.components.equippable:SetOnEquip( beefalo_equip )
        inst.components.equippable:SetOnUnequip( beefalo_unequip )

        inst:AddComponent("insulator")
        inst.components.insulator.insulation = TUNING.INSULATION_LARGE
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
        
        return inst
    end

    local function walrus()
        local inst = simple()

        inst:AddComponent("dapperness")
        inst.components.dapperness.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("insulator")
        inst.components.insulator.insulation = TUNING.INSULATION_MED
        
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
        return inst
    end

    local function miner_equip(inst, owner)
        onequip(inst, owner)
        inst.Light:Enable(true)
        owner.SoundEmitter:PlaySound("dontstarve/common/switch_toggle")
    end
    local function miner_unequip(inst, owner)
        onunequip(inst, owner)
        owner.SoundEmitter:PlaySound("dontstarve/common/switch_toggle")
        inst.Light:Enable(false)
    end
    local function miner_perish(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner then
            owner:PushEvent("torchranout", {torch = inst})
        end
        inst:Remove()
        if owner and owner.components.inventory then
            local strawhat = SpawnPrefab("strawhat")
            owner.components.inventory:GiveItem(strawhat)
        end
    end
    local function miner_drop(inst)
        inst.Light:Enable(false)
    end

    local function miner()
        local inst = simple()

        local light = inst.entity:AddLight()
        light:SetFalloff(0.4)
        light:SetIntensity(.7)
        light:SetRadius(2.5)
        light:SetColour(180/255, 195/255, 150/255)
        light:Enable(false)

        inst.components.inventoryitem:SetOnDroppedFn( miner_drop )
        inst.components.equippable:SetOnEquip( miner_equip )
        inst.components.equippable:SetOnUnequip( miner_unequip )
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "MINERHAT"
        inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
        inst.components.fueled:SetDepletedFn(miner_perish)
        return inst
    end


    local function spider_disable(inst)
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner:RemoveTag("monster")
            for k,v in pairs(owner.components.leader.followers) do
                if k:HasTag("spider") and k.components.combat then
                    k.components.combat:SuggestTarget(owner)
                end
            end
            owner.components.leader:RemoveFollowersByTag("spider")
        end
    end
    local function spider_update(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, {"spider"})
            for k,v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end
    local function spider_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            owner:AddTag("monster")
        end
        inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)
    end
    local function spider_equip(inst, owner)
        onequip(inst, owner)
        spider_enable(inst)
    end
    local function spider_unequip(inst, owner)
        onunequip(inst, owner)
        spider_disable(inst)
    end

    local function spider_perish(inst)
        spider_disable(inst)
        inst:Remove()
    end


	local function top()
		local inst = simple()
		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = TUNING.DAPPERNESS_MED
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(spider_perish)
		return inst
	end
	
    local function spider()
        local inst = simple()

		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = -TUNING.DAPPERNESS_SMALL

        inst.components.inventoryitem:SetOnDroppedFn( spider_disable )
        inst.components.equippable:SetOnEquip( spider_equip )
        inst.components.equippable:SetOnUnequip( spider_unequip )
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "SPIDERHAT"
        inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(spider_perish)
        return inst
    end

    local function stopusingbush(inst, data)
        local hat = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and not (data.statename == "hide_idle" or data.statename == "hide") then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function onequipbush(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        
        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end
        
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end

        inst:ListenForEvent("newstate", stopusingbush, owner) 
    end

    local function onunequipbush(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()        
        end

        inst:RemoveEventCallback("newstate", stopusingbush, owner)
    end

    local function onusebush(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.sg:GoToState("hide")
        end
    end
    
    local function bush()
        local inst = simple()

        inst:AddTag("hide")
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/bushhat"

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(onusebush)

        inst.components.equippable:SetOnEquip( onequipbush )
        inst.components.equippable:SetOnUnequip( onunequipbush )


        return inst
    end
    
	local function flower()
		local inst = simple()
		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = TUNING.DAPPERNESS_TINY

		inst:AddComponent("edible")
		inst.components.edible.healthvalue = TUNING.HEALING_SMALL
		inst.components.edible.hungervalue = 0
		inst.components.edible.sanityvalue = TUNING.SANITY_SMALL
		inst.components.edible.foodtype = "VEGGIE"
		
		
		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
		inst.components.perishable:StartPerishing()
		inst.components.perishable:SetOnPerishFn(generic_perish)
        inst.components.equippable:SetOnEquip( opentop_onequip )
		return inst
    end 

    local function slurtle()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMOR_SLURTLEHAT_ABSORPTION)
        return inst
    end
    
    local fn = nil
    local prefabs = nil
    if name == "bee" then
        fn = bee
    elseif name == "top" then
		fn = top
    elseif name == "feather" then
		fn = feather
    elseif name == "football" then
		fn = football
    elseif name == "flower" then
		fn = flower
    elseif name == "spider" then
		fn = spider
    elseif name == "miner" then
        fn = miner
        prefabs =
        {
            "strawhat",
        }
    elseif name == "earmuffs" then
		fn = earmuffs
    elseif name == "winter" then
		fn = winter
    elseif name == "beefalo" then
		fn = beefalo
    elseif name == "bush" then
        fn = bush
    elseif name == "walrus" then
        fn = walrus
    elseif name == "slurtle" then
        fn = slurtle
    end

    return Prefab( "common/inventory/"..prefabname, fn or simple, assets, prefabs)
end

return MakeHat("straw"),
        MakeHat("top"),
        MakeHat("beefalo"),
        MakeHat("feather"),
        MakeHat("bee"),
        MakeHat("miner"),
        MakeHat("spider"),
        MakeHat("football"),
        MakeHat("earmuffs"),
        MakeHat("winter"),
        MakeHat("bush"),
        MakeHat("flower"),
        MakeHat("walrus"),
        MakeHat("slurtle") 
