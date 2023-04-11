local function PickLootItems(number, loot)
	local refinedloot = {}

	for i = 1, number do
		local num = math.random(#loot)
		table.insert(refinedloot, loot[num])
		table.remove(loot, num)
	end

	return refinedloot
end


local function AddChestItems(chest, loot, num)
	local numloot = num or chest.components.container.numslots
	if #loot >  numloot then
		loot = PickLootItems(numloot, loot)
	end

	for k, itemtype in ipairs(loot) do
		local count = itemtype.count or 1
		for i = 1, count do
			local chance = itemtype.chance
			local spawn = true
			if chance then
				spawn = math.random() < chance
			end
			if spawn then
				local item = SpawnPrefab(itemtype.item or itemtype)
				if item ~= nil then
					if itemtype.initfn then
						itemtype.initfn(item)
					end
					chest.components.container:GiveItem( item )
				else
					print("Cant spawn", itemtype.item or itemtype)
				end
			end
		end
	end
end

local function InitializeChestTrap(inst, scenariorunner, openfn)
	inst.scene_triggerfn = function()  
		chestfunctions.OnOpenChestTrap(inst,  openfn)
		scenariorunner:ClearScenario()
	end
	inst:ListenForEvent("onopen", inst.scene_triggerfn)
	inst:ListenForEvent("worked", inst.scene_triggerfn)

end

local function OnOpenChestTrap(inst, openfn) 
	local chancetotrigger = math.random()
	if math.random() > chancetotrigger then
		local talkabouttrap = function(inst, txt)
			inst.components.talker:Say(txt)
		end
		local player = GetPlayer()
		--random chance
		local r = math.random()
		--if r < 0.5 then
		if true then
			openfn(inst)
			--get the player, and get him to say oops
			player:DoTaskInTime(1, talkabouttrap, GetString(player.prefab, "ANNOUNCE_TRAP_WENT_OFF"))
		else
			player:DoTaskInTime(1, talkabouttrap, GetString(player.prefab, "ANNOUNCE_NO_TRAP"))
		end	
	end
end

local function OnDestroy(inst)
	if inst.scene_triggerfn then
		inst:RemoveEventCallback("onopen", inst.scene_triggerfn)
		inst:RemoveEventCallback("worked", inst.scene_triggerfn)
		inst.scene_triggerfn = nil
	end
end

return
{
	OnOpenChestTrap = OnOpenChestTrap,
	AddChestItems = AddChestItems,
	OnDestroy = OnDestroy,
	InitializeChestTrap = InitializeChestTrap
}