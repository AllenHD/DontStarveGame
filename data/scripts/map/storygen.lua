require("map/network")
require("map/lockandkey")
require("map/stack")
require("map/terrain")
local MapTags = require("map/maptags")

function print_lockandkey_ex(...)
	--print(...)
end
function print_lockandkey(...)
	--print(...)
end

--[[ 

Example story for DS

Goals: 
	Kill ALL the Spiders (The pig village is in trouble, can you defend it and remove the threat?)
	
	1. To get to the pig village you must first pass through a mountain pass
		LOCK: 	Bolder blocks your path
		KEY:		You must build a pickaxe 
	
	2. You must gather enough meat for the pigs so that they have time to help you with the spiders
		LOCK: 	Pig friendship (Pig village)
		KEY:		Meat

Requirements:
	1. 	LOCK: 	Narrow area that can be blocked with boulders
		KEY:		Rocks on the ground, Twigs/grass, time to dig through the boulders
	2.	LOCK: 	Pig village with pigs and fireplace
		KEY:		Sources of meat and ways to get it; Carrots & Rabbits, wandering spiders
	
So working backwards: (create a random number of empty nodes between each)

Area 0
	1. Create evil spider dens
	2. Create pig village far enough away from spider dens, but close enough to annoy them
	3. Create Meat source close enough to pig village (this includes wood/etc to stay safe at night) it probably wants to stay away from spiders
	4. Lock all this behind LOCK 1
Area 1
	1. Add rock source
	2. Add twigs/grass source
	3. Add Starting position
--]]

Story = Class(function(self, id, tasks, terrain, gen_params)
	self.id = id
	self.loop_blanks = 1
	self.gen_params = gen_params
	self.impassible_value = gen_params.impassible_value or GROUND.IMPASSABLE

	self.tasks = {}
	for k,task in pairs(tasks) do
		self.tasks[task.id] = task
	end
	
	self.TERRAIN = {}
	self.terrain = terrain
	
	self.rootNode = Graph(id.."_root", {})
	self.startNode = nil

	self.map_tags = MapTags()
	
	self:GenerateNodesFromTasks()

	self:AddBGNodes(2)

	self:InsertAdditionalSetPieces()
	
	self:ProcessExtraTags()
end)

function Story:PlaceTeleportatoParts()
	local RemoveExitTag = function(node)
		local newtags = {}
		for i,tag in ipairs(node.data.tags) do
			if tag ~= "ExitPiece" then
				table.insert(newtags, tag)
			end
		end
		node.data.tags = newtags
	end

	local IsNodeAnExit = function(node)
		if not node.data.tags then
			return false
		end
		for i,tag in ipairs(node.data.tags) do
			if tag == "ExitPiece" then
				return true
			end
		end
		return false
	end

	local AddPartToTask = function(part, task)
		local nodeNames = shuffledKeys(task.nodes)
		for i,name in ipairs(nodeNames) do
			if IsNodeAnExit(task.nodes[name]) then
				local extra = task.nodes[name].data.terrain_contents_extra
				if not extra.static_layouts then
					extra.static_layouts = {}
				end
				table.insert(extra.static_layouts, part)
				RemoveExitTag(task.nodes[name])
				return true
			end
		end
		return false
	end

	local InsertPartnumIntoATask = function(partnum, partSpread, part, tasks)
		for id,task in pairs(tasks) do
			if task.story_depth == math.ceil(partnum*partSpread) then
				local success = AddPartToTask(part, task)
				-- Not sure why we need this, was causeing crash
				--assert( success or task.id == "TEST_TASK"or task.id == "MaxHome", "Could not add an exit part to task "..task.id)
				return success
			end
		end
		return false
	end

	local parts = {"TeleportatoRingLayout",  "TeleportatoBoxLayout", "TeleportatoCrankLayout",  "TeleportatoPotatoLayout"}
	if self.gen_params.level_type ~= "adventure" then
		table.insert(parts, "AdventurePortalLayout")
		table.insert(parts, "TeleportatoBaseLayout")
	elseif self.gen_params.level_type == "adventure" then
		table.insert(parts, "TeleportatoBaseAdventureLayout")
	end
	local maxdepth = -1
	for id,task in pairs(self.rootNode:GetChildren()) do
		if task.story_depth > maxdepth then
			maxdepth = task.story_depth
		end
	end
	local partSpread = maxdepth/#parts

	for partnum = 1,#parts do
		InsertPartnumIntoATask(partnum, partSpread, parts[partnum], self.rootNode:GetChildren())
	end
