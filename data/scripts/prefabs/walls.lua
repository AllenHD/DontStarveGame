require "prefabutil"

function MakeWallType(data)

	local assets =
	{
		Asset("ANIM", "data/anim/wall.zip"),
		Asset("ANIM", "data/anim/wall_".. data.name..".zip"),
	}

	local function ondeploywall(inst, pt, deployer)
		--inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
		local wall = SpawnPrefab("wall_"..data.name) 
		if wall then 
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			wall.Physics:SetCollides(false)
			wall.Physics:Teleport(pt.x, pt.y, pt.z) 
			wall.Physics:SetCollides(true)
			inst.components.stackable:Get():Remove()

		    local ground = GetWorld()
		    if ground then
		    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		    end
		end 
		
	end


	local function onhammered(inst, worker)

		if data.maxloots and data.loot then
			local num_loots = math.max(1, math.floor(data.maxloots*inst.components.health:GetPercent()))
			for k = 1, num_loots do
				inst.components.lootdropper:SpawnLootPrefab(data.loot)
			end
		end		
		
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		
		if data.destroysound then
			inst.SoundEmitter:PlaySound(data.destroysound)		
		end
		
		inst:Remove()
	end


	local function test_wall(inst, pt)
		return true
	end

	local function makeobstacle(inst)
	
	    inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:CollidesWith(COLLISION.ITEMS)
		inst.Physics:CollidesWith(COLLISION.CHARACTERS)

	    local ground = GetWorld()
	    if ground then
	    	local pt = Point(inst.Transform:GetWorldPosition())
			--print("    at: ", pt)
	    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
	    end
		
		
	end

	local function clearobstacle(inst)
	    inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:CollidesWith(COLLISION.ITEMS)
	    local ground = GetWorld()
	    if ground then
	    	local pt = Point(inst.Transform:GetWorldPosition())
	    	--print("    at: ", pt)
	    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	    end
		
	end


	local function onhealthchange(inst, old_percent, new_percent)
		
		if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
		if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

		local anim_to_play = nil
		if new_percent <= 0 then
			anim_to_play = "0"
		elseif new_percent <= .4 then
			anim_to_play = "1_4"
		elseif new_percent <= .5 then
			anim_to_play = "1_2"
		elseif new_percent <= .9 then
			anim_to_play = "3_4"
		else
			anim_to_play = "1"
		end

		if old_percent > new_percent and new_percent > 0 then
		
			
			inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
			inst.AnimState:PushAnimation(anim_to_play)		
		else
			inst.AnimState:PlayAnimation(anim_to_play)		
		end
	end
	
	local function itemfn(Sim)

		local inst = CreateEntity()
		inst:AddTag("wallbuilder")
		
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
	    
		inst.AnimState:SetBank("wall")
		inst.AnimState:SetBuild("wall_"..data.name)
		inst.AnimState:PlayAnimation("idle")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
		inst.components.stackable.stacksize = data.stacksize
		
		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("repairer")
		inst.components.repairer.repairmaterial = data.name
		inst.components.repairer.value = 50
	    
		
		if data.flammable then
			MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
			MakeSmallPropagator(inst)
			
			inst:AddComponent("fuel")
			inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
		end
		
		inst:AddComponent("deployable")
		inst.components.deployable.ondeploy = ondeploywall
		inst.components.deployable.test = test_wall
		inst.components.deployable.min_spacing = 0
		inst.components.deployable.placer = "wall_"..data.name.."_placer"
		
		return inst
	end



	
	local function onhit(inst)
		if data.destroysound then
			inst.SoundEmitter:PlaySound(data.destroysound)		
		end
	end

	local function onrepaired(inst)
		if data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end
		makeobstacle(inst)
	end
	    
	local function onload(inst, data)
		--print("walls - onload")
		makeobstacle(inst)
		if inst.components.health:GetPercent() <= 0 then
			clearobstacle(inst)
		end
	end

	local function onremoveentity(inst)
		--print("walls - onremoveentity")
		clearobstacle(inst)
	end

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		--trans:SetScale(1.3,1.3,1.3)
		inst:AddTag("wall")
		MakeObstaclePhysics(inst, .5)    

		anim:SetBank("wall")
		anim:SetBuild("wall_"..data.name)
	    anim:PlayAnimation("half", false)
	    
		inst:AddComponent("inspectable")
		inst:AddComponent("lootdropper")
		
		for k,v in ipairs(data.tags) do
		    inst:AddTag(v)
		end
		
		
		inst:AddComponent("repairable")
		inst.components.repairable.repairmaterial = data.name
		inst.components.repairable.onrepaired = onrepaired
		
		inst:AddComponent("combat")
		inst.components.combat.onhitfn = onhit
		
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(data.maxhealth)
		inst.components.health.currenthealth = data.maxhealth / 2
		inst.components.health.ondelta = onhealthchange
		inst.components.health.nofadeout = true
		inst:AddTag("noauradamage")
		
		if data.flammable then
			MakeLargeBurnable(inst)
			MakeLargePropagator(inst)
			inst.components.burnable.flammability = .5
			
			--lame!
			if data.name == "wood" then
				inst.components.propagator.flashpoint = 30+math.random()*10			
			end
		else
			inst.components.health.fire_damage_scale = 0
		end

		if data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end
		
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(3)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit) 
				
		
	    inst.OnLoad = onload
	    inst.OnRemoveEntity = onremoveentity
		
		MakeSnowCovered(inst)
		
		return inst
	end


	return Prefab( "common/wall_"..data.name, fn, assets),
		   Prefab( "common/wall_"..data.name.."_item", itemfn, assets),
		   MakePlacer("common/wall_"..data.name.."_placer", "wall", "wall_"..data.name, "half", false, false, true) 
end



local wallprefabs = {}

--6 rock, 8 wood, 4 straw
local walldata = {
			{name = "stone", tags={"stone"}, loot = "rocks", maxloots = 2, stacksize = 6, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
			{name = "wood", tags={"wood"}, loot = "log", maxloots = 2, stacksize = 8, maxhealth=TUNING.WOODWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_wood", destroysound="dontstarve/common/destroy_wood"},
			{name = "hay", tags={"grass"}, loot = "cutgrass", maxloots = 2, stacksize = 4, maxhealth=TUNING.HAYWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_straw", destroysound="dontstarve/common/destroy_straw"}}

for k,v in pairs(walldata) do
	local wall, item, placer = MakeWallType(v)
	table.insert(wallprefabs, wall)
	table.insert(wallprefabs, item)
	table.insert(wallprefabs, placer)
end


return unpack(wallprefabs) 
