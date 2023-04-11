local assets=
{
    Asset("ANIM", "data/anim/pine_needles.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()

    
    inst.AnimState:SetBank("pine_needles")
    inst.AnimState:SetBuild("pine_needles")
    inst.AnimState:PlayAnimation(math.random() < .5 and "chop" or "fall")
    inst:AddTag("FX")
    inst.persists = false
    inst:ListenForEvent("animover", function() inst:Remove() end)
    return inst
end

return Prefab( "common/pine_needles", fn, assets) 

