
local wall_update_fns = {}
function AddWallUpdateFn(fn)
	wall_update_fns[ fn ] = fn
end

local DebugCommands = {}
function InjectDebugCommand(data)
	table.insert(DebugCommands, data)
end

--this is an update that always runs on wall time (not sim time)
function WallUpdate(dt)
	TheSim:ProfilerPush("LuaWallUpdate")
	if GetPlayer() then
		local x,y,z = GetPlayer().Transform:GetWorldPosition()
		TheSim:SetActiveAreaCenterpoint(x,y,z)
	end
	
	if #DebugCommands > 0 then
		for k,v in ipairs(DebugCommands) do
			local fn, message = loadstring(v)
			if not fn then
				print ("Error running debug command:", message)
			else
				fn()
			end
		end
		DebugCommands = {}
	end

	for k,v in pairs(wall_update_fns) do
		if not (v and v(dt)) then
			wall_update_fns[k] = nil
		end
	end	

    TheMixer:Update(dt)

	if not IsHUDPaused() then
		TheCamera:Update(dt)
	end
    
	CheckForUpsellTimeout(dt)

    TheInput:OnUpdate()
	TheFrontEnd:Update(dt)
	
	TheSim:ProfilerPop()
end

function PostUpdate(dt)
	TheSim:ProfilerPush("LuaPostUpdate")
	EmitterManager:PostUpdate()
	TheSim:ProfilerPop()
end


local StaticComponentLongUpdates = {}
function RegisterStaticComponentLongUpdate(classname, fn)
	StaticComponentLongUpdates[classname] = fn
end


local StaticComponentUpdates = {}
function RegisterStaticComponentUpdate(classname, fn)
	StaticComponentUpdates[classname] = fn
end


local last_tick_seen = -1
--This is where the magic happens
function Update( dt )
	TheSim:ProfilerPush("LuaUpdate")    
	CheckDemoTimeout()
    
    if PLATFORM == "NACL" then
        AccumulatedStatsHeartbeat(dt)
    end
	
    
    local tick = TheSim:GetTick()
    if tick > last_tick_seen then
    	TheSim:ProfilerPush("scheduler")
        for i = last_tick_seen +1, tick do
            RunScheduler(i)
        end
		TheSim:ProfilerPop()
		
		TheSim:ProfilerPush("static components")
		for k,v in pairs(StaticComponentUpdates) do
			v(dt)
		end
        TheSim:ProfilerPop()

		TheSim:ProfilerPush("updating components")
        for k,v in pairs(UpdatingEnts) do
            if v.updatecomponents then
                for cmp in pairs(v.updatecomponents) do
                    if cmp.OnUpdate then
                        cmp:OnUpdate( dt )
                    end
                end
            end
        end
        
		for k,v in pairs(NewUpdatingEnts) do
			UpdatingEnts[k] = v
	    end
	    NewUpdatingEnts = {}
        TheSim:ProfilerPop()
        

        for i = last_tick_seen + 1, tick do
            TheSim:ProfilerPush("LuaSG")
            SGManager:Update(i)
            TheSim:ProfilerPop()
            
            TheSim:ProfilerPush("LuaBrain")
            BrainManager:Update(i)
            TheSim:ProfilerPop()
        end
    else
		print ("Saw this before")
    end
    last_tick_seen = tick
    
	TheSim:ProfilerPop()        
end


--this is for advancing the sim long periods of time (to skip nights, come back from caves, etc)
function LongUpdate(dt, ignore_player)

	local function doupdate(dt)
		for k,v in pairs(StaticComponentLongUpdates) do
			v(dt)
		end

		local player = GetPlayer()
		for k,v in pairs(Ents) do
			local should_ignore = ignore_player and (player == v or (v.components.inventoryitem and v.components.inventoryitem:GetGrandOwner() == player))

			if not should_ignore then
				v:LongUpdate(dt)	
			end
			
		end	
	end

	
	doupdate(dt)
	--[[
	local longest_dt = TUNING.SEG_TIME*4
	local num_full_updates = math.floor(dt / longest_dt)
	local leftover_dt = dt - num_full_updates*longest_dt
	print (string.format("Advancing time with %d updates", num_full_updates + (leftover_dt > 0 and 1 or 0)))
	
	
	for k = 1, num_full_updates do
		doupdate(longest_dt)
	end
	if leftover_dt > 0 then
		doupdate(leftover_dt)
	end
	
	scollectgarbage("collect")
--]]
end