end

function Story:ProcessExtraTags()
	self:PlaceTeleportatoParts()
end


function Story:InsertAdditionalSetPieces()

	local tasks = self.rootNode:GetChildren()
	for id, task in pairs(tasks) do
		if task.set_pieces ~= nil and #task.set_pieces >0 then
			for i,setpiece_data  in ipairs(task.set_pieces) do


				local is_entrance = function(room)
					-- return true if the room is an entrance
					return room.data.entrance ~= nil and room.data.entrance == true
				end
				local is_background_ok = function(room)
					-- return true if the piece is not backround restricted, or if it is but we are on a background
					return setpiece_data.restrict_to ~= "background" or room.data.type == "background"
				end

				local choicekeys = shuffledKeys(task.nodes)
				local choice = nil
				for i, choicekey in ipairs(choicekeys) do
					if not is_entrance(task.nodes[choicekey]) and is_background_ok(task.nodes[choicekey]) then
						choice = choicekey
						break
					end
				end

				if choice == nil then
					print("Warning! Couldn't find a spot in "..task.id.." for "..setpiece_data.name)
					break
				end

				--print("Placing "..setpiece_data.name.." in "..task.id..":"..task.nodes[choice].id)

				if task.nodes[choice].data.terrain_contents.countstaticlayouts == nil then
					task.nodes[choice].data.terrain_contents.countstaticlayouts = {}
				end
				--print ("Set peice", name, choice, room_choices._et[choice].contents, room_choices._et[choice].contents.countstaticlayouts[name])
				task.nodes[choice].data.terrain_contents.countstaticlayouts[setpiece_data.name] = 1
			end 
			
		end
	end
end

