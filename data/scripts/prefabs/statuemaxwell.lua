assets = 
{
	Asset("ANIM", "data/anim/statue_maxwell.zip"),
}

local prefabs =
{
	"marble",
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst:AddTag("maxwell")

	MakeObstaclePhysics(inst, 0.66)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"marble","marble"}) --Does this drop marble?
	inst.components.lootdropper:AddChanceLoot("marble", 0.33)

	anim:SetBank("statue_maxwell")
	anim:SetBuild("statue_maxwell")
	anim:PlayAnimation("idle_full")

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "statue.png" )

	inst:AddComponent("inspectable")
	inst:AddComponent("workable")
	--TODO: Custom variables for mining speed/cost
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
	                inst.AnimState:PlayAnimation("hit_low")
	                inst.AnimState:PushAnimation("idle_low")
	            elseif workleft < TUNING.MARBLEPILLAR_MINE*(2/3) then
	                inst.AnimState:PlayAnimation("hit_med")
	                inst.AnimState:PushAnimation("idle_med")
	            else
	                inst.AnimState:PlayAnimation("hit_full")
	                inst.AnimState:PushAnimation("idle_full")
	            end
	        end
	    end)
	return inst
end

return Prefab("forest/objects/statuemaxwell", fn, assets, prefabs) 
