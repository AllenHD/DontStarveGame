local assets =
{
	Asset("ANIM", "data/anim/impact.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.Transform:SetTwoFaced()
	
    anim:SetBank("impact")
    anim:SetBuild("impact")
    anim:PlayAnimation("idle")
    anim:SetFinalOffset(-1)
    inst:AddTag("fx")
    
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    return inst
end

return Prefab("common/fx/impact", fn, assets) 
