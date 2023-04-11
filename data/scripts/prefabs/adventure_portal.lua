local assets=
{
	Asset("ANIM", "data/anim/portal_adventure.zip"),
}


local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.GENERIC
end

local function OnActivate(inst)
	--do popup confirmation
	--do portal presentation 
	--save and do restart
	SetHUDPause(true,"portal")
	local function startadventure()
		local function onsaved()
		    local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot()}
		    TheSim:SetInstanceParameters(params)
			SendAccumulatedProfileStats()
		    TheSim:Reset()
		end
		SetHUDPause(false)
		GetPlayer().sg:GoToState("teleportato_teleport")
		GetPlayer():DoTaskInTime(5, function() SaveGameIndex:StartAdventure(onsaved) end)
	end

	TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.STARTADVENTURE.TITLE, STRINGS.UI.STARTADVENTURE.BODY, 
			{{text=STRINGS.UI.STARTADVENTURE.YES, cb = startadventure},
			 {text=STRINGS.UI.STARTADVENTURE.NO, cb = function() SetHUDPause(false) inst.components.activatable.inactive = true end}  }))
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "portal.png" )
   
    anim:SetBank("portal_adventure")
    anim:SetBuild("portal_adventure")
    anim:PlayAnimation("idle_off", true)
    
    inst:AddComponent("inspectable")

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
	inst.components.playerprox.onnear = function()
		inst.AnimState:PushAnimation("activate", false)
		inst.AnimState:PushAnimation("idle_loop_on", true)
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_activate")
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_idle", "idle")

		inst:DoTaskInTime(1, function()
			if inst.ragtime_playing == nil then
				inst.ragtime_playing = true
				inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/ragtime", "ragtime")
			else
				inst.SoundEmitter:SetVolume("ragtime",1)
			end
		end)
	end
	
	inst.components.playerprox.onfar = function()
		inst.AnimState:PushAnimation("deactivate", false)
		inst.AnimState:PushAnimation("idle_off", true)
		inst.SoundEmitter:KillSound("idle")
		inst.SoundEmitter:PlaySound("dontstarve/common/maxwellportal_shutdown")

		inst:DoTaskInTime(1, function()
			inst.SoundEmitter:SetVolume("ragtime",0)
		end)
	end

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

    return inst
end

return Prefab( "common/adventure_portal", fn, assets) 
