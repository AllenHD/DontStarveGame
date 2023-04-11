SaveIndex = Class(function(self)
	self.data =
	{
		slots=
		{
		}
	}
	for k = 1, 4 do

		local filename = "latest_" .. tostring(k)

		if BRANCH ~= "release" then
			filename = filename .. "_" .. BRANCH
		end

		self.data.slots[k] = 
		{
			current_mode = nil,
			modes = {survival= {file = filename}}
		}
	end
	self.current_slot = 1
end)

function SaveIndex:GetSaveGameName(type, slot)

	local savename = nil

	if type == "cave" then
		local cavenum = self:GetCurrentCaveNum(slot)
		local levelnum = self:GetCurrentCaveLevel(slot, cavenum)
		savename = type .. "_" .. tostring(cavenum) .. "_" .. tostring(levelnum) .. "_" .. tostring(slot)
	else
		savename = type.."_"..tostring(slot)
	end

	
	if BRANCH ~= "release" then
		savename = savename .. "_" .. BRANCH
	end
	return savename
end

function SaveIndex:GetSaveIndexName()
	local name = "saveindex" 
	if BRANCH ~= "release" then
		name = name .. "_"..BRANCH
	end
	return name
end

function SaveIndex:Save(callback)
	local data = DataDumper(self.data, nil, false)
    local insz, outsz = TheSim:SetPersistentString(self:GetSaveIndexName(), data, ENCODE_SAVES, callback)
end

function SaveIndex:Load(callback)

    local filename = self:GetSaveIndexName()
    TheSim:GetPersistentString(filename,
        function(str) 
			local success, savedata = RunInSandbox(str)
			if success and string.len(str) > 0 then
				self.data = savedata
				print ("loaded "..filename)
			else
				print ("Could not load "..filename)
			end

			--callback()
			self:VerifyFiles(callback)
        end)    
end



--this also does recovery of pre-existing save files (sort of)
function SaveIndex:VerifyFiles(completion_callback)

	local pending_slots = {}
	for k,v in ipairs(self.data.slots) do
		pending_slots[k] = true
	end
	
	for k,v in ipairs(self.data.slots) do
		local dirty = false
		local files = {}
		if v.current_mode == "empty" then
			v.current_mode = nil
		end
		if v.modes then
			v.modes.empty = nil
			for k, v in pairs(v.modes) do
				table.insert(files, v.file)
			end
		end
		if not v.save_id then
			v.save_id = self:GenerateSaveID(k)
		end

		CheckFiles(function(status) 

			if v.modes then
				for kk,vv in pairs (v.modes) do
					if vv.file and not status[vv.file] then
						vv.file = nil
					end
				end

			 	if v.current_mode == nil then
			 		if v.modes.survival and v.modes.survival.file then
			 			v.current_mode = "survival"
			 		end
			 	end
			 end

		 	pending_slots[k] = nil

		 	if not next(pending_slots) then
		 		self:Save(completion_callback)
		 	end

		 end, files)
	end
end

function SaveIndex:GetModeData(slot, mode)
	if slot and mode and self.data.slots[slot] then
		if not self.data.slots[slot].modes then
			self.data.slots[slot].modes = {}
		end
		if not self.data.slots[slot].modes[mode] then
			self.data.slots[slot].modes[mode] = {}
		end
		return self.data.slots[slot].modes[mode]
	end

	return {}
end

function SaveIndex:GetSaveData(slot, mode, cb)
	self.current_slot = slot
	
	TheSim:GetPersistentString(self:GetModeData(slot, mode).file, function(str)
		local success, savedata = RunInSandbox(str)
		
		--[[
		if not success then
			local file = io.open("bin/badfile.lua", "w")
			if file then
				str = string.gsub(str, "},", "},\n")
				file:write(str)
				
				file:close()
			end
		end--]]

		assert(success, "Corrupt Save file")


		cb(savedata)
	end)
end

function SaveIndex:GetPlayerData(slot, mode)
	local slot = slot or self.current_slot
	return self:GetModeData(slot, mode or self.data.slots[slot].current_mode).playerdata
end

function SaveIndex:DeleteSlot(slot, cb)
	local function onerased()
		self.data.slots[slot] = { current_mode = nil, modes = {}}
		self:Save(cb)
	end

	local files = {}
	for k,v in pairs(self.data.slots[slot].modes) do
		table.insert(files, v.file)
		if v.files then
			for kk, vv in pairs(v.files) do
				table.insert(files, vv)
			end
		end

	end

	EraseFiles(onerased, files)