function Story:LinkNodesByKeys(startParentNode, unusedTasks)
	print_lockandkey_ex("\n\n### START PARENT NODE:",startParentNode.id)
	local lastNode = startParentNode
	local availableKeys = {}
	for i,v in ipairs(self.tasks[startParentNode.id].keys_given) do
		availableKeys[v] = {}
		table.insert(availableKeys[v], startParentNode)
	end
	local usedTasks = {}

	startParentNode.story_depth = 0
	local story_depth = 1
	local currentNode = nil
	
	while GetTableSize(unusedTasks) > 0 do
		local effectiveLastNode = lastNode

		print_lockandkey_ex("\n\n### About to insert a node. Last node:", lastNode.id)

		print_lockandkey_ex("\tHave Keys:")
		for key, keyNodes in pairs(availableKeys) do
			print_lockandkey_ex("\t\t",KEYS_ARRAY[key], GetTableSize(keyNodes))
		end

		for taskid, node in pairs(unusedTasks) do

			print_lockandkey_ex("  TASK: "..taskid)
			print_lockandkey_ex("\t Locks:")

			local locks = {}
			for i,v in ipairs(self.tasks[taskid].locks) do
				local lock = {keys=LOCKS_KEYS[v], unlocked=false}
				locks[v] = lock
				print_lockandkey_ex("\t\tLock:",LOCKS_ARRAY[v],tabletoliststring(lock.keys, function(x) return KEYS_ARRAY[x] end))
			end


			local unlockingNodes = {}

			for lock,lockData in pairs(locks) do						-- For each lock:
				print_lockandkey_ex("\tUnlocking",LOCKS_ARRAY[lock])
				for key, keyNodes in pairs(availableKeys) do			-- Do we have any key for
					for reqKeyIdx,reqKey in ipairs(lockData.keys) do	   -- this lock?
						if reqKey == key then							-- If yes, get the nodes with
																		   -- that key so that we
							for i,node in ipairs(keyNodes) do			   -- can potentially attach
								unlockingNodes[node.id] = node			   -- to one.
							end
							lockData.unlocked = true					-- Also unlock the lock
							print_lockandkey_ex("\t\t\tUnlocked!", KEYS_ARRAY[key])
						end
					end
				end
			end

			local unlocked = true
			for lock,lockData in pairs(locks) do
				print_lockandkey_ex("\tDid we unlock ", LOCKS_ARRAY[lock])
				if lockData.unlocked == false then
					print_lockandkey_ex("\t\tno.")
					unlocked = false
					break
				end
			end

			if unlocked then
				-- this task is presently unlockable!
				currentNode = node
				print_lockandkey_ex ("StartParentNode",startParentNode.id,"currentNode",currentNode.id)

				local lowest = {i=999,node=nil}
				local highest = {i=-1,node=nil}
				for id,node in pairs(unlockingNodes) do
					if node.story_depth >= highest.i then
						highest.i = node.story_depth
						highest.node = node
					end
					if node.story_depth < lowest.i then
						lowest.i = node.story_depth
						lowest.node = node
					end
				end

				if self.gen_params.branching == nil or self.gen_params.branching == "default" then
					effectiveLastNode = GetRandomItem(unlockingNodes)
					print_lockandkey("\tAttaching "..currentNode.id.." to random key", effectiveLastNode.id)
				elseif self.gen_params.branching == "most" then
					effectiveLastNode = lowest.node
					print_lockandkey("\tAttaching "..currentNode.id.." to lowest key", effectiveLastNode.id)
				elseif self.gen_params.branching == "least" then
					effectiveLastNode = highest.node
					print_lockandkey("\tAttaching "..currentNode.id.." to highest key", effectiveLastNode.id)
				elseif self.gen_params.branching == "never" then
					effectiveLastNode = lastNode
					print_lockandkey("\tAttaching "..currentNode.id.." to end of chain", effectiveLastNode.id)
				end

				break
			end

		end

		if currentNode == nil then
			currentNode = self:GetRandomNodeFromTasks(unusedTasks)
			print_lockandkey("\t\tAttaching random node "..currentNode.id.." to last node", effectiveLastNode.id)
		end

		currentNode.story_depth = story_depth
		story_depth = story_depth + 1

		local lastNodeExit = effectiveLastNode:GetRandomNode()
		local currentNodeEntrance = currentNode:GetRandomNode()
		if currentNode.entrancenode then
			currentNodeEntrance = currentNode.entrancenode
		end

		assert(lastNodeExit)
		assert(currentNodeEntrance)

		if self.gen_params.island_percent ~= nil and self.gen_params.island_percent >= math.random() and currentNodeEntrance.data.entrance == false then
			self:SeperateStoryByBlanks(lastNodeExit, currentNodeEntrance )
		else
			self.rootNode:LockGraph(effectiveLastNode.id..'->'..currentNode.id, lastNodeExit, currentNodeEntrance, {type="none", key=self.tasks[currentNode.id].locks, node=nil})
		end		

		print_lockandkey_ex("\t\tAdding keys to keyring:")
		for i,v in ipairs(self.tasks[currentNode.id].keys_given) do
			if availableKeys[v] == nil then
				availableKeys[v] = {}
			end
			table.insert(availableKeys[v], currentNode)
			print_lockandkey_ex("\t\t",KEYS_ARRAY[v])
		end

		unusedTasks[currentNode.id] = nil
		usedTasks[currentNode.id] = currentNode
		lastNode = currentNode
		currentNode = nil
	end

	return lastNode:GetRandomNode()
end

function Story:GetRandomNodeFromTasks(taskSet)
	local sz = GetTableSize(taskSet)
	local task = nil
	if sz > 0 then
		local choice = math.random(sz) -1

		
		for taskid,_ in pairs(taskSet) do -- special order
			task = taskid
			if choice<= 0 then
				break
			end
			choice = choice -1
		end
	end
	--print("G2 task ", task)
	return self.TERRAIN[task]
end

