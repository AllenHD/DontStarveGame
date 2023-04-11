local stalagmite_tall_assets = 
{
	Asset("ANIM", "data/anim/rock_stalagmite_tall.zip"),
}

local prefabs =
{
	"rocks",
	"nitre",
	"flint",
	"goldnugget",
}

local function workcallback(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
		inst:Remove()
	else			
		if workleft <= TUNING.ROCKS_MINE*(1/3) then
			inst.AnimState:PlayAnimation("low_"..inst.type)
		elseif workleft <= TUNING.ROCKS_MINE*(2/3) then
			inst.AnimState:PlayAnimation("med_"..inst.type)
		else
			inst.AnimState:PlayAnimation("full_"..inst.type)
		end
	end
end

local function commonfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    inst.type = math.random(2)  -- left or right handed rock
	
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("stalagmite.png")

	MakeObstaclePhysics(inst, 1.)

	anim:SetBank("rock_stalagmite_tall")
	anim:SetBuild("rock_stalagmite_tall")

	inst:AddComponent("lootdropper") 
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "stalagmite_tall"

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

	inst.components.workable:SetOnWorkCallback(workcallback)

	return inst
end

local function fullrock()
	local inst = commonfn()
	inst.components.lootdropper:SetLoot({"rocks", "rocks", "goldnugget", "flint"})
	inst.components.lootdropper:AddChanceLoot("goldnugget", 0.25)
	inst.components.lootdropper:AddChanceLoot("flint", 0.6)
	inst.AnimState:PlayAnimation("full_"..inst.type)
	return inst
end

local function medrock()
	local inst = commonfn()
	isnt.components.workable:SetWorkLeft(TUNING.ROCKS * (2/3))
	inst.AnimState:PlayAnimation("med_" .. inst.type)
	inst.components.lootdropper:SetLoot({"rocks", "flint"})
	inst.components.lootdropper:AddChanceLoot("goldnugget", 0.15)
	inst.components.lootdropper:AddChanceLoot("flint", 0.6)
	return inst
end

local function lowrock()
	local inst = commonfn()
	isnt.components.workable:SetWorkLeft(TUNING.ROCKS * (1/3))
	inst.AnimState:PlayAnimation("low_" .. inst.type)
	inst.components.lootdropper:SetLoot({"rocks", "flint"})
	inst.components.lootdropper:AddChanceLoot("goldnugget", 0.15)
	inst.components.lootdropper:AddChanceLoot("flint", 0.3)
	return inst
end

return Prefab("cave/objects/stalagmite_tall_full", fullrock, stalagmite_tall_assets, prefabs),
       Prefab("cave/objects/stalagmite_tall_med", medrock, stalagmite_tall_assets, prefabs),
       Prefab("cave/objects/stalagmite_tall_low", lowrock, stalagmite_tall_assets, prefabs),
       Prefab("cave/objects/stalagmite_tall", fullrock, stalagmite_tall_assets, prefabs) 

