local assets =
{
	Asset("ANIM", "data/anim/meat_rack.zip"),
	Asset("ANIM", "data/anim/meat_rack_food.zip"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end
        
local function onhit(inst, worker)
	if inst.components.dryer and inst.components.dryer:IsDrying() then
		inst.AnimState:PlayAnimation("hit_full")
		inst.AnimState:PushAnimation("drying_pre", false)
		inst.AnimState:PushAnimation("drying_loop", true)
	elseif inst.components.dryer and inst.components.dryer:IsDone() then
		inst.AnimState:PlayAnimation("hit_full")
		inst.AnimState:PushAnimation("idle_full", false)
	else
		inst.AnimState:PlayAnimation("hit_empty")
		inst.AnimState:PushAnimation("idle_empty", false)
	end
end

local function getstatus(inst)
    if inst.components.dryer and inst.components.dryer:IsDrying() then
        return "DRYING"
    elseif inst.components.dryer and inst.components.dryer:IsDone() then
        return "DONE"
    end
end

local function onstartdrying(inst, dryable)
    inst.AnimState:PlayAnimation("drying_pre")
	inst.AnimState:PushAnimation("drying_loop", true)
    inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", dryable)
end

local function setdone(inst, product)
    inst.AnimState:PlayAnimation("idle_full")
    inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", product)
end

local function ondonedrying(inst, product)
    inst.AnimState:PlayAnimation("drying_pst")
    local ondonefn -- must be forward declared, as it refers to itself in the function body
    ondonefn = function(inst)
        inst:RemoveEventCallback("animover", ondonefn)
        setdone(inst, product)
    end
    inst:ListenForEvent("animover", ondonefn)
end

local function onharvested(inst)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_empty", false)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
 
 	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "meatrack.png" )
	
    inst.entity:AddSoundEmitter()
    inst:AddTag("structure")

    anim:SetBank("meat_rack")
    anim:SetBuild("meat_rack")
    anim:PlayAnimation("idle_empty")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- should be DRY
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent("dryer")
	inst.components.dryer:SetStartDryingFn(onstartdrying)
	inst.components.dryer:SetDoneDryingFn(ondonedrying)
	inst.components.dryer:SetContinueDryingFn(onstartdrying)
	inst.components.dryer:SetContinueDoneFn(setdone)
	inst.components.dryer:SetOnHarvestFn(onharvested)
    
    inst:AddComponent("inspectable")
    
    inst.components.inspectable.getstatus = getstatus
	MakeSnowCovered(inst, .01)	
	inst:ListenForEvent( "onbuilt", onbuilt)
    return inst
end

return Prefab( "common/objects/meatrack", fn, assets ),
	   MakePlacer("common/meatrack_placer", "meat_rack", "meat_rack", "idle_empty")  
