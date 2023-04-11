local CAMPAIGN_LENGTH = 5


Level = Class( function(self, data)
	self.id = data.id or "UNKNOWN_ID"
	self.name = data.name or ""
	self.desc = data.desc or ""
	self.tasks = data.tasks or {}
	self.overrides = data.overrides or {}
	self.substitutes = data.substitutes or {}
	self.override_triggers = data.override_triggers
	self.set_pieces = data.set_pieces or {}
	self.numoptionaltasks = data.numoptionaltasks or 0
	self.nomaxwell = data.nomaxwell or false
	self.override_level_string = data.override_level_string or false
	self.optionaltasks = data.optionaltasks or {}
	self.hideminimap = data.hideminimap or false
	self.teleportaction = data.teleportaction or nil
	self.teleportmaxwell = data.teleportmaxwell or nil
	self.min_playlist_position = data.min_playlist_position or 0
	self.max_playlist_position = data.max_playlist_position or 999
end)


function Level:GetOverridesForTasks(tasklist)
	-- Update the task with whatever overrrides are going
	local resources = require("map/resource_substitution")
	
	-- WE MAKE ONE SELECTION FOR ALL TASKS or ONE PER TASK
	for name, override in pairs(self.substitutes) do

		local substitute = resources.GetSubstitute(name)

		if name ~= substitute then
			print("Substituting [".. substitute.."] for [".. name.."]")
			for task_idx,val in ipairs(tasklist) do
				local chance = 	math.random()
				if chance < override.perstory then 
					if tasklist[task_idx].substitutes == nil then
						tasklist[task_idx].substitutes = {}
					end
					--print(task_idx, "Overriding", name, "with", substitute, "for:", self.name, chance, override.perstory )
					tasklist[task_idx].substitutes[name] = {name = substitute, percent = override.pertask}
				-- else
				-- 	print("NOT overriding ", name, "with", substitute, "for:", self.name, chance, override.perstory)

				end
			end
		end
	end

	return tasklist
end