function Story:GenerateNodesFromTasks()	
	--print("Story:GenerateNodesFromTasks creating stories")

	local unusedTasks = {}
	
	-- Generate all the TERRAIN
	for k,task in pairs(self.tasks) do
		--print("Story:GenerateNodesFromTasks k,task",k,task,  GetTableSize(self.TERRAIN))
		local node = self:GenerateNodesFromTask(task, 1)--0.5)
		self.TERRAIN[task.id] = node
		unusedTasks[task.id] = node
	end
		
	--print("Story:GenerateNodesFromTasks lock terrain")
	
	local startTasks = {}
	for k,task in pairs(self.tasks) do
		if #task.locks == 0 or task.locks[1] == LOCKS.NONE then
			startTasks[task.id] = self.TERRAIN[task.id]
		end
	end
	
	--print("Story:GenerateNodesFromTasks finding start parent node")

	local startParentNode = GetRandomItem(self.TERRAIN)
	if  GetTableSize(startTasks) > 0 then
		startParentNode = GetRandomItem(startTasks)
	end

	unusedTasks[startParentNode.id] = nil
	
    --print("Lock and Key")	

	local finalNode = startParentNode
	--if math.random()>0.8 then
		--print("LinkNodesByLocks")	
		--finalNode = self:LinkNodesByLocks(startParentNode, unusedTasks)
	--else
		print("LinkNodesByKeys")	
		finalNode = self:LinkNodesByKeys(startParentNode, unusedTasks)
	--end	
	--print("Setting start node")	
	

	local randomStartNode = startParentNode:GetRandomNode()
	
	local start_node_data = {id="START"}

	if self.gen_params.start_node ~= nil then
		start_node_data.data = deepcopy(self.terrain.base[self.gen_params.start_node])
		start_node_data.data.terrain_contents = start_node_data.data.contents		
	else
		start_node_data.data = {
								value = GROUND.GRASS,								
								terrain_contents={
									countprefabs = {
										spawnpoint=1,
										sapling=1,
										flint=1,
										berrybush=1, 
										grass=function () return 2 + math.random(2) end
									} 
								}
							 }
	end

	start_node_data.data.type = "START"
	start_node_data.data.colour = {r=0,g=1,b=1,a=.80}
	
	if self.gen_params.start_setpeice ~= nil then
		start_node_data.data.terrain_contents.countstaticlayouts = {}
		start_node_data.data.terrain_contents.countstaticlayouts[self.gen_params.start_setpeice] = 1
		
		if start_node_data.data.terrain_contents.countprefabs ~= nil then
			start_node_data.data.terrain_contents.countprefabs.spawnpoint = nil
		end
	end

	self.startNode = startParentNode:AddNode(start_node_data)
											
	--print("Story:GenerateNodesFromTasks adding start node link", self.startNode.id.." -> "..randomStartNode.id)
	startParentNode:AddEdge({node1id=self.startNode.id, node2id=randomStartNode.id})	

	-- form the map into a loop!
	if self.gen_params.loop_percent ~= nil then
		if math.random() < self.gen_params.loop_percent then
			--print("Adding map loop")
			self:SeperateStoryByBlanks(self.startNode, finalNode )
		end
	else
		if math.random() < 0.5 then
			--print("Adding map loop")
			self:SeperateStoryByBlanks(self.startNode, finalNode )
		end
	end
end

function Story:AddBGNodes(random_count)
	local tasksnodes = self.rootNode:GetChildren(false)
	local bg_idx = 0

	for taskid, task in pairs(tasksnodes) do

		local background_template = deepcopy(self.terrain.base[task.data.background])
		assert(background_template, "Couldn't find room with name "..task.data.background)

		self:RunTaskSubstitution(task, background_template.contents.distributeprefabs)

		for nodeid,node in pairs(task:GetNodes(false)) do

			if not node.data.entrance then

				local count = math.random(0,random_count)
				local prevNode = nil
				for i=1,count do

					local new_room = deepcopy(background_template)

					-- this has to be inside the inner loop so that things like teleportato tags
					-- only get processed for a single node.
					local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)

					local room_id = nodeid..":BG_"..bg_idx
					
					local newNode = task:AddNode({
										id=room_id, 
										data={
												type="background",
												colour = new_room.colour,
												value = new_room.value,
												internal_type = new_room.internal_type,
												tags = extra_tags,
												terrain_contents = new_room.contents,
												terrain_contents_extra = extra_contents,
												terrain_filter = self.terrain.filter,
												entrance = new_room.entrance
											  }										
										})

					task:AddEdge({node1id=newNode.id, node2id=nodeid})
					-- This will probably cause crushng so it is commented out for now
					-- if prevNode then
					-- 	task:AddEdge({node1id=newNode.id, node2id=prevNode.id})
					-- end

					bg_idx = bg_idx + 1
					prevNode = newNode
				end
			end

		end

	end
