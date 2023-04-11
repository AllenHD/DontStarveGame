--[[
    Suggested taxomony for structuring stats
    NOT a final definition of what will be saved

    UserID = {
        UserStats = {   - cumulative user stats   Are items with the same label replaced in the database or appended?
            currentDate = <date>,
            totalDeaths = <number>,
            totalSession = <number>,
            totalTime = <time>, -- Minus idle
            daysSinceLastSession = <number>,
            sessionsStarted = <number>,
            deathsThisSession = <number>,
            avgSessionDuration = <number>,
            avgInterSessionTime = <number>,
            totalMilesRun = <number>,
            gamesUsingConsole = <number>,
            ConsoleUse = { numSpawns=<number>,timeInGodMode=<number>, ... ? },
            Frontend = {   -- Preset/customization menu uses, simultaneous saved games
                Customizations = {
                    SettingA = { setting=<value>, gamesPlayedWithThisValue },
                    SettingB = { setting=<value>, gamesPlayedWithThisValue },
                    },
                Mods = {
                    },
                }
            },
        GameID = {
            Game = {
                resurrections = <number>,
                timePlaying = <RealTime>,    -- realtime length of session minus idle (away from keyboard)
                idleTime = <RealTime>,       -- time game running but not being played  (add to timePlaying to find total time game running)
                endWithSave = <boolean>,
                consoleUsed = <boolean>,
                timeInGodMode = <time>,
                ConsoleUse = { numSpawns=<number>,timeInGodMode=<number>, ...? },
                Crafting = {
                    Summary = {
                        totalDayBuilds = <number>,
                        totalNightBuilds = <number>,
                        totalSeasonBuilds = <array>,
                                    -- or do we do it like this?
                                    --   totalSeasonBuilds = {Winter=<number>,Spring=<number>,Summer=<number>,Fall=<number>},
                                    -- or like this?
                                    --    totalWinterBuilds = <number>,
                                    --    totalSpringBuilds = <number>,
                                    --    totalSummerBuilds = <number>,
                                    --    totalFallBuilds = <number>,
                        },
                    Item1 = {
                        firstbuild = <time>,
                        totalBuilt = <number>,
                        seasonBuilds = {Winter=<number>,Spring=<number>,Summer=<number>,Fall=<number>},
                        },
                    Item2 = {
                        firstbuild = <time>,
                        totalBuilt = <number>,
                        seasonBuilds = {Winter=<number>,Spring=<number>,Summer=<number>,Fall=<number>},
                        },
                    ...
                    },
                Harvesting = {
                    Summary = {
                        totalDayBuilds = <number>,
                        totalNightBuilds = <number>,
                        totalSeasonBuilds = {Winter=<number>,Spring=<number>,Summer=<number>,Fall=<number>},
                        },
                    Item1 = {
                        firstbuild = <time>,
                        totalBuilt = <number>,
                        seasonBuilds = {Winter=<number>,Spring=<number>,Summer=<number>,Fall=<number>},
                        },
                        ...
                    },
                Fighting = {
                    },
                Exploration = {
                    distanceCovered = {night=<number>,other=<number>},
                    totalMapExplored = <percent>,
                    mapExploredToday = <percent>,
                    mapExplored = {total=<percent>,today=<percent>,Winter=<percent>,Spring=<percent>,Summer=<percent>,Fall=<percent>},
                    },
                },
            UI = {
                Crafting = {
                    summary = {   -- Provide a easy label to get all summary info out of the database?
                        firstuse = <number>,
                        totalTimeLooking = <number>,
                        averageTimePerLook = <number>,
                        averageBuildsPerLook = <number>,
                        looksWithoutBuilding = <number>,
                        ...
                        },
                     tools = {   -- here to show structure, not sure what stats we would want to collect here
                        },
                     fire = {
                        },

                    },
                },
            Frontend = {   -- Preset/customization menu uses, simultaneous saved games, mods enabled
                },
            },
        },



--]]

STATS_ENABLE = true
-- NOTE: There is also a call to 'anon/start' in dontstarve/main.cpp which has to be un/commented

--- non-user-facing Tracking stats  ---
TrackingEventsStats = {}
TrackingTimingStats = {}
function IncTrackingStat(stat, subtable)

    local t = TrackingEventsStats
    if subtable then
        t = TrackingEventsStats[subtable]

        if not t then
            t = {}
            TrackingEventsStats[subtable] = t
        end
    end

    t[stat] = 1 + (t[stat] or 0)
end

function SetTimingStat(subtable, stat, value)

    local t = TrackingTimingStats
    if subtable then
        t = TrackingTimingStats[subtable]

        if not t then
            t = {}
            TrackingTimingStats[subtable] = t
        end
    end

    t[stat] = math.floor(value/1000)
end


function SendTrackingStats()
	if GetTableSize(TrackingEventsStats) then
    	local stats = json.encode({events=TrackingEventsStats, timings=TrackingTimingStats})
    	TheSim:LogBulkMetric(stats)
    end
end


