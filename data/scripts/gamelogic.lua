require "mods"
require "playerprofile"
require "saveindex"
require "screens/mainscreen"
require "screens/deathscreen"
require "screens/popupdialog"
require "screens/bigpopupdialog"
require "screens/endgamedialog"

Print (VERBOSITY.DEBUG, "[Loading frontend assets]")

local start_game_time = nil

TheSim:SetRenderPassDefaultEffect( RENDERPASS.BLOOM, "data/shaders/anim_bloom.ksh" )
TheSim:SetErosionTexture( "data/images/erosion.tex" )


--this is suuuuuper placeholdery. We need to think about how to handle all of the different types of updates for this
local function DoAgeWorld()
	for k,v in pairs(Ents) do

		--spoil all of the spoilables
		if v.components.perishable then
			v.components.perishable:Perish()
		end
		
		--send things to their homes
		if v.components.homeseeker and v.components.homeseeker.home then
			
			if v.components.homeseeker.home.components.childspawner then
				v.components.homeseeker.home.components.childspawner:GoHome(v)
			end
			
			if v.components.homeseeker.home.components.spawner then
				v.components.homeseeker.home.components.spawner:GoHome(v)
			end
			
		end
		
		if v.components.fueled then
			v.components.fueled:MakeEmpty()
		end
		
	end
end

local function LoadAssets(fe)

	local be_prefabs = {"hud", "forest", "cave", "ceiling", "maxwell", "fire", "character_fire", "shatter"}
	local fe_prefabs = {"frontend"}

	local recipe_prefabs = {}
	for k,v in pairs(Recipes) do
		table.insert(recipe_prefabs, v.name)
		if v.placer then
			table.insert(recipe_prefabs, v.placer)
		end
	end

	if fe then
		print ("LOAD FE")
		TheSim:LoadPrefabs(fe_prefabs)
		TheSim:UnloadPrefabs(be_prefabs)
		TheSim:UnloadPrefabs(recipe_prefabs)
		print ("LOAD FE: done")
	else
		print ("LOAD BE")
		TheSim:UnloadPrefabs(fe_prefabs)
		TheSim:LoadPrefabs(be_prefabs)
		TheSim:LoadPrefabs(recipe_prefabs)
		print ("LOAD BE: done")
	end
end

function GetTimePlaying()
	if not start_game_time then
		return 0
	end
	return GetTime() - start_game_time 
end

function CalculatePlayerRewards(wilson)
	local Progression = require "progressionconstants"
	
	print("Calculating progression")
	
	--increment the xp counter and give rewards
	local days_survived = GetClock().numcycles
	local start_xp = wilson.profile:GetXP()
	local reward_xp = Progression.GetXPForDays(days_survived)
	local new_xp = math.min(start_xp + reward_xp, Progression.GetXPCap())
        
	local all_rewards = Progression.GetRewardsForTotalXP(new_xp)
	for k,v in pairs(all_rewards) do
		wilson.profile:UnlockCharacter(v)
	end
	wilson.profile:SetXP(new_xp)

	print("Progression: ",days_survived, start_xp, reward_xp, new_xp)
	return days_survived, start_xp, reward_xp, new_xp
end


local function HandleDeathCleanup(wilson, data)
    local game_time = GetClock():ToMetricsString()

    if SaveGameIndex:GetCurrentMode() == "survival" then
	    local playtime = GetTimePlaying()
	    playtime = math.floor(playtime*1000)
	    SetTimingStat("time", "scenario", playtime)
	    SendTrackingStats()
	    local days_survived, start_xp, reward_xp, new_xp = CalculatePlayerRewards(wilson)
	    
	    ProfileStatsSet("xp_gain", reward_xp)
	    ProfileStatsSet("xp_total", new_xp)
	    SubmitCompletedLevel() --close off the instance

	    wilson.components.health.invincible = true

	    wilson.profile:Save(function()
		    SaveGameIndex:EraseCurrent(function() 
				    scheduler:ExecuteInTime(3, function() 
						TheFrontEnd:PushScreen(DeathScreen(days_survived, start_xp))
					end)
		    	end)
		    end)
	elseif SaveGameIndex:GetCurrentMode() == "adventure" then

		SaveGameIndex:OnFailAdventure(function()
		    scheduler:ExecuteInTime(3, function() 
				TheFrontEnd:Fade(false, 3, function()
						local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot(), playeranim="failadventure"}
						TheSim:SetInstanceParameters(params)
						TheSim:Reset()
					end)
				end)
			end)	
	elseif SaveGameIndex:GetCurrentMode() == "cave" then
		scheduler:ExecuteInTime(2, function()
				TheFrontEnd:Fade(false, 2, function()
						for k,v in pairs(Ents) do
							if v.prefab == "cave_exit" then
								GetPlayer().Transform:SetPosition(v.Transform:GetWorldPosition())
								break
							end
						end
						
						DoAgeWorld()
						
						SaveGameIndex:SaveCurrent(function()
							SaveGameIndex:OnFailCave(function()
								local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot(), playeranim="failcave"}
								TheSim:SetInstanceParameters(params)
								TheSim:Reset()
							end)
						end)
					end)
				end)

	end
