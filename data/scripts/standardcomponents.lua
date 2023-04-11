function DefaultIgniteFn(inst)
	if inst.components.burnable then inst.components.burnable:Ignite() end 
end

function DefaultBurnFn(inst)
    if inst.components.workable and inst.components.workable.action ~= ACTIONS.HAMMER then
        inst.components.workable:SetWorkLeft(0)
    end
    if inst.components.pickable then
        inst:RemoveComponent("pickable")
    end
    if inst.components.growable then
        inst:RemoveComponent("growable")
    end
    if inst.components.inventoryitem and not inst.components.inventoryitem:IsHeld() then
        inst:RemoveComponent("inventoryitem")
    end
    
    if not inst:HasTag("tree") then
		inst.persists = false
	end
end

function DefaultBurntFn(inst)
    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    
    if inst.components.stackable then
        ash.components.stackable.stacksize = inst.components.stackable.stacksize
    end

    inst:Remove()
end

local burnfx = 
{
    character = "character_fire",
    generic = "fire",
}

function MakeSmallBurnable(inst, time, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(time or 5)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
end

function MakeMediumBurnable(inst, time, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(time or 10)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
end

function MakeLargeBurnable(inst, time, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(4)
    inst.components.burnable:SetBurnTime(time or 15)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
end

function MakeSmallPropagator(inst)
   
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 5 + math.random()*5
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 3
    inst.components.propagator.heatoutput = 8
    
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true
end

function MakeLargePropagator(inst)
    
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 15+math.random()*10
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 6
    inst.components.propagator.heatoutput = 12
    
    inst.components.propagator.damagerange = 3
    inst.components.propagator.damages = true
end

function MakeSmallBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(1)
    inst.components.burnable:SetBurnTime(6)
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 0), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeMediumBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(8)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 0), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeLargeBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 0), sym)
    MakeLargePropagator(inst)
    inst.components.propagator.acceptsheat = false
end

local shatterfx = 
{
    character = "shatter",
}

function MakeTinyFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(1)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeSmallFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeMediumFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(3)
    inst.components.freezable:SetResistance(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeLargeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(4)
    inst.components.freezable:SetResistance(3)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeHugeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(5)
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeInventoryPhysics(inst)

    inst.entity:AddPhysics()
    inst.Physics:SetSphere(.5)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(.1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)

end


function MakeCharacterPhysics(inst, mass, rad)

    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function MakeGhostPhysics(inst, mass, rad)

    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    --inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end


function MakeObstaclePhysics(inst, rad, height)

    height = height or 2

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(9999999) --this is lame. Bullet wants 0 mass for static objects, for for some reason it is slow when we do that
    inst.Physics:SetCapsule(rad,height)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:SetFriction(10000)
    
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function RemovePhysicsColliders(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end


local function OnGrowSeasonChange(inst)
	if not GetSeasonManager() then return end
	
	if inst.components.pickable then
		if GetSeasonManager():IsWinter() then
			inst.components.pickable:Pause()
		else
			inst.components.pickable:Resume()
		end
	end
end

function MakeNoGrowInWinter(inst)
	if not GetSeasonManager() then return end
	
	inst:ListenForEvent("seasonChange", function() OnGrowSeasonChange(inst) end, GetWorld())
	if GetSeasonManager():IsWinter() then
		OnGrowSeasonChange(inst)
	end
end

local function OnSnowCoverChange(inst, thresh)
	thresh = thresh or .2
	local snow_cover = GetSeasonManager():GetSnowPercent()

	if snow_cover > thresh then
		inst.AnimState:Show("snow")
	else
		inst.AnimState:Hide("snow")
	end
end

function MakeSnowCovered(inst, thresh)
	if not GetSeasonManager() then return end
	thresh = thresh or .02
	inst.AnimState:OverrideSymbol("snow", "snow", "snow")
	inst:ListenForEvent("snowcoverchange", function() OnSnowCoverChange(inst, thresh) end, GetWorld())
	OnSnowCoverChange(inst, thresh)
end