end


function SaveIndex:ResetCave(cavenum, cb)
	
	local slot = self.current_slot

	if slot and cavenum and self.data.slots[slot] and self.data.slots[slot].modes.cave then
		
		local del_files = {}
		for k,v in pairs(self.data.slots[slot].modes.cave.files) do
			
			local cave_num = string.match(v, "cave_(%d+)_")
			if cave_num and tonumber(cave_num) == cavenum then
				table.insert(del_files, v)
			end
		end
		
		EraseFiles(cb, del_files)
	else
		if cb then
			cb()
		end
	end

end


function SaveIndex:EraseCaves(cb)
	local function onerased()
		self.data.slots[self.current_slot].modes.cave = {}
		self:Save(cb)
	end

	local files = {}
	
	if self.data.slots[self.current_slot] and self.data.slots[self.current_slot].modes and self.data.slots[self.current_slot].modes.cave then
		if self.data.slots[self.current_slot].modes.cave.file then
			table.insert(files, self.data.slots[self.current_slot].modes.cave.file)
		end
		if self.data.slots[self.current_slot].modes.cave.files then
			for kk, vv in pairs(self.data.slots[self.current_slot].modes.cave.files) do
				table.insert(files, vv)
			end
		end
	end
	EraseFiles(onerased, files)
end



function SaveIndex:EraseCurrent(cb)
	
	local current_mode = self.data.slots[self.current_slot].current_mode

	local function docaves()
		if current_mode == "survival" then
			self:EraseCaves(cb)
		else
			cb()
		end
	end

	local filename = ""
	local function onerased()	
		EraseFiles(docaves, {filename})
	end
	
	local data = self:GetModeData(self.current_slot, current_mode)
	filename = data.file
	data.file = nil
	data.playerdata = nil
	data.day = nil
	data.world = nil
	self:Save(onerased)

end

function SaveIndex:SaveCurrent(onsavedcb)
	
	local ground = GetWorld()
	assert(ground, "missing world?")
	local level_number = ground.topology.level_number or 1
	local day_number = GetClock().numcycles + 1

	local function onsavedgame()
		self:Save(onsavedcb)
	end

	local current_mode = self.data.slots[self.current_slot].current_mode
	local data = self:GetModeData(self.current_slot, current_mode)

	self.data.slots[self.current_slot].character = GetPlayer().prefab
	data.day = day_number
	data.playerdata = nil

	data.file = self:GetSaveGameName(current_mode, self.current_slot)
	SaveGame(self:GetSaveGameName(current_mode, self.current_slot), onsavedgame)
end

function SaveIndex:SetSlotCharacter(saveslot, character, cb)
	self.data.slots[saveslot].character = character
	self:Save(cb)
end

function SaveIndex:SetCurrentIndex(saveslot)
	self.current_slot = saveslot
end

function SaveIndex:GetCurrentSaveSlot()
	return self.current_slot
end


--called upon relaunch when a new level needs to be loaded
function SaveIndex:OnGenerateNewWorld(saveslot, savedata, cb)
	--local playerdata = nil
	self.current_slot = saveslot
	local filename = self:GetSaveGameName(self.data.slots[self.current_slot].current_mode, self.current_slot)
	
	local function onindexsaved()
		cb()
		--cb(playerdata)
	end		

	local function onsavedatasaved()
		self.data.slots[self.current_slot].continue_pending = false
		local current_mode = self.data.slots[self.current_slot].current_mode
		local data = self:GetModeData(self.current_slot, current_mode)
		data.file = filename
		data.day = 1
		
		--playerdata = data.playerdata
		--data.playerdata = nil

		self:Save(onindexsaved)
	end

	local insz, outsz = TheSim:SetPersistentString(filename, savedata, ENCODE_SAVES, onsavedatasaved)	
end


--call after you have worldgen data to initialize a new survival save slot
function SaveIndex:StartSurvivalMode(saveslot, character, customoptions, onsavedcb)
	self.current_slot = saveslot
--	local data = self:GetModeData(saveslot, "survival")
	self.data.slots[self.current_slot].character = character
	self.data.slots[self.current_slot].current_mode = "survival"
	self.data.slots[self.current_slot].save_id = self:GenerateSaveID(self.current_slot)

	self.data.slots[self.current_slot].modes = 
	{
		survival = {
			file = self:GetSaveGameName("survival", self.current_slot),
			day = 1,
			world = 1,
			options = customoptions
		},
	}
 	
 	self:Save(onsavedcb)
end