end

local function OnPlayerDeath(wilson, data)

	local cause = data.cause or "unknown"
	local will_resurrect = wilson.components.resurrectable and wilson.components.resurrectable:CanResurrect() 

	
    TheMixer:PushMix("death")
    wilson.HUD:Hide()
    
    local game_time = GetClock():ToMetricsString()
    
	RecordDeathStats(cause, GetClock():GetPhase(), wilson.components.sanity.current, wilson.components.hunger.current, will_resurrect)

	ProfileStatsAdd("killed_by_"..cause)
    
    ProfileStatsAdd("deaths")

    --local res = TheSim:FindFirstEntityWithTag("resurrector")
    
	if will_resurrect then
        scheduler:ExecuteInTime(4, function()  
            TheMixer:PopMix("death")
            if wilson.components.resurrectable:DoResurrect() then
				ProfileStatsAdd("resurrections")
			else
				HandleDeathCleanup(wilson, data)
			end
        end)
    else
		HandleDeathCleanup(wilson, data)
    end
end


function SetUpPlayerCharacterCallbacks(wilson)
    --set up on ondeath handler
    wilson:ListenForEvent( "death", function(inst, data) OnPlayerDeath(wilson, data) end)
    wilson:ListenForEvent( "quit",
        function()
            Print (VERBOSITY.DEBUG, "I SHOULD QUIT!")
            TheMixer:PushMix("death")
            wilson.HUD:Hide()
            local playtime = GetTimePlaying()
            playtime = math.floor(playtime*1000)
            
            RecordQuitStats()
            SetTimingStat("time", "scenario", playtime)
            ProfileStatsSet("time_played", playtime)
            SendTrackingStats()
            SendAccumulatedProfileStats()
            
			TheSim:SetInstanceParameters()
			TheSim:Reset()
        end)        
    
    wilson:ListenForEvent( "daycomplete", 
        function(it, data) 
            if not wilson.components.health:IsDead() then
                RecordEndOfDayStats()
                ProfileStatsAdd("nights_survived_iar")
				SendAccumulatedProfileStats()
            end
        end, GetWorld()) 
        
    --[[wilson:ListenForEvent( "daytime", 
        function(it, data) 
            if not wilson.components.health:IsDead() and not wilson.is_teleporting then
				--print("Day has arrived...")
				--SaveGameIndex:SaveCurrent()
            end
        end, GetWorld()) 
	--]]
    wilson:ListenForEvent("builditem", function(inst, data) ProfileStatsAdd("build_item_"..data.item.prefab) end)    
    wilson:ListenForEvent("buildstructure", function(inst, data) ProfileStatsAdd("build_structure_"..data.item.prefab) end)
end


local function StartGame(wilson)
	
	TheFrontEnd:GetSound():KillSound("FEMusic") -- just in case...
	
	start_game_time = GetTime()
	SetUpPlayerCharacterCallbacks(wilson)
end


local deprecated = { turf_webbing = true }
local replace = { 
				farmplot = "slow_farmplot", farmplot2 = "fast_farmplot", 
				farmplot3 = "fast_farmplot", sinkhole= "cave_entrance",
				cave_stairs= "cave_entrance"
			}

