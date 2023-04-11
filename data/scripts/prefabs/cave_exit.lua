local assets=
{
	Asset("ANIM", "data/anim/cave_exit_rope.zip"),
}


local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.CLIMB
end

local function onnear(inst)
	inst.AnimState:PlayAnimation("down")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_down")
end

local function onfar(inst)
    inst.AnimState:PlayAnimation("up")
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
end



local function OnActivate(inst)
	--do popup confirmation
	--do portal presentation 
	--decrement the depth counter
	--save and do restart
	SetHUDPause(true)
	local function startadventure()


		local function onsaved()
		    local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot()}
		    TheSim:SetInstanceParameters(params)
			SendAccumulatedProfileStats()
		    TheSim:Reset()
		end

		SetHUDPause(false)
		local level = GetWorld().topology.level_number or 1
		if level == 1 then
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:LeaveCave(onsaved) end)
		else
			-- Ascend
			local level = level - 1
			
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterCave(onsaved,nil, inst.cavenum, level) end)
		end
	end

	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.EXITCAVE.TITLE, STRINGS.UI.EXITCAVE.BODY, 
			{{text=STRINGS.UI.EXITCAVE.YES, cb = startadventure},
			 {text=STRINGS.UI.EXITCAVE.NO, cb = function() SetHUDPause(false) inst.components.activatable.inactive = true end}  }))
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --MakeObstaclePhysics(inst, 1)
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "cave_open.png" )
    
    anim:SetBank("exitrope")
    anim:SetBuild("cave_exit_rope")

    --anim:PlayAnimation("down")
    --anim:PushAnimation("idle_loop", true)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(5,7)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst.components.playerprox:SetOnPlayerNear(onnear)

    inst:AddComponent("inspectable")

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

    return inst
end

return Prefab( "common/cave_exit", fn, assets) 
