local assets=
{
	Asset("ANIM", "data/anim/trap_teeth.zip"),
	Asset("ANIM", "data/anim/trap_teeth_maxwell.zip"),
}


local function onfinished_normal(inst)
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("mine")
    inst.persists = false
    inst.AnimState:PushAnimation("used", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:DoTaskInTime(3, function() inst:Remove() end )
end

local function onfinished_maxwell(inst)
    inst:RemoveComponent("mine")
    inst.persists = false
	inst:DoTaskInTime(1.25, function()
		inst.AnimState:PlayAnimation("used", false)
		inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
		inst:DoTaskInTime(3, function() inst:Remove() end )
	end)
end

local function OnExplode(inst, target)
    inst.AnimState:PlayAnimation("trap")
    if target then
        inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_trigger")
	    target.components.combat:GetAttacked(inst, TUNING.TRAP_TEETH_DAMAGE)
    end
    if inst.components.finiteuses then
	    inst.components.finiteuses:Use(1)
    end
end

local function OnReset(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("reset")
	inst.AnimState:PushAnimation("idle", false)
end

local function SetSprung(inst)
    inst.AnimState:PlayAnimation("trap_idle")
end

local function OnDropped(inst)
    if inst.components.mine then
        inst.components.mine:Reset()
    end
end

local function MakeTeethTrapNormal()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "toothtrap.png" )
   
	anim:SetBank("trap_teeth")
	anim:SetBuild("trap_teeth")
	anim:PlayAnimation("idle")
	
	inst:AddTag("trap")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	
	inst:AddComponent("mine")
	inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS)
	inst.components.mine:SetAlignment("player")
	inst.components.mine:SetOnExplodeFn(OnExplode)
	inst.components.mine:SetOnResetFn(OnReset)
	inst.components.mine:SetOnSprungFn(SetSprung)
	inst.components.mine:StartTesting()
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TRAP_TEETH_USES)
	inst.components.finiteuses:SetUses(TUNING.TRAP_TEETH_USES)
	inst.components.finiteuses:SetOnFinished( onfinished_normal )
	
	return inst
end

local function MakeTeethTrapMaxwell()
	local inst = MakeTeethTrapNormal()

	inst.AnimState:SetBank("trap_teeth_maxwell")
	inst.AnimState:SetBuild("trap_teeth_maxwell")

	inst:RemoveComponent("inventoryitem")

	inst.components.mine:SetAlignment("nobody")

	inst.components.finiteuses:SetMaxUses(1)
	inst.components.finiteuses:SetUses(1)
	inst.components.finiteuses:SetOnFinished( onfinished_maxwell )

	return inst
end

return Prefab( "common/inventory/trap_teeth", MakeTeethTrapNormal, assets),
	   Prefab( "common/inventory/trap_teeth_maxwell", MakeTeethTrapMaxwell, assets) 