function SaveIndex:GenerateSaveID(slot)
	local now = os.time()
	return TheSim:GetUserID() .."-".. tostring(now) .."-".. tostring(slot)
end

function SaveIndex:GetSaveID(slot)
	slot = slot or self.current_slot
	return self.data.slots[slot].save_id
end

function SaveIndex:OnFailCave(onsavedcb)
	self.data.slots[self.current_slot].modes.cave.playerdata = nil
	self.data.slots[self.current_slot].current_mode = "survival"
	local playerdata = {}
    local player = GetPlayer()
    if player then
    	--remember our unlocked recipes
        playerdata.builder = player:GetSaveRecord().data.builder
        
        --set our meters to the standard resurrection amounts
        playerdata.health = {health = TUNING.RESURRECT_HEALTH}
		playerdata.hunger = {hunger = player.components.hunger.max*.66}
		playerdata.sanity = {current = player.components.sanity.max*.5}
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
		
   	end 

	if self.data.slots[self.current_slot].modes.survival then
		self.data.slots[self.current_slot].modes.survival.playerdata = playerdata
	end
	self:Save(onsavedcb)
end

function SaveIndex:LeaveCave(onsavedcb)
	local playerdata = {}
    local player = GetPlayer()
    if player then
        playerdata = player:GetSaveRecord().data
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
        
   	end 
	self.data.slots[self.current_slot].modes.cave.playerdata = nil
	self.data.slots[self.current_slot].current_mode = "survival"
	
	if self.data.slots[self.current_slot].modes.survival then
		self.data.slots[self.current_slot].modes.survival.playerdata = playerdata
	end
	self:Save(onsavedcb)
end


function SaveIndex:EnterCave(onsavedcb, saveslot, cavenum, level)
	self.current_slot = saveslot or self.current_slot

	--get the current player, and maintain his player data
 	local playerdata = {}
    local player = GetPlayer()
    if player then
        playerdata = player:GetSaveRecord().data
        playerdata.leader = nil
        playerdata.sanitymonsterspawner = nil
   	end  

	level = level or 1
	cavenum = cavenum or 1

	self.data.slots[self.current_slot].current_mode = "cave"
	
	if not self.data.slots[self.current_slot].modes.cave then
		self.data.slots[self.current_slot].modes.cave = {}
	end

	self.data.slots[self.current_slot].modes.cave.files = self.data.slots[self.current_slot].modes.cave.files or {}
	self.data.slots[self.current_slot].modes.cave.current_level = self.data.slots[self.current_slot].modes.cave.current_level or {}
	self.data.slots[self.current_slot].modes.cave.world = level or 1

	self.data.slots[self.current_slot].modes.cave.current_level[cavenum] = level
	self.data.slots[self.current_slot].modes.cave.current_cave = cavenum
	
	local savename = self:GetSaveGameName("cave", self.current_slot)
	self.data.slots[self.current_slot].modes.cave.playerdata = playerdata
	
	local found = false
	for k,v in pairs(self.data.slots[self.current_slot].modes.cave.files) do
		if v == savename then
			found = true
		end
	end

	if not found then 
		table.insert(self.data.slots[self.current_slot].modes.cave.files, savename)
	end
	
	self.data.slots[self.current_slot].modes.cave.file = savename

 	self:Save(onsavedcb)
end

function SaveIndex:OnFailAdventure(cb)
	local filename = self.data.slots[self.current_slot].modes.adventure.file

	local function onsavedindex()
		EraseFiles(cb, {filename})
	end
	self.data.slots[self.current_slot].current_mode = "survival"
	self.data.slots[self.current_slot].modes.adventure = {}
	self:Save(onsavedindex)
end

function SaveIndex:FakeAdventure(cb, slot, start_world)
	self.data.slots[slot].current_mode = "adventure"
	self.data.slots[slot].modes.adventure = {world = start_world, playlist = {1,2,3,4,5,6}}
 	self:Save(cb)
end

function SaveIndex:StartAdventure(cb)

	local function ongamesaved()
		local playlist = self.BuildAdventurePlaylist()
		self.data.slots[self.current_slot].current_mode = "adventure"
		self.data.slots[self.current_slot].modes.adventure = {world = 1, playlist = playlist}
	 	self:Save(cb)
	end

	self:SaveCurrent(ongamesaved)

end