function PopulateWorld(savedata, profile, playercharacter, playersavedataoverride)
    
    playercharacter = playercharacter or "wilson"
	Print(VERBOSITY.DEBUG, "PopulateWorld")
 	Print(VERBOSITY.DEBUG,  "[Instantiating objects...]" )
 	local wilson = nil
    if savedata then

        --figure out our start info
        local spawnpoint = Vector3(0,0,0)
        local playerdata = {}
        if savedata.playerinfo then
        
            if savedata.playerinfo.x and savedata.playerinfo.z then
				local y = savedata.playerinfo.y or 0
                spawnpoint = Vector3(savedata.playerinfo.x, y, savedata.playerinfo.z)
            end
            
            if savedata.playerinfo.data then
                playerdata = savedata.playerinfo.data
            end
        end
        
		if playersavedataoverride then
			playerdata = playersavedataoverride
		end
		
		local newents = {}
		

		--local world = SpawnPrefab("forest")
		local world = nil
		local ceiling = nil
		if savedata.map.prefab == "cave" then
			world = SpawnPrefab("cave")
			ceiling = SpawnPrefab("ceiling")
		else
			world = SpawnPrefab("forest")
		end
		
		
        --spawn the player character and set him up
        TheSim:LoadPrefabs{playercharacter}
        wilson = SpawnPrefab(playercharacter)
        assert(wilson, "could not spawn player character")
        wilson:SetProfile(Profile)
        wilson.Transform:SetPosition(spawnpoint:Get())

        --this was spawned by the level file. kinda lame - we should just do everything from in here.
        local ground = GetWorld()
        if ground then


            if GetCeiling() then
	        	GetCeiling().MapCeiling:SetSize(savedata.map.width, savedata.map.height)
	        	GetCeiling().MapCeiling:SetFromString(savedata.map.tiles)
	        	GetCeiling().MapCeiling:Finalize(TheSim:GetSetting("graphics", "static_walls") == "true")
	        end

            ground.Map:SetSize(savedata.map.width, savedata.map.height)
	        if savedata.map.prefab == "cave" then
	        	ground.Map:SetPhysicsWallDistance(0.75)--0) -- TEMP for STREAM
	        else
	        	ground.Map:SetPhysicsWallDistance(0)--0.75)
	        end

            ground.Map:SetFromString(savedata.map.tiles)
            ground.Map:Finalize()
	        



            if savedata.map.nav then
             	print("Loading Nav Grid")
             	ground.Map:SetNavSize(savedata.map.width, savedata.map.height)
             	ground.Map:SetNavFromString(savedata.map.nav)
             else
             	print("No Nav Grid")
            end
			
            ground.hideminimap = savedata.map.hideminimap
			ground.topology = savedata.map.topology
			ground.meta = savedata.meta
			assert(savedata.map.topology.ids, "[MALFORMED SAVE DATA] Map missing topology information. This save file is too old, and is missing neccessary information.")
			
			for i=#savedata.map.topology.ids,1, -1 do
				local name = savedata.map.topology.ids[i]
				if string.find(name, "LOOP_BLANK_SUB") ~= nil then
					table.remove(savedata.map.topology.ids, i)
					table.remove(savedata.map.topology.nodes, i)
					for eid=#savedata.map.topology.edges,1,-1 do
						if savedata.map.topology.edges[eid].n1 == i or savedata.map.topology.edges[eid].n2 == i then
							table.remove(savedata.map.topology.edges, eid)
						end
					end
				end
			end		
			
			if ground.topology.level_number ~= nil then
				require("map/levels")
				if levels.story_levels[ground.topology.level_number] ~= nil then
					profile:UnlockWorldGen("preset", levels.story_levels[ground.topology.level_number].name)
				end
			end
			
			wilson:AddComponent("area_aware")
			--wilson:AddComponent("area_unlock")
			
			if ground.topology.override_triggers then
				wilson:AddComponent("area_trigger")
				
				wilson.components.area_trigger:RegisterTriggers(ground.topology.override_triggers)
			end
				
			
			for i,node in ipairs(ground.topology.nodes) do
				local story = ground.topology.ids[i]
				-- guard for old saves
				local story_depth = nil
				if ground.topology.story_depths then
					story_depth = ground.topology.story_depths[i]
				end
				if story ~= "START" then
					story = string.sub(story, 1, string.find(story,":")-1)