function Level:GetTasksForLevel(sampletasks)
	--print("Getting tasks for level:", self.name)
	local tasklist = {}
	for i=1,#self.tasks do
		self:EnqueueATask(tasklist, self.tasks[i], sampletasks)
	end

	if self.numoptionaltasks and self.numoptionaltasks > 0 then
		local shuffletasknames = shuffleArray(self.optionaltasks)
		local numtoadd = self.numoptionaltasks
		local i = 1
		while numtoadd > 0 and i <= #self.optionaltasks do
			if type(self.optionaltasks[i]) == "table" then
				for i,taskname in ipairs(self.optionaltasks[i]) do
					self:EnqueueATask(tasklist, taskname, sampletasks)
					numtoadd = numtoadd - 1
				end
			else
				self:EnqueueATask(tasklist, self.optionaltasks[i], sampletasks)
				numtoadd = numtoadd - 1
			end
			i = i + 1
		end
	end

	for name, choicedata in pairs(self.set_pieces) do
		local found = false
		local idx = {}
		for i, task in ipairs(tasklist) do
			idx[task.id] = i
		end

		-- Pick one of the choces and add it to that task
		local choices = choicedata.tasks
		local count = choicedata.count or 1

		assert(choices, "Trying to add set piece '"..name.."' but no choices given.")

		-- Only one layout per task, so we stop when we run out of tasks or 
		while count > 0 and #choices > 0 do
			local idx_choice_offset = math.random(#choices) - 1 -- we'll convert back to 1-index in a moment
			-- To account for the fact that some of the choices might not exist in the level (i.e. option tasks) loop through them.
			for i=1,#choices do
				local idx_choice = ((idx_choice_offset + i)% #choices) + 1 -- convert back to 1-index
				local choice = idx[choices[idx_choice]]
				--print("choice", idx_choice, choice, #choices, choices[idx_choice], tasklist[choice])
				if tasklist[choice] then
					if tasklist[choice].set_pieces == nil then
						tasklist[choice].set_pieces = {}
					end
					table.insert(tasklist[choice].set_pieces, {name=name, restrict_to=choicedata.restrict_to})
					idx[choices[idx_choice]] = nil
					table.remove(choices, choice)
					break
				end
			end
			count = count-1
		end
	end
	
	self:GetOverridesForTasks(tasklist)
	return tasklist
end

function Level:EnqueueATask(tasklist, taskname, sampletasks)
	local task = self:GetTaskByName(taskname, sampletasks)
	if task then
		--print("\tChoosing task:",task.id)
		table.insert(tasklist, deepcopy(task))
	else
		assert(task, "Could not find a task called "..taskname)
	end
end

function Level:GetTaskByName(taskname, sampletasks)
	for j=1,#sampletasks do
		if string.upper(taskname) == string.upper(sampletasks[j].id) then
			return sampletasks[j]
		end
	end
	return nil
end

local test_level = Level({
	name="TEST_LEVEL",
	desc="",
	overrides={
		{"world_size", 	"tiny"},
		{"day", 		"onlyday"}, 
		{"waves", 		"off"},
		{"location",	"cave"},
		{"boons", 			"never"},
		{"poi", 			"never"},
		{"traps", 			"never"},
		{"protected", 		"never"},
		{"start_setpeice", 	"CaveStart"},
		{"start_node",	"BGNoisyFungus"},
	},
	tasks={
			"FungalRabitCityPlain",
	},
	numoptionaltasks = 0,
	optionaltasks = {
			"CaveBase",
			"MushBase",
			"SinkBase",
			"RabbitTown",
	}
})

local cave_levels = {

	Level{
		id="CAVE_LEVEL_1",
		name="CAVE_LEVEL_1",
		overrides={
			{"world_size", 	"tiny"},
			{"day", 		"onlynight"}, 
			{"waves", 		"off"},
			{"location",	"cave"},
			{"boons", 			"never"},
			{"poi", 			"never"},
			{"traps", 			"never"},
			{"protected", 		"never"},
			{"start_setpeice", 	"CaveStart"},
			{"start_node",		"BGSinkholeRoom"},
		},
		tasks={
			"CavesStart",
			"CavesAlternateStart",
			"FungalBatCave",
			"BatCaves",
			"TentacledCave",
			"LargeFungalComplex",
			"SingleBatCaveTask",
			"RabbitsAndFungs",
			"FungalPlain",
			"Cavern",
		},
		numoptionaltasks = 1,
		optionaltasks = {
			"CaveBase",
			"MushBase",
			"SinkBase",
			"RabbitTown",
		}
	},
	Level{
		id="CAVE_LEVEL_2",
		name="CAVE_LEVEL_2",
		overrides={
			{"world_size", 	"tiny"},
			{"day", 		"onlynight"}, 
			{"waves", 		"off"},
			{"location",	"cave"},
			{"boons", 			"never"},
			{"poi", 			"never"},
			{"traps", 			"never"},
			{"protected", 		"never"},
			{"start_setpeice", 	"CaveStart"},
			{"start_node",		"BGSinkholeRoom"},
		},
		tasks={
			"FungalRabitCityPlain",
		},
		numoptionaltasks = 0,
		optionaltasks = {
			"CaveBase",
			"MushBase",
			"SinkBase",
			"RabbitTown",
		}
	},
}

local free_levels ={
	Level({ 
		id="SURVIVAL_DEFAULT",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[1],
		desc=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[1],
		overrides={
				{"start_setpeice", 	"DefaultStart"},		
				{"start_node",		"Clearing"},
		},
		tasks = {
				"Make a pick",
				"Dig that rock",
				"Great Plains",
				"Squeltch",
				"Beeeees!",
				"Speak to the king",
				"Forest hunters",
		},
		numoptionaltasks = 4,
		optionaltasks = {
				"Befriend the pigs",
				"For a nice walk",
				"Kill the spiders",
				"Killer bees!",
				"Make a Beehat",
				"The hunters",
				"Magic meadow",
				"Frogs and bugs",
		},
		set_pieces = {
			["ResurrectionStone"] = { count=2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" } },
			["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
		},
	}),
	Level({
		id="SURVIVAL_DEFAULT_PLUS",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[2],
		desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[2],
		overrides={				
				{"start_setpeice", 	"DefaultPlusStart"},	
				{"start_node",		{"DeepForest", "Forest", "SpiderForest", "Plain", "Rocky", "Marsh"}},
				{"boons", 			"often"},
				
				{"spiders", 		"often"},
				{"berrybush", 		"rare"},
				{"carrot", 			"rare"},
				{"rabbits", 		"rare"},
				
				
		},
		tasks = {
				"Make a pick",
				"Dig that rock",
				"Great Plains",
				"Squeltch",
				"Beeeees!",
				"Speak to the king",
				"Tentacle-Blocked The Deep Forest",
		},
		numoptionaltasks = 4,
		optionaltasks = {
				"Forest hunters",
				"Befriend the pigs",
				"For a nice walk",
				"Kill the spiders",
				"Killer bees!",
				"Make a Beehat",
				"The hunters",
				"Magic meadow",
				"Hounded Greater Plains",
				"Merms ahoy",
				"Frogs and bugs",
		},
		set_pieces = {
				["ResurrectionStone"] = { count=2, tasks={ "Speak to the king", "Forest hunters" } },
				["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
		},
	}),

	Level({
		id="COMPLETE_DARKNESS",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[3],
		desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[3],
		overrides={				
				{"start_setpeice", 	"DarknessStart"},	
				{"start_node",		{"DeepForest", "Forest"}},		
				{"day", 			"onlynight"}, 
		},
		tasks = {
				"Make a pick",
				"Dig that rock",
				"Great Plains",
				"Squeltch",
				"Beeeees!",
				"Speak to the king",
				"Tentacle-Blocked The Deep Forest",
		},
		numoptionaltasks = 4,
		optionaltasks = {
				"Forest hunters",
				"Befriend the pigs",
				"For a nice walk",
				"Kill the spiders",
				"Killer bees!",
				"Make a Beehat",
				"The hunters",
				"Magic meadow",
				"Hounded Greater Plains",
				"Merms ahoy",
				"Frogs and bugs",
		},
		set_pieces = {
				["ResurrectionStone"] = { count=2, tasks={ "Speak to the king", "Forest hunters" } },
				["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
		},
	}),

	-- Level({ 
	-- 	id="SURVIVAL_CAVEPREVIEW",
	-- 	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[3],
	-- 	desc=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[3],
	-- 	overrides={
	-- 			{"start_setpeice", 	"CaveTestStart"},		
	-- 			{"start_node",		"Clearing"},
	-- 	},
	-- 	tasks = {
	-- 			"Make a pick",
	-- 			"Dig that rock",
	-- 			"Great Plains",
	-- 			"Squeltch",
	-- 			"Beeeees!",
	-- 			"Speak to the king",
	-- 			"Forest hunters",
	-- 	},
	-- 	numoptionaltasks = 4,
	-- 	optionaltasks = {
	-- 			"Befriend the pigs",
	-- 			"For a nice walk",
	-- 			"Kill the spiders",
	-- 			"Killer bees!",
	-- 			"Make a Beehat",
	-- 			"The hunters",
	-- 			"Magic meadow",
	-- 			"Frogs and bugs",
	-- 	},
	-- 	set_pieces = {
	-- 		["ResurrectionStone"] = { count=2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" } },
	-- 		["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
	-- 	},
	-- }),
}

local function GetRandomSubstituteList( substitutes, num_choices )	
	local subs = {}
	local list = {}

	for k,v in pairs(substitutes) do 
		list[k] = v.weight
	end

	for i=1,num_choices do
		local choice = weighted_random_choice(list)
		list[choice] = nil
		subs[choice] = substitutes[choice]
	end

	return subs
end

local SUBS_1= {
			["evergreen"] = 		{perstory=0.5, 	pertask=1, 		weight=1},
			["evergreen_short"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["evergreen_normal"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["evergreen_tall"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["sapling"] = 			{perstory=0.6, 	pertask=0.95,	weight=1},
			["beefalo"] = 			{perstory=1, 	pertask=1, 		weight=1},
			["rabbithole"] = 		{perstory=1, 	pertask=1, 		weight=1},
			["rock1"] = 			{perstory=0.3, 	pertask=1, 		weight=1},
			["rock2"] = 			{perstory=0.5, 	pertask=0.8, 	weight=1},
			["grass"] = 			{perstory=0.5, 	pertask=0.9, 	weight=1},
			["flint"] = 			{perstory=0.5, 	pertask=1,		weight=1},
			["spiderden"] =			{perstory=1, 	pertask=1, 		weight=1},
		}

local story_levels = {
	Level({
		id="RAINY", -- A Cold Reception
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[1],
		min_playlist_position=1,
		max_playlist_position=3,
		overrides={
			{"world_size", 		"default"},
			{"day", 			"longdusk"}, 
			{"weather", 		"squall"},		
			{"weather_start", 	"wet"},		
			{"frograin",		"often"},
			
			{"start_setpeice", 	"WinterStartEasy"},	
			{"start_node", 		"Forest"},	

			{"season", 			"autumn"}, 
			{"season_start", 	"summer"},
			
			{"deerclops", 		"never"},
			{"hounds", 			"never"},
			{"mactusk", 		"always"},
			{"leifs",			"always"},
			
			{"trees", 			"often"},
			{"carrot", 			"default"},
			{"berrybush", 		"never"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
				"Make a pick",
				"Easy Blocked Dig that rock",
				"Great Plains",
				"Guarded Speak to the king",
		},
		numoptionaltasks = 4,
		optionaltasks = {
				"Waspy Beeeees!",
				"Guarded Squeltch",
				"Guarded Forest hunters",
				"Befriend the pigs",
				"Guarded For a nice walk",
				"Walled Kill the spiders",
				"Killer bees!",
				"Make a Beehat",
				"Waspy The hunters",
				"Hounded Magic meadow",
				"Wasps and Frogs and bugs",
				"Guarded Walrus Desolate",
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={
														"Easy Blocked Dig that rock",
														"Great Plains",
														"Guarded Speak to the king",
														"Waspy Beeeees!",
														"Guarded Squeltch",
														"Guarded Forest hunters",
														"Befriend the pigs",
														"Guarded For a nice walk",
														"Walled Kill the spiders",
														"Killer bees!",
														"Make a Beehat",
														"Waspy The hunters",
														"Hounded Magic meadow",
														"Wasps and Frogs and bugs",
														"Guarded Walrus Desolate"} },
			["ResurrectionStoneWinter"] = { count=1, tasks={"Make a pick",
														"Easy Blocked Dig that rock",
														"Great Plains",
														"Guarded Speak to the king",
														"Waspy Beeeees!",
														"Guarded Squeltch",
														"Guarded Forest hunters",
														"Befriend the pigs",
														"Guarded For a nice walk",
														"Walled Kill the spiders",
														"Killer bees!",
														"Make a Beehat",
														"Waspy The hunters",
														"Hounded Magic meadow",
														"Wasps and Frogs and bugs",
														"Guarded Walrus Desolate"} },
		},
	}),
	Level({
		id="WINTER",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[2],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day", 			"longdusk"}, 
			
			{"start_setpeice", 	"WinterStartMedium"},		
			{"start_node",		"Clearing"},

			{"loop",			"never"},
			{"branching",		"least"},
			
			{"season", 			"onlywinter"},
			{"season_start", 	"winter"},
			{"weather", 		{"always", "often"}},		
			
			{"deerclops", 		"often"},
			{"hounds", 			"never"},
			{"mactusk", 		"always"},
			
			{{"carrot","berrybush"},{"never","rare"}},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 1),
		tasks = {
			"Resource-rich Tier2",
			"Sanity-Blocked Great Plains",
			"Hounded Greater Plains",
			"Insanity-Blocked Necronomicon",
		},
		numoptionaltasks = 2,
		optionaltasks = {
			"Walrus Desolate",
			"Walled Kill the spiders",
			"The Deep Forest",
			"Forest hunters",
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={ "Hounded Greater Plains", "Walrus Desolate", "Walled Kill the spiders",
																"The Deep Forest", "Forest hunters" }},
			["MacTuskTown"] = { tasks={"Insanity-Blocked Necronomicon", "Hounded Greater Plains", "Sanity-Blocked Great Plains"} },
			["ResurrectionStoneWinter"] = { count=1, tasks={"Resource-rich Tier2",
														"Sanity-Blocked Great Plains",
														"Hounded Greater Plains",
														"Insanity-Blocked Necronomicon", 
														"Walrus Desolate",
														"Walled Kill the spiders",
														"The Deep Forest",
														"Forest hunters"} },
		},
	}),
	-- Weather: start with very short winter, then endless summer.
	Level({
		id="HUB",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[3],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day",			 	"longdusk"}, 
			
			{"start_setpeice", 	"PreSummerStart"},
			{"start_node",		"Clearing"},
					
			{"season", 			"preonlysummer"}, 
			{"season_start", 	"winter"},
			{"spiders",			"often"},

			{"branching",		"default"},
			{"loop",			"never"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
	-- Enemies: Lots of hound mounds and maxwell traps everywhere. Frequent hound invasions.
		tasks = {
			"Resource-Rich",
			"Lots-o-Spiders",
			"Lots-o-Tentacles",
			"Lots-o-Tallbirds",
			"Lots-o-Chessmonsters",
		},
		numoptionaltasks = 4,
		optionaltasks = {
			"The hunters",
			"Trapped Forest hunters",
			"Wasps and Frogs and bugs",
			"Tentacle-Blocked The Deep Forest",
			"Hounded Greater Plains",
			"Merms ahoy",
		},
		set_pieces = {
			["SimpleBase"] = { tasks={"Lots-o-Spiders", "Lots-o-Tentacles", "Lots-o-Tallbirds", "Lots-o-Chessmonsters"}},
			["WesUnlock"] = { restrict_to="background", tasks={ "The hunters", "Trapped Forest hunters", "Wasps and Frogs and bugs", "Tentacle-Blocked The Deep Forest", "Hounded Greater Plains", "Merms ahoy" }},
			["ResurrectionStone"] = { count=1, tasks={"Resource-Rich",
														"Lots-o-Spiders",
														"Lots-o-Tentacles",
														"Lots-o-Tallbirds",
														"Lots-o-Chessmonsters", "The hunters",
														"Trapped Forest hunters",
														"Wasps and Frogs and bugs",
														"Tentacle-Blocked The Deep Forest",
														"Hounded Greater Plains",
														"Merms ahoy"} },
		},
	}),
	Level({
		id="ISLANDHOP",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[4],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			{"islands", 		"always"},	
			{"roads", 			"never"},	
			{"start_node",		"BGGrass"},
			{"start_setpeice", 	"ThisMeansWarStart"},
			{"weather", 		{"rare", "default", "often"}},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
			"IslandHop_Start",
			"IslandHop_Hounds",
			"IslandHop_Forest",
			"IslandHop_Savanna",
			"IslandHop_Rocky",
			"IslandHop_Merm",
		},
		numoptionaltasks = 0,
		optionaltasks = {
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={ "IslandHop1", "IslandHop2", "IslandHop3", "IslandHop4", "IslandHop5", "IslandHop6" } },
		},
	}),	
	Level({
		id="TWOLANDS",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[5],
		override_level_string=true,
		min_playlist_position=3,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day", 			"longday"}, 
			{"season", 			"onlysummer"},
			{"season_start",	"summer"},
			
			{"islands", 		"always"},	
			{"roads", 			"never"},	
				
			{"start_setpeice", 	"BargainStart"},		
			{"start_node",		"Clearing"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
			-- Part 1 - Easy peasy - lots of stuff
			"Land of Plenty",
			
			-- Part 2 - Lets kill them off
			"The other side",	
		},
		override_triggers = {
			["START"] = {	-- Quick (localised) fix for area-aware bug #677
									{"weather", "never"}, 
									{"day", "longday"},
							 	},
			["Land of Plenty"] = {	
									{"weather", "never"}, 
									{"day", "longday"},
							 	},
			["The other side"] = {	
									{"weather", "often"}, 
									{"day", "longdusk"},
							 	},
		},
		set_pieces = {
			["MaxPigShrine"] = {tasks={"Land of Plenty"}},
			["MaxMermShrine"] = {tasks={"The other side"}},
			["ResurrectionStone"] = { count=2, tasks={"Land of Plenty", "The other side" } },
		},
	}),

	Level({
		id="DARKNESS",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[6],
		min_playlist_position=CAMPAIGN_LENGTH,
		max_playlist_position=CAMPAIGN_LENGTH,
		overrides={
			{"branching",		"never"},
			{"day", 			"onlynight"}, 
			{"season_start", 	"summer"},
			{"season", 			"onlysummer"},
			{"weather", 		"often"}, -- always

			{"boons",			"always"},
			
			{"roads", 			"never"},
			--{"carrot", 			"rare"},
			{"berrybush", 		"never"},
			{"spiders", 		"often"},

			{"fireflies",		"always"},
			
			{"start_setpeice", 	"NightmareStart"},--ThisMeansWarStart"},
			{"start_node",		"BGGrass"},

			{"maxwelllight_area",	"always"},
		},
		substitutes = MergeMaps( {["pighouse"] = {perstory=1,weight=1,pertask=1}},
								 GetRandomSubstituteList(SUBS_1, 3) ),
		tasks = {
			"Swamp start",
			"Battlefield",
			"Walled Kill the spiders",
			"Sanity-Blocked Spider Queendom",
		},
		numoptionaltasks = 2,
		optionaltasks = {
			"Killer Bees!",
			"Chessworld",
			"Tentacle-Blocked The Deep Forest",
			"Tentacle-Blocked Spider Swamp",
			"Trapped Forest hunters",
			"Waspy The hunters",
			"Hounded Magic meadow",
		},
		-- override_triggers = {
		-- 	[5] = {	
		-- 		{"season", 		"onlywinter"},
		-- 		{"season_start","winter"}, 
		-- 		{"weather", 	"always"},
		-- 		{"day", 		"onlynight"}, 
		-- 		--{"start_setpeice", 	"PermaWinterNight"},
		-- 	},
		--},	
		set_pieces = {
			["RuinedBase"] = {tasks={"Swamp start", "Battlefield", "Walled Kill the spiders", "Killer Bees!"}},
			["ResurrectionStoneLit"] = { count=4, tasks={"Swamp start", "Battlefield", "Walled Kill the spiders", "Sanity-Blocked Spider Queendom","Killer Bees!",
														"Chessworld",
														"Tentacle-Blocked The Deep Forest",
														"Tentacle-Blocked Spider Swamp",
														"Trapped Forest hunters",
														"Waspy The hunters",
														"Hounded Magic meadow", } },
		},

	}),
 	Level({
		id="ENDING",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[7],
		nomaxwell=true,
		min_playlist_position=CAMPAIGN_LENGTH+1, -- IMPORTANT! This should be the only level allowed to play after the campaign
		max_playlist_position=CAMPAIGN_LENGTH+1,
		overrides={
			{"day", 			"onlynight"}, 
			{"season", 			"onlysummer"},
			{"weather", 		"never"},
			{"creepyeyes", 		"always"},
			{"waves", 			"off"},
			{"boons",			"never"},
		},	
		tasks = {
			"MaxHome",
		},
		numoptionaltasks =0,
		hideminimap = true,
		teleportaction = "restart",
		teleportmaxwell = "ADVENTURE_6_TELEPORTFAIL",
		
		optionaltasks = {
		},
		override_triggers = {
			["MaxHome"] = {	
				{"areaambient", "VOID"}, 
			},
		},
	}),
	
}
levels = { story_levels=story_levels, sandbox_levels=free_levels, cave_levels = cave_levels, free_level=free_levels[1], test_level=test_level, CAMPAIGN_LENGTH=CAMPAIGN_LENGTH }