function SaveIndex:BuildAdventurePlaylist()
	require("map/levels")

	local playlist = {}

	local remaining_keys = shuffledKeys(levels.story_levels)
	for i=1,levels.CAMPAIGN_LENGTH+1 do -- the end level is at position length+1
		for k_idx,k in ipairs(remaining_keys) do
			local level_candidate = levels.story_levels[k]
			if level_candidate.min_playlist_position <= i and level_candidate.max_playlist_position >= i then
				table.insert(playlist, k)
				table.remove(remaining_keys, k_idx)
				break
			end
		end
	end

	assert(#playlist == levels.CAMPAIGN_LENGTH+1)

	--debug
	print("Chosen levels:")
	for _,k in ipairs(playlist) do
		print("",levels.story_levels[k].name)
	end

	return playlist
end

--call when you have finished a survival or adventure level to increment the world number and save off the continue information
function SaveIndex:CompleteLevel(cb)
	local adventuremode = self.data.slots[self.current_slot].current_mode == "adventure"

    local playerdata = {}
    local player = GetPlayer()
    if player then
    	player:OnProgress()

		-- bottom out the player's stats so they don't start the next level and die
		local minhealth = 0.2
		if player.components.health:GetPercent() < minhealth then
			player.components.health:SetPercent(minhealth)
		end
		local minsanity = 0.3
		if  player.components.sanity:GetPercent() < minsanity then
			player.components.sanity:SetPercent(minsanity)
		end
		local minhunger = 0.4
		if  player.components.hunger:GetPercent() < minhunger then
			player.components.hunger:SetPercent(minhunger)
		end


        playerdata = player:GetSaveRecord().data
   	 end   

   	local function onerased()
   		if adventuremode then
   			self:Save(cb)
   		else
   			self:EraseCaves(cb)
   		end
   		--self:Save(cb)
   	end

	self.data.slots[self.current_slot].continue_pending = true

	local current_mode = self.data.slots[self.current_slot].current_mode
	local data = self:GetModeData(self.current_slot, current_mode)

	data.day = 1
	data.world = data.world and (data.world + 1) or 2
 	data.playerdata = playerdata
	local file = data.file 
	data.file = nil
	EraseFiles( onerased, { file } )		
end

function SaveIndex:GetSlotDay(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.day or 1
end

-- The WORLD is the "depth" the player has traversed through the teleporters. 1, 2, 3, 4...
-- Contrast with the LEVEL, below.
function SaveIndex:GetSlotWorld(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.world or 1
end

-- The LEVEL is the index from levels.lua to load. This gets shuffled via the playlist.
function SaveIndex:GetSlotLevelIndexFromPlaylist(slot)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	local world = data.world or 1
	if data.playlist and world <= #data.playlist then
		local level = data.playlist[world]
		return level
	else
		return world
	end
end

function SaveIndex:GetSlotCharacter(slot)
	local character = self.data.slots[slot or self.current_slot].character
	-- In case a file was saved with a mod character that has become disabled, fall back to wilson
	if not table.contains(CHARACTERLIST, character) and not table.contains(MODCHARACTERLIST, character) then
		character = "wilson"
	end
	return character
end

function SaveIndex:HasWorld(slot, mode)

	slot = slot or self.current_slot
	local current_mode = mode or self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.file ~= nil
end

function SaveIndex:GetSlotGenOptions(slot, mode)
	slot = slot or self.current_slot
	local current_mode = self.data.slots[slot].current_mode
	local data = self:GetModeData(slot, current_mode)
	return data.options
end

function SaveIndex:IsContinuePending(slot)
	return self.data.slots[slot or self.current_slot].continue_pending
end

function SaveIndex:GetCurrentMode(slot)
	return self.data.slots[slot or self.current_slot].current_mode
end

function SaveIndex:GetCurrentCaveLevel(slot, cavenum)
	slot = slot or self.current_slot
	cavenum = cavenum or self:GetModeData(slot, "cave").current_cave or cavenum or 1
	local cave_data = self:GetModeData(slot, "cave")
	if cave_data.current_level and cave_data.current_level[cavenum] then
		return cave_data.current_level[cavenum]
	end
	return 1
end

function SaveIndex:GetCurrentCaveNum(slot)
	slot = slot or self.current_slot
	return self:GetModeData(slot, "cave").current_cave or 1
end

function SaveIndex:GetNumCaves(slot)
	slot = slot or self.current_slot
	return self:GetModeData(slot, "cave").num_caves or 0
end


function SaveIndex:AddCave(slot, cb)
	slot = slot or self.current_slot
	
	self:GetModeData(slot, "cave").num_caves = self:GetModeData(slot, "cave").num_caves and self:GetModeData(slot, "cave").num_caves + 1 or 1
	self:Save(cb)
end

