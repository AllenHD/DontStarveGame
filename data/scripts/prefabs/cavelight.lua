local assets=
{
	Asset("ANIM", "data/anim/cave_exit_lightsource.zip"),
}


local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/cave/forestAMB_spot", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

    anim:SetBank("cavelight")
    anim:SetBuild("cave_exit_lightsource")
    anim:PlayAnimation("idle_loop", true)

    inst:AddTag("NOCLICK")
    --anim:PlayAnimation("down")
    --anim:PushAnimation("idle_loop", true)

    local light = inst.entity:AddLight()
    light:SetFalloff(0.3)
    light:SetIntensity(.9)
    light:SetRadius(5)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(true)

    inst.AnimState:SetMultColour(255/255,177/255,32/255,0)

    return inst
end

return Prefab( "common/cavelight", fn, assets) 
