assets = 
{
	Asset("ANIM", "data/anim/statue_small.zip"),
	Asset("ANIM", "data/anim/statue_small_harp_build.zip"),
}

local prefabs =
{
	--marble drops
	"marble",
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.AnimState:SetRayTestOnBB(true) --TODO: remove this when artists adds a mouseover region

	MakeObstaclePhysics(inst, 0.66)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"marble","marble"}) --Add other loot?
	inst.components.lootdropper:AddChanceLoot("marble", 0.33)

	anim:SetBank("statue_small")
	anim:SetBuild("statue_small")
	anim:OverrideSymbol("swap_statue", "statue_small_harp_build", "swap_statue")
	anim:PlayAnimation("full")


	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "statue_small.png" )

	inst:AddComponent("inspectable")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
	inst.components.workable:SetOnWorkCallback(          
		function(inst, worker, workleft)
	        local pt = Point(inst.Transform:GetWorldPosition())
	        if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
	            inst.components.lootdropper:DropLoot(pt)
	            inst:Remove()
	        else	            
	            if workleft < TUNING.MARBLEPILLAR_MINE*(1/3) then
	                inst.AnimState:PlayAnimation("low")
	            elseif workleft < TUNING.MARBLEPILLAR_MINE*(2/3) then
	                inst.AnimState:PlayAnimation("med")
	            else
	                inst.AnimState:PlayAnimation("full")
	            end
	        end
	    end)
	return inst
end

return Prefab("forest/objects/statueharp", fn, assets, prefabs) 
