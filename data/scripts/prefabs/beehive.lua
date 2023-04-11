local prefabs = 
{
	"bee",
	"killerbee",
    "honey",
    "honeycomb",
}

local assets =
{
    Asset("ANIM", "data/anim/beehive.zip"),
	Asset("SOUND", "data/sound/bee.fsb"),
}


local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/bee_hive_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function StartSpawningFn(inst)
	local fn = function(world)
		
		if inst.components.childspawner and GetSeasonManager() and GetSeasonManager():IsSummer() then
			inst.components.childspawner:StartSpawning()
		end
	end
	return fn
end

local function StopSpawningFn(inst)
	local fn = function(world)
		if inst.components.childspawner then
			inst.components.childspawner:StopSpawning()
		end
	end
	return fn
end

local function OnIgnite(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("cocoon_dead", true)
    inst.Physics:ClearCollisionMask()
    
    inst.SoundEmitter:KillSound("loop")
    
    inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_destroy")
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	
    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "beehive.png" )

	anim:SetBank("beehive")
	anim:SetBuild("beehive")
	anim:PlayAnimation("cocoon_small", true)

    inst:AddTag("structure")
	inst:AddTag("hive")
    
    -------------------
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200)

    -------------------
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "bee"
	inst.components.childspawner:SetRegenPeriod(TUNING.BEEHIVE_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.BEEHIVE_RELEASE_TIME)
	inst.components.childspawner:SetMaxChildren(TUNING.BEEHIVE_BEES)
	if GetSeasonManager() and GetSeasonManager():IsSummer() then
		inst.components.childspawner:StartSpawning()
	end
	inst:ListenForEvent( "dusktime", StopSpawningFn(inst), GetWorld())
	inst:ListenForEvent( "daytime", StartSpawningFn(inst), GetWorld())
	
    ---------------------  
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"honey","honey","honey","honeycomb"})
    ---------------------  

    ---------------------        
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    -------------------
    
    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(
        function(inst, attacker, damage) 
            if inst.components.childspawner then
                inst.components.childspawner:ReleaseAllChildren(attacker, "killerbee")
            end
            if not inst.components.health:IsDead() then
                inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
                inst.AnimState:PlayAnimation("cocoon_small_hit")
                inst.AnimState:PushAnimation("cocoon_small", true)
            end
        end)
    inst:ListenForEvent("death", OnKilled)
    
    ---------------------       
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)
    
    ---------------------
    
    inst:AddComponent("inspectable")
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
    
    
    
	return inst
end

return Prefab( "forest/monsters/beehive", fn, assets, prefabs ) 