end

function Story:SeperateStoryByBlanks(startnode, endnode )	
	local blank_node = Graph("LOOP_BLANK"..tostring(self.loop_blanks), {parent=self.rootNode, default_bg=GROUND.IMPASSABLE, colour = {r=0,g=0,b=0,a=1}, background="BGImpassable" })
	WorldSim:AddChild(self.rootNode.id, "LOOP_BLANK"..tostring(self.loop_blanks), GROUND.IMPASSABLE, 0, 0, 0, 1, "blank")
	local blank_subnode = blank_node:AddNode({
											id="LOOP_BLANK_SUB "..tostring(self.loop_blanks), 
											data={
													type="blank",
													tags = {"RoadPoison", "ForceDisconnected"},					 
													colour={r=0.3,g=.8,b=.5,a=.50},
													value = self.impassible_value
												  }										
										})

	self.loop_blanks = self.loop_blanks + 1
	self.rootNode:LockGraph(startnode.id..'->'..blank_subnode.id, 	startnode, 	blank_subnode, {type="none", key=KEYS.NONE, node=nil})
	self.rootNode:LockGraph(endnode.id..'->'..blank_subnode.id, 	endnode, 	blank_subnode, {type="none", key=KEYS.NONE, node=nil})
end

function Story:GetExtrasForRoom(next_room)
	local extra_contents = {}
	local extra_tags = {}
	if next_room.tags ~= nil then
		for i,tag in ipairs(next_room.tags) do
			local type, extra = self.map_tags.Tag[tag](self.map_tags.TagData)
			if type == "STATIC" then
				if extra_contents.static_layouts == nil then
					extra_contents.static_layouts = {}
				end
				table.insert(extra_contents.static_layouts, extra)
			end
			if type == "ITEM" then
				if extra_contents.prefabs == nil then
					extra_contents.prefabs = {}
				end
				table.insert(extra_contents.prefabs, extra)
			end
			if type == "TAG" then
				table.insert(extra_tags, extra)
			end
		end
	end

	return extra_contents, extra_tags
end

function Story:RunTaskSubstitution(task, items )
	if task.substitutes == nil or items == nil then
		return items
	end

	for k,v in pairs(task.substitutes) do 
		if items[k] ~= nil then 
			if v.percent == 1 or v.percent == nil then
				items[v.name] = items[k]
				items[k] = nil
			else
				items[v.name] = items[k] * v.percent
				items[k] = items[k] * (1.0-v.percent)
			end
		end
	end

	return items
end

