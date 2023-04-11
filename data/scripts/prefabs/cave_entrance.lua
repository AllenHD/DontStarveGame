local assets=
{
	Asset("ANIM", "data/anim/cave_entrance.zip"),
}

local prefabs = 
{
	"bat",
	"exitcavelight"
}

local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.SPELUNK
end

local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function OnActivate(inst)

	if not IsGamePurchased() then return end

	--do popup confirmation
	--do portal presentation
	--increment the depth counter 
	--save and do restart
	SetHUDPause(true)

	local function doresetcave()

		SaveGameIndex:ResetCave(inst.cavenum, function() SetHUDPause(false) inst.components.activatable.inactive = true  end)
	end

	local function resetcaveconfirm()
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.RESETCAVE.TITLE, STRINGS.UI.RESETCAVE.BODY, 
			{{text=STRINGS.UI.RESETCAVE.YES, cb = doresetcave },
			 {text=STRINGS.UI.RESETCAVE.NO, cb = function() SetHUDPause(false) inst.components.activatable.inactive = true end}  }))
	end
	
	local function startadventure()
		
		local function onsaved()
		    local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot()}
		    TheSim:SetInstanceParameters(params)
			SendAccumulatedProfileStats()
		    TheSim:Reset()
		end

		local function doenter()
			local level = 1
			if GetWorld().prefab == "cave" then
				level = GetWorld().topology.level_number + 1
			end
			SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterCave(onsaved,nil, inst.cavenum, level) end)
		end

		SetHUDPause(false)
		
		if not inst.cavenum then
			inst.cavenum = SaveGameIndex:GetNumCaves() + 1
			SaveGameIndex:AddCave(nil, doenter)
		else
			doenter()
		end
	end


	local options = {
		{text=STRINGS.UI.ENTERCAVE.YES, cb = startadventure},
		{text=STRINGS.UI.ENTERCAVE.NO, cb = function() SetHUDPause(false) inst.components.activatable.inactive = true end}  
	}

	if inst.cavenum then
		table.insert(options, {text=STRINGS.UI.ENTERCAVE.RESET, cb = resetcaveconfirm})
	end

	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.ENTERCAVE.TITLE, STRINGS.UI.ENTERCAVE.BODY, options))
end

local Open = nil


local function OnWork(inst, worker, workleft)
	local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot(pt)
		Open(inst)
	end
end


Open = function(inst)

	inst.startspawningfn = function()	
		inst.components.childspawner:StopRegen()	
		inst.components.childspawner:StartSpawning()
	end

	inst.stopspawningfn = function()
		inst.components.childspawner:StartRegen()
		inst.components.childspawner:StopSpawning()
		ReturnChildren(inst)
	end
	inst.components.childspawner:StopSpawning()
	inst:ListenForEvent("dusktime", inst.startspawningfn, GetWorld())
	inst:ListenForEvent("daytime", inst.stopspawningfn, GetWorld())

	if IsGamePurchased() then
		inst:AddComponent("activatable")
	    inst.components.activatable.OnActivate = OnActivate
	    inst.components.activatable.inactive = true
	    inst.components.activatable.getverb = GetVerb
		inst.components.activatable.quickaction = true
	end

    inst.AnimState:PlayAnimation("idle_open", true)
    inst:RemoveComponent("workable")
    
    inst.open = true

    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_OPEN
	inst:RemoveComponent("lootdropper")

	inst.MiniMapEntity:SetIcon("cave_open.png")

end      


local function Close(inst)

	if inst.open then
		inst:RemoveEventCallback("daytime", inst.stopspawningfn)
		inst:RemoveEventCallback("dusktime", inst.startspawningfn)
	end
	inst:RemoveComponent("activatable")
    inst.AnimState:PlayAnimation("idle_closed", true)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(OnWork)
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rocks", "rocks", "flint", "flint", "flint"})


    inst.name = STRINGS.NAMES.CAVE_ENTRANCE_CLOSED
    inst.open = false
end      


local function onsave(inst, data)
	data.cavenum = inst.cavenum
	data.open = inst.open
end           

local function onload(inst, data)
	inst.cavenum = data and data.cavenum 

	if data and data.open then
		Open(inst)
	end
end     

local function GetStatus(inst)
	if inst.open then return "OPEN" end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("cave_closed.png")
    anim:SetBank("cave_entrance")
    anim:SetBuild("cave_entrance")

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(.1)
	inst.components.childspawner:SetMaxChildren(6)
	inst.components.childspawner.childname = "bat"

    Close(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload
    return inst
end

return Prefab( "common/cave_entrance", fn, assets, prefabs) 