--					
--					if Profile:IsWorldGenUnlocked("tasks", story) == false then
--						wilson.components.area_unlock:RegisterStory(story)
--					end
				end
				wilson.components.area_aware:RegisterArea({idx=i, type=node.type, poly=node.poly, story=story, story_depth=story_depth})
								
				if node.type == "Graveyard" or node.type == "MistyCavern" then
					if node.area_emitter == nil then

						local mist = SpawnPrefab( "mist" )
						mist.Transform:SetPosition( node.cent[1], 0, node.cent[2] )
						mist.components.emitter.area_emitter = CreateAreaEmitter( node.poly, node.cent )
						
						if node.area == nil then
							node.area = 1
						end
						
						mist.components.emitter.density_factor = math.ceil(node.area / 4)/31
						mist.components.emitter:Emit()
					end
				end

			end

			if savedata.map.persistdata ~= nil then
				ground:SetPersistData(savedata.map.persistdata)
			end

			
			wilson.components.area_aware:StartCheckingPosition()
        end
        
        
        wilson:SetPersistData(playerdata, newents)
        if wilson.components.health.currenthealth == 0 then
			wilson.components.health.currenthealth = 1
        end
        if savedata.playerinfo and savedata.playerinfo.id then
            newents[savedata.playerinfo.id] = {entity=wilson, data=playerdata} 
        end
        
        
        --set the clock (LEGACY! this is now handled via the world object's normal serialization)
        if savedata.playerinfo.day and savedata.playerinfo.dayphase and savedata.playerinfo.timeleftinera then
	        
			GetClock().numcycles = savedata.playerinfo and savedata.playerinfo.day or 0
			if savedata.playerinfo and savedata.playerinfo.dayphase == "night" then
        		GetClock():StartNight(true)
			elseif savedata.playerinfo and savedata.playerinfo.dayphase == "dusk" then
        		GetClock():StartDusk(true)
      		else 
        		GetClock():StartDay(true)
			end
	        
			if savedata.playerinfo.timeleftinera then
				GetClock().timeLeftInEra = savedata.playerinfo.timeleftinera
			end
		end

        -- Force overrides for ambient
		local retune = require("tuning_override")
		retune.OVERRIDES["areaambientdefault"].doit(savedata.map.prefab)

		-- Check for map overrides
		if ground.topology.overrides ~= nil and ground.topology.overrides ~= nil and GetTableSize(ground.topology.overrides) > 0 then			
			for area, overrides in pairs(ground.topology.overrides) do	
				for i,override in ipairs(overrides) do	
					if retune.OVERRIDES[override[1]] ~= nil then
						retune.OVERRIDES[override[1]].doit(override[2])
					end
				end
			end
		end
        
        --instantiate all the dudes
        for prefab, ents in pairs(savedata.ents) do
			local prefab = replace[prefab] or prefab
       		if not deprecated[prefab] then
                for k,v in ipairs(ents) do
                    v.prefab = v.prefab or prefab -- prefab field is stripped out when entities are saved in global entity collections, so put it back
					SpawnSaveRecord(v, newents)
				end
			end
        end    
    
        --post pass in neccessary to hook up references
        for k,v in pairs(newents) do
            v.entity:LoadPostPass(newents, v.data)
        end
        GetWorld():LoadPostPass(newents, savedata.map.persistdata)
        

		--Run scenario scripts
        for guid, ent in pairs(Ents) do
			if ent.components.scenariorunner then
				ent.components.scenariorunner:Run()
			end
		end

		--Record mod information
		ModManager:SetModRecords(savedata.mods or {})
        
        if SaveGameIndex:GetCurrentMode() ~= "adventure" and GetWorld().components.age and GetPlayer().components.age then
			local player_age = GetPlayer().components.age:GetAge()
			local world_age = GetWorld().components.age:GetAge()
			
			if world_age <= 0 then
				GetWorld().components.age.saved_age = player_age
			elseif player_age > world_age then
				local catch_up = player_age - world_age 
				print ("Catching up world", catch_up)
				LongUpdate(catch_up, true)
				
				--this is a cheesy workaround for coming out of a cave at night, so you don't get immediately eaten
				if SaveGameIndex:GetCurrentMode() == "survival" and not GetWorld().components.clock:IsDay() then
					local light = SpawnPrefab("exitcavelight")
					light.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
				end
				
			end
        end
    
    else
        Print(VERBOSITY.ERROR, "[MALFORMED SAVE DATA] PopulateWorld complete" )
        return
    end

	Print(VERBOSITY.DEBUG, "[FINISHED LOADING SAVED GAME] PopulateWorld complete" )
	return wilson
end


local function DrawDebugGraph(graph)
	-- debug draw of new map gen
	local debugdrawmap = CreateEntity()
	local draw = debugdrawmap.entity:AddDebugRender()
	draw:SetZ(0.1)
	
	
	for idx,node in ipairs(graph.nodes) do
		local colour = graph.colours[node.c]
		
		for i =1, #node.poly-1 do
			draw:Line(node.poly[i][1], node.poly[i][2], node.poly[i+1][1], node.poly[i+1][2], colour.r, colour.g, colour.b, 255)
		end
		draw:Line(node.poly[1][1], node.poly[1][2], node.poly[#node.poly][1], node.poly[#node.poly][2], colour.r, colour.g, colour.b, 255)
		
		draw:Poly(node.cent[1], node.cent[2], colour.r, colour.g, colour.b, colour.a, node.poly)
			
		draw:String(graph.ids[idx].."("..node.cent[1]..","..node.cent[2]..")", 	node.cent[1], node.cent[2], node.ts)
	end 
	
	draw:SetZ(0.15)

	for idx,edge in ipairs(graph.edges) do
		if edge.n1 ~= nil and edge.n2 ~= nil then
			local colour = graph.colours[edge.c]
			
			local n1 = graph.nodes[edge.n1]
			local n2 = graph.nodes[edge.n2]
			if n1 ~= nil and n2 ~= nil then
				draw:Line(n1.cent[1], n1.cent[2], n2.cent[1], n2.cent[2], colour.r, colour.g, colour.b, colour.a)
			end
		end
	end 
end

--OK, we have our savedata and a profile. Instatiate everything and start the game!
function DoInitGame(playercharacter, savedata, profile, next_world_playerdata, fast)	
	--print("DoInitGame",playercharacter, savedata, profile, next_world_playerdata, fast)
	TheFrontEnd:ClearScreens()	
	LoadAssets(false)
	
	assert(savedata.map, "Map missing from savedata on load")
	assert(savedata.map.prefab, "Map prefab missing from savedata on load")
	assert(savedata.map.tiles, "Map tiles missing from savedata on load")
	assert(savedata.map.width, "Map width missing from savedata on load")
	assert(savedata.map.height, "Map height missing from savedata on load")
	
	assert(savedata.map.topology, "Map topology missing from savedata on load")
	assert(savedata.map.topology.ids, "Topology entity ids are missing from savedata on load")
	--assert(savedata.map.topology.story_depths, "Topology story_depths are missing from savedata on load")
	assert(savedata.map.topology.colours, "Topology colours are missing from savedata on load")
	assert(savedata.map.topology.edges, "Topology edges are missing from savedata on load")
	assert(savedata.map.topology.nodes, "Topology nodes are missing from savedata on load")
	assert(savedata.map.topology.level_type, "Topology level type is missing from savedata on load")
	assert(savedata.map.topology.overrides, "Topology overrides is missing from savedata on load")
        
	assert(savedata.playerinfo, "Playerinfo missing from savedata on load")
	assert(savedata.playerinfo.x, "Playerinfo.x missing from savedata on load")
	--assert(savedata.playerinfo.y, "Playerinfo.y missing from savedata on load")   --y is often omitted for space, don't check for it
	assert(savedata.playerinfo.z, "Playerinfo.z missing from savedata on load")
	--assert(savedata.playerinfo.day, "Playerinfo day missing from savedata on load")

	assert(savedata.ents, "Entites missing from savedata on load")
	
	if savedata.map.roads then
		Roads = savedata.map.roads
		for k, road_data in pairs( savedata.map.roads ) do
			RoadManager:BeginRoad()
			local weight = road_data[1]
			
			if weight == 3 then
				for i = 2, #road_data do
					local ctrl_pt = road_data[i]
					RoadManager:AddControlPoint( ctrl_pt[1], ctrl_pt[2] )
				end

				for k, v in pairs( ROAD_STRIPS ) do
					RoadManager:SetStripEffect( v, "data/shaders/road.ksh" )
				end
				
				RoadManager:SetStripTextures( ROAD_STRIPS.EDGES,	"data/images/roadedge.tex",		"data/images/roadnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.CENTER,	"data/images/square.tex",		"data/images/roadnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.CORNERS,	"data/images/roadcorner.tex",	"data/images/roadnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.ENDS,		"data/images/roadendcap.tex",	"data/images/roadnoise.tex" )
			
				RoadManager:GenerateVB(
						ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
						ROAD_PARAMETERS.MIN_WIDTH, ROAD_PARAMETERS.MAX_WIDTH,
						ROAD_PARAMETERS.MIN_EDGE_WIDTH, ROAD_PARAMETERS.MAX_EDGE_WIDTH,
						ROAD_PARAMETERS.WIDTH_JITTER_SCALE, true )
			else
				for i = 2, #road_data do
					local ctrl_pt = road_data[i]
					RoadManager:AddControlPoint( ctrl_pt[1], ctrl_pt[2] )
				end
				
				for k, v in pairs( ROAD_STRIPS ) do
					RoadManager:SetStripEffect( v, "data/shaders/road.ksh" )
				end
				RoadManager:SetStripTextures( ROAD_STRIPS.EDGES,	"data/images/roadedge.tex",		"data/images/pathnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.CENTER,	"data/images/square.tex",		"data/images/pathnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.CORNERS,	"data/images/roadcorner.tex",	"data/images/pathnoise.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.ENDS,		"data/images/roadendcap.tex",	"data/images/pathnoise.tex" )
				
				RoadManager:GenerateVB(
						ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
						0, 0,
						ROAD_PARAMETERS.MIN_EDGE_WIDTH*4, ROAD_PARAMETERS.MAX_EDGE_WIDTH*4,
						0, false )						
				--[[
			else
				for i = 2, #road_data do
					local ctrl_pt = road_data[i]
					RoadManager:AddSmoothedControlPoint( ctrl_pt[1], ctrl_pt[2] )
				end
				
				for k, v in pairs( ROAD_STRIPS ) do
					RoadManager:SetStripEffect( v, "data/shaders/river.ksh" )
				end
				RoadManager:SetStripTextures( ROAD_STRIPS.EDGES,	"data/images/square.tex",		"data/images/river_bed.tex" )
				RoadManager:SetStripTextures( ROAD_STRIPS.CENTER,	"data/images/square.tex",		"data/images/water_river.tex" )
				RoadManager:SetStripUVAnimStep( ROAD_STRIPS.CENTER, 0, 0.25 )
				RoadManager:SetStripWrapMode( ROAD_STRIPS.EDGES, WRAP_MODE.CLAMP_TO_EDGE, WRAP_MODE.WRAP )
				--RoadManager:SetStripTextures( ROAD_STRIPS.CORNERS,	"data/images/roadcorner.tex",	"data/images/pathnoise.tex" )
				--RoadManager:SetStripTextures( ROAD_STRIPS.ENDS,		"data/images/roadendcap.tex",	"data/images/pathnoise.tex" )
				
				RoadManager:GenerateVB(
						ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
						5, 5,
						2, 2,
						0, false )
				--]]
			end
		end
		RoadManager:GenerateQuadTree()
	end
	
	SubmitStartStats(playercharacter)
	
    --some lame explicit loads
	Print(VERBOSITY.DEBUG, "DoInitGame Loading prefabs...")
    
	Print(VERBOSITY.DEBUG, "DoInitGame Adjusting audio...")
    TheMixer:SetLevel("master", 0)
    
	--apply the volumes
	
	Print(VERBOSITY.DEBUG, "DoInitGame Populating world...")
	
    local wilson = PopulateWorld(savedata, profile, playercharacter, next_world_playerdata)
    if wilson then
		TheCamera:SetTarget(wilson)
		StartGame(wilson)
		TheCamera:SetDefault()
		TheCamera:Snap()
	else
		Print(VERBOSITY.WARNING, "DoInitGame NO WILSON?")
    end
    
    if Profile.persistdata.debug_world  == 1 then
    	if savedata.map.topology == nil then
    		Print(VERBOSITY.ERROR, "OI! Where is my topology info!")
    	else
    		DrawDebugGraph(savedata.map.topology)
     	end
    end
    
    local function OnStart()
    	Print(VERBOSITY.DEBUG, "DoInitGame OnStart Callback... turning volume up")
		SetHUDPause(false)
    end
	
	if not TheFrontEnd:IsDisplayingError() then
		local hud = PlayerHud()
		TheFrontEnd:PushScreen(hud)
		hud:SetMainCharacter(wilson)
		
	    --clear the player stats, so that it doesn't count items "acquired" from the save file
	    GetProfileStats(true)

		RecordSessionStartStats()
		
	    --after starting everything up, give the mods additional environment variables
	    ModManager:SimPostInit(wilson)
		
		GetPlayer().components.health:RecalculatePenalty()

		if ( SaveGameIndex:GetCurrentMode() ~= "cave" and (SaveGameIndex:GetCurrentMode() == "survival" or SaveGameIndex:GetSlotWorld() == 1) and SaveGameIndex:GetSlotDay() == 1 and GetClock():GetNormTime() == 0) then
			if GetPlayer().components.inventory.starting_inventory then
				for k,v in pairs(GetPlayer().components.inventory.starting_inventory) do
					local item = SpawnPrefab(v)
					if item then
						GetPlayer().components.inventory:GiveItem(item)
					end
				end
			end
		end

	    if fast then
	    	OnStart()
	    else
			SetHUDPause(true,"InitGame")
			if Settings.playeranim == "failcave" then
				GetPlayer().sg:GoToState("wakeup")
				GetClock():MakeNextDay()
			elseif Settings.playeranim == "failadventure" then
				GetPlayer().sg:GoToState("failadventure")
				GetPlayer().HUD:Show()
			elseif GetWorld():IsCave() then
				GetPlayer().sg:GoToState("caveenter")
				GetPlayer().HUD:Show()
			elseif Settings.playeranim == "wakeup" or playercharacter == "waxwell" or savedata.map.nomaxwell then
				
				GetPlayer().sg:GoToState("wakeup")
				GetPlayer().HUD:Show()
				--announce your freedom if you are starting as waxwell
				if playercharacter == "waxwell" and SaveGameIndex:GetCurrentMode() == "survival" and (GetClock().numcycles == 0 and GetClock():GetNormTime() == 0) then
					GetPlayer():DoTaskInTime( 3.5, function()
						GetPlayer().components.talker:Say(GetString("waxwell", "ANNOUNCE_FREEDOM"))
					end)
				end

			elseif (GetClock().numcycles == 0 and GetClock():GetNormTime() == 0) or Settings.maxwell ~= nil then

				local max = SpawnPrefab("maxwellintro")
				local speechName = "NULL_SPEECH"
				if Settings.maxwell then
					speechName = Settings.maxwell
				elseif SaveGameIndex:GetCurrentMode() == "adventure" then
					if savedata.map.override_level_string == true then
						local level_id = 1
						if GetWorld().meta then
							level_id = GetWorld().meta.level_id or level_id 
						end

						speechName = "ADVENTURE_"..level_id
					else
						speechName = "ADVENTURE_"..SaveGameIndex:GetSlotWorld()
					end
				else
					speechName = "SANDBOX_1"
				end
				max.components.maxwelltalker:SetSpeech(speechName)
				max.components.maxwelltalker:Initialize()
				max.task = max:StartThread(function()	max.components.maxwelltalker:DoTalk() end) 
				--PlayNIS("maxwellintro", savedata.map.maxwell)
			end
			
			
			local title = STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[SaveGameIndex:GetSlotLevelIndexFromPlaylist()]
			local subtitle = STRINGS.UI.SANDBOXMENU.CHAPTERS[SaveGameIndex:GetSlotWorld()]
			local showtitle = SaveGameIndex:GetCurrentMode() == "adventure" and title
			if showtitle then
				TheFrontEnd:ShowTitle(title,subtitle)
			end
			
			TheFrontEnd:Fade(true, 1, function() 
				SetHUDPause(false)
				TheMixer:SetLevel("master", 1) 
				TheMixer:PushMix("normal") 
				TheFrontEnd:HideTitle()
				--TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.HUD.READYTITLE, STRINGS.UI.HUD.READY, {{text=STRINGS.UI.HUD.START, cb = function() OnStart() end}}))
			end, showtitle and 3, showtitle and function() SetHUDPause(false) end )
	    end
	    
	    if savedata.map.hideminimap ~= nil then
	        hud.minimap:DoTaskInTime(0, function(inst) inst.MiniMap:ClearRevealedAreas(savedata.map.hideminimap) end)
	    end
	    if savedata.map.teleportaction ~= nil then
	        local teleportato = TheSim:FindFirstEntityWithTag("teleportato")
	        if teleportato then
	        	local pickPosition = function() 
	        		local portpositions = GetRandomInstWithTag("teleportlocation", teleportato, 1000)
	        		if portpositions then
	        			return Vector3(portpositions.Transform:GetWorldPosition())
	        		else
	        			return Vector3(savedata.playerinfo.x, savedata.playerinfo.y or 0, savedata.playerinfo.z)
	        		end
	        	end
	            teleportato.action = savedata.map.teleportaction
	            teleportato.maxwell = savedata.map.teleportmaxwell
	            teleportato.teleportpos = pickPosition()
	        end
	    end
	end
	
    --DoStartPause("Ready!")
    Print(VERBOSITY.DEBUG, "DoInitGame complete")
    
    if PRINT_TEXTURE_INFO then
		c_printtextureinfo( "texinfo.csv" )
		TheSim:Quit()
	end    
end

------------------------THESE FUNCTIONS HANDLE STARTUP FLOW


local function DoLoadWorld(saveslot, playerdataoverride)
	local function onload(savedata)
		DoInitGame(SaveGameIndex:GetSlotCharacter(saveslot), savedata, Profile, playerdataoverride)
	end
	SaveGameIndex:GetSaveData(saveslot, SaveGameIndex:GetCurrentMode(saveslot), onload)
end

local function DoGenerateWorld(saveslot, type_override)

	local function onComplete(savedata )
		local function onsaved()
			local success, world_table = RunInSandbox(savedata)
			if success then

				DoInitGame(SaveGameIndex:GetSlotCharacter(saveslot), world_table, Profile, SaveGameIndex:GetPlayerData(saveslot))
			end
		end

		SaveGameIndex:OnGenerateNewWorld(saveslot, savedata, onsaved)
	end

	local world_gen_options =
	{
		level_type = type_override or SaveGameIndex:GetCurrentMode(saveslot),
		custom_options = SaveGameIndex:GetSlotGenOptions(saveslot,SaveGameIndex:GetCurrentMode()),
		level_world = SaveGameIndex:GetSlotLevelIndexFromPlaylist(saveslot),
		profiledata = Profile.persistdata,
	}
	
	if world_gen_options.level_type == "adventure" then
		world_gen_options["adventure_progress"] = SaveGameIndex:GetSlotWorld()
	elseif world_gen_options.level_type == "cave" then
		world_gen_options["cave_progress"] = SaveGameIndex:GetCurrentCaveLevel()
	end

	TheFrontEnd:PushScreen(WorldGenScreen(Profile, onComplete, world_gen_options))
end

local function LoadSlot(slot)
	TheFrontEnd:ClearScreens()
	if SaveGameIndex:HasWorld(slot, SaveGameIndex:GetCurrentMode(slot)) then
   		DoLoadWorld(slot, SaveGameIndex:GetModeData(slot, SaveGameIndex:GetCurrentMode(slot)).playerdata)
	else
		LoadAssets(true)
		if SaveGameIndex:GetCurrentMode(slot) == "survival" and SaveGameIndex:IsContinuePending(slot) then
			
			local function onsave()
				DoGenerateWorld(slot)
			end

			local function onSet(character)
				SaveGameIndex:SetSlotCharacter(slot, character, onsave)
			end
			TheFrontEnd:PushScreen(CharacterSelectScreen(Profile, onSet, true, SaveGameIndex:GetSlotCharacter(slot)))
		else			
			DoGenerateWorld(slot)
		end
	end
end



----------------LOAD THE PROFILE AND THE SAVE INDEX, AND START THE FRONTEND

local function OnFilesLoaded()
	UpdateGamePurchasedState( function()
		--print( "[Settings]",Settings.character, Settings.savefile)
		if Settings.reset_action then
			if Settings.reset_action == "loadslot" then
				if not SaveGameIndex:GetCurrentMode(Settings.save_slot) then
					LoadAssets(true)
					TheFrontEnd:ShowScreen(MainScreen(Profile))
				else
					LoadSlot(Settings.save_slot)
				end
			elseif Settings.reset_action == "printtextureinfo" then
				LoadAssets(true)
				DoGenerateWorld(1)
			else
				LoadAssets(true)
				TheFrontEnd:ShowScreen(MainScreen(Profile))
			end
		else
			if PRINT_TEXTURE_INFO then
				SaveGameIndex:DeleteSlot(1,
					function()
						local function onsaved()
							local params = json.encode{reset_action="printtextureinfo", save_slot = 1}
							TheSim:SetInstanceParameters(params)
							TheSim:Reset()
						end
						SaveGameIndex:StartSurvivalMode(1, "wilson", {}, onsaved)
					end)
			else
				LoadAssets(true)
				TheFrontEnd:ShowScreen(MainScreen(Profile))
			end
		end
	end)
end


Profile = PlayerProfile()
SaveGameIndex = SaveIndex()

Print(VERBOSITY.DEBUG, "[Loading profile and save index]")
Profile:Load( function() 
	SaveGameIndex:Load( OnFilesLoaded )
end )

--dont_load_save in profile