-- Generate a subgraph containing all the items for this story
function Story:GenerateNodesFromTask(task, crossLinkFactor)
	--print("Story:GenerateNodesFromTask", task.id)
	-- Create stack of rooms
	local room_choices = Stack:Create()

	if task.entrance_room then
		local r = math.random()
		if task.entrance_room_chance == nil or task.entrance_room_chance > r then
			if type(task.entrance_room) == "table" then
				task.entrance_room = GetRandomItem(task.entrance_room)
			end
			--print("\tAdding entrance: ",task.entrance_room,"rolled:",r,"needed:",task.entrance_room_chance)
			local new_room = deepcopy(self.terrain.special[task.entrance_room])
			assert(new_room, "Couldn't find entrance room with name "..task.entrance_room)

			if new_room.contents == nil then
				new_room.contents = {}
			end

			if new_room.contents.fn then					
				new_room.contents.fn(new_room)
			end
			new_room.type = task.entrance_room
			new_room.entrance = true
			room_choices:push(new_room)
		--else
		--	print("\tHad entrance but didn't use it. rolled:",r,"needed:",task.entrance_room_chance)
		end
	end
	
	if task.room_choices ~= nil then
		for room, count in pairs(task.room_choices) do
			--print("Story:GenerateNodesFromTask adding "..count.." of "..room)
			for id = 1, count do
				--print("Story:GenerateNodesFromTask adding "..id)
				--dumptable(TERRAIN[room])
				local new_room = deepcopy(self.terrain.base[room])
				assert(new_room, "Couldn't find room with name "..room)
				if new_room.contents == nil then
					new_room.contents = {}
				end
			
				new_room.type = room
				room_choices:push(new_room)
			end
		end
	end

	if task.room_choices_special then
		for room, count in pairs(task.room_choices_special) do
			--print("Story:GenerateNodesFromTask adding "..count.." of "..room, self.terrain.special[room].contents.fn)
			for id = 1, count do
				local new_room = deepcopy(self.terrain.special[room])

				assert(new_room, "Couldn't find special room with name "..room)
				if new_room.contents == nil then
					new_room.contents = {}
				end			
				
				-- Do any special processing for this room
				if new_room.contents.fn then					
					new_room.contents.fn(new_room)
				end
				new_room.type = room
				room_choices:push(new_room)
			end
		end
	end


	local task_node = Graph(task.id, {parent=self.rootNode, default_bg=task.room_bg, colour = task.colour, background=task.background_room, set_pieces=task.set_pieces})
	task_node.substitutes = task.substitutes
	--print ("Adding Voronoi Child", self.rootNode.id, task.id, task.room_bg, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a )

	WorldSim:AddChild(self.rootNode.id, task.id, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a)
	
	local newNode = nil
	local prevNode = nil
	
	local roomID = 0
	--print("Story:GenerateNodesFromTask adding "..room_choices:getn().." rooms")
	while room_choices:getn() > 0 do
		local next_room = room_choices:pop()
		local room_id = task.id..":"..roomID..":"..next_room.type	-- TODO: add room names for special rooms

		self:RunTaskSubstitution(task, next_room.contents.distributeprefabs)
		
		-- TODO: Move this to 
		local extra_contents, extra_tags = self:GetExtrasForRoom(next_room)
		
		newNode = task_node:AddNode({
										id=room_id, 
										data={
												type= next_room.entrance and "blocker" or next_room.type, 
												colour = next_room.colour,
												value = next_room.value,
												internal_type = next_room.internal_type,
												tags = extra_tags,
												custom_tiles = next_room.custom_tiles,
												custom_objects = next_room.custom_objects,
												terrain_contents = next_room.contents,
												terrain_contents_extra = extra_contents,
												terrain_filter = self.terrain.filter,
												entrance = next_room.entrance
											  }										
									})
		
		if prevNode then
			--dumptable(prevNode)
			--print("Story:GenerateNodesFromTask Adding edge "..newNode.id.." -> "..prevNode.id)
			local edge = task_node:AddEdge({node1id=newNode.id, node2id=prevNode.id})
		end
		
		--dumptable(newNode)
		-- This will make long line of nodes
		prevNode = newNode
		roomID = roomID + 1
	end
	
	if crossLinkFactor then
		--print("Story:GenerateNodesFromTask crosslinking")
		-- do some extra linking.
		task_node:CrosslinkRandom(crossLinkFactor)
	end
	--print("Story:GenerateNodesFromTask done")
	return task_node
end
------------------------------------------------------------------------------------------
---------             TESTING                   --------------------------------------
------------------------------------------------------------------------------------------

function TEST_STORY(tasks, story_gen_params)
	--print("Building TEST STORY", tasks)
	local start_time = GetTimeReal()
	
	local story = Story("GAME", tasks, terrain, story_gen_params)
	    
	SetTimingStat("time", "generate_story", GetTimeReal() - start_time)
	
	--print("\n------------------------------------------------")
	--story.rootNode:Dump()
	--print("\n------------------------------------------------")
	
	return {root=story.rootNode, startNode=story.startNode}
end


