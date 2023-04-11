local assets=
{
	Asset("ANIM", "data/anim/diviningrod.zip"),
    Asset("SOUND", "data/sound/common.fsb"),
    Asset("ANIM", "data/anim/diviningrod_maxwell.zip")
}

local prefabs = 
{
    "diviningrodstart",
}

local function GetGenderStrings()
    local charactername = GetPlayer().profile:GetValue("characterinthrone") or "wilson"
    if charactername == "wilson" or
    charactername == "woodie" or
    charactername == "waxwell" or
    charactername == "wolfgang" or
    charactername == "wes" then
        return "MALE"
    elseif charactername == "willow" or
    charactername == "wendy" or
    charactername == "wickerbottom" then
        return "FEMALE"
    elseif charactername == "wx78" then
        return "ROBOT"
    else
        return "MALE"
    end
end

local function OnUnlock(inst, key, doer)
    inst.AnimState:PlayAnimation("idle_full")
    inst.throne = TheSim:FindFirstEntityWithTag("maxwellthrone")
    inst.throne.lock = inst
    GetPlayer().components.playercontroller:Enable(false)
    TheFrontEnd:PushScreen(PopupDialogScreen(
        STRINGS.UI.UNLOCKMAXWELL.TITLE, STRINGS.UI.UNLOCKMAXWELL.BODY1..
        STRINGS.CHARACTER_NAMES[GetPlayer().profile:GetValue("characterinthrone") or "waxwell"]..
        string.format(STRINGS.UI.UNLOCKMAXWELL.BODY2, STRINGS.UI.GENDERSTRINGS[GetGenderStrings()].TWO),
        {
            {text=STRINGS.UI.UNLOCKMAXWELL.YES, cb = function()
                inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_add_divining")
                inst.throne.startthread(inst.throne)
            end},

            {text=STRINGS.UI.UNLOCKMAXWELL.NO, cb = function()
                SetHUDPause(false)
                GetPlayer().components.playercontroller:Enable(true)
                inst.components.lock:Lock(doer)
                inst:PushEvent("notfree")                
            end}
        }))
end

local function OnLock(inst, doer)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("diviningrod")
    anim:SetBuild("diviningrod_maxwell")
    anim:PlayAnimation("activate_loop", true)
    
    inst:AddComponent("inspectable")

    inst:AddTag("maxwelllock")

    inst:AddComponent("lock")
    inst.components.lock.locktype = "maxwell"
    inst.components.lock:SetOnUnlockedFn(OnUnlock)
    inst.components.lock:SetOnLockedFn(OnLock)

    return inst
end

return Prefab( "common/maxwelllock", fn, assets, prefabs) 