function BuildContextTable()
	local sendstats = {}

	sendstats.user = TheSim:GetUserID()
	if sendstats.user == nil then
		if BRANCH == "release" then
			sendstats.user = "unknown"
		else
			sendstats.user = "testing"
		end
	end
	if BRANCH ~= "release" then
		sendstats.user = sendstats.user
	end

	sendstats.branch = BRANCH

	if ModManager:GetModNames() and #ModManager:GetModNames() > 0 then
		sendstats.branch = sendstats.branch .. "_modded"
	end

	sendstats.build = APP_VERSION

	if GetSeasonManager() then
		sendstats.season = GetSeasonManager():GetSeasonString()
	end

	if GetClock() then
		sendstats.day = GetClock().numcycles
	end

	if GetWorld() then
		-- we don't want everything in meta, ony things which are stats-relevant
		sendstats.map_meta = {}
		sendstats.map_meta.level_id = GetWorld().meta.level_id
		sendstats.map_meta.seed = GetWorld().meta.seed
		sendstats.map_meta.build_version = GetWorld().meta.build_version

		sendstats.mode = GetWorld().topology.level_type or "UNKNOWN"
	end

	sendstats.save_id = SaveGameIndex:GetSaveID()

	return sendstats
end


--- GAME Stats and details to be sent to server on game complete ---
ProfileStats = {}

function GetProfileStats(wipe)
	if GetTableSize(ProfileStats) == 0 then
		return json.encode( {} )
	end

	wipe = wipe or false
	local jsonstats = ''
	local sendstats = BuildContextTable()

	sendstats.stats = ProfileStats

	jsonstats = json.encode( sendstats )

	if wipe then
		ProfileStats = {}
    end
    return jsonstats
end


function RecordEndOfDayStats()
	if not STATS_ENABLE then
		return
	end

    -- Do local analysis of game session so far
    dprint("RecordEndOfDayStats")
end

function RecordQuitStats()
	if not STATS_ENABLE then
		return
	end

    -- Do local analysis of game session
    dprint("RecordQuitStats")
end

function RecordPauseStats()         -- Run some analysis and save stats when player pauses
	if not STATS_ENABLE or not IsHUDPaused() then
		return
	end
    dprint("RecordPauseStats")
end

function RecordDeathStats(killed_by, time_of_day, sanity, hunger, will_resurrect)
	if not STATS_ENABLE then
		return
	end

	local sendstats = BuildContextTable()
	sendstats.death = {
		killed_by=killed_by,
		time_of_day=time_of_day,
		sanity=sanity,
		hunger=hunger,
		will_resurrect=will_resurrect,
	}

	local jsonstats = json.encode( sendstats )
	--print("Sending death stats...\n")
	--print(jsonstats)
	TheSim:SendProfileStats( jsonstats )
end

function RecordSessionStartStats()
	if not STATS_ENABLE then
		return
	end

	-- TODO: This should actually just write the specific start stats, and it will eventually
	-- be rolled into the "quit" stats and sent off all at once.
	local sendstats = BuildContextTable()
	sendstats.Session = {
		Loads = {
			Mods = { 
				mod = false,
				list = {}
				
			},
		}
	}

	for i,name in ipairs(ModManager:GetEnabledModNames()) do
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, name)
	end
	
	local jsonstats = json.encode( sendstats )
	print("Sending sessions start stats...\n")
	print(jsonstats)
	TheSim:SendProfileStats( jsonstats )
end

-- value is optional, 1 if nil
function ProfileStatsAdd(item, value)
    --print ("ProfileStatsAdd", item)
    if value == nil then
        value = 1
    end

    if ProfileStats[item] then
    	ProfileStats[item] = ProfileStats[item] + value
    else
    	ProfileStats[item] = value
    end
end

function ProfileStatsAddItemChunk(item, chunk)
    if ProfileStats[item] == nil then
    	ProfileStats[item] = {}
    end

    if ProfileStats[item][chunk] then
    	ProfileStats[item][chunk] =ProfileStats[item][chunk] +1
    else
    	ProfileStats[item][chunk] = 1
    end
end

function ProfileStatsSet(item, value)
	ProfileStats[item] = value
end

function SendAccumulatedProfileStats()
	if not STATS_ENABLE then
		return
	end
	local stats = GetProfileStats(true)
	print("Sending stats...\n")
	print(stats)
	TheSim:SendProfileStats( stats )
end

--Periodically upload and refresh the player stats, so we always
--have up-to-date stats even if they close/crash the game.
StatsHeartbeatRemaining = 30
function AccumulatedStatsHeartbeat(dt)
    -- only fire this while in-game
    local player = GetPlayer()
    if player then
        ProfileStatsAdd("time_played", math.floor(dt*1000))
        StatsHeartbeatRemaining = StatsHeartbeatRemaining - dt
        if StatsHeartbeatRemaining < 0 then
            SendAccumulatedProfileStats()
            StatsHeartbeatRemaining = 120
        end
    end
end

function SubmitCompletedLevel()
	SendAccumulatedProfileStats()
end

function SubmitStartStats(playercharacter)
	if not STATS_ENABLE then
		return
	end
	
	-- At the moment there are no special start stats.
end

function SubmitExitStats()
	if not STATS_ENABLE then
	    Shutdown()
		return
	end

	-- At the moment there are no special exit stats.
	Shutdown()
end

function SubmitQuitStats()
	if not STATS_ENABLE then
		return
	end

	-- At the moment there are no special quit stats.
end

