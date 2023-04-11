local FLOCK_SIZE = 9
local SEASON_LIMIT = 60
local SPAWN_INTERVAL = 30
local MIN_SPAWN_DIST = 40
local LAND_CHECK_RADIUS = 6
local WATER_CHECK_RADIUS = 2

if CHEATS_ENABLED then
    FLOCK_SIZE = 2
    SEASON_LIMIT = 600
    SPAWN_INTERVAL = 0
    MIN_SPAWN_DIST = 0
end

local PenguinSpawner = Class(function(self, inst)
	self.inst = inst
    self.colonies = {}       -- existing colonies
    self.maxColonySize = 12
    self.maxPenguins = 50  -- max simultaneous penguins
    self.totalBirds = 0    -- current number of birds alive
    self.flockSize = FLOCK_SIZE
    self.seasonLimit = 0  -- total spawned this season
    self.spacing = 60
    self.checktime = 5
    self.lastSpawnTime = 0
    self.lastSpawnPos = Vector3(0,0,0)
    -- self.badground = {}
    -- self.badpath = {}
    -- self.badclose = {}

	self.inst:DoPeriodicTask(self.checktime, function() self:TryToSpawnFlock() end)

end)

local MAX_DIST_FROM_PLAYER = 12
local MAX_DIST_FROM_WATER = 6

function FindLandNextToWater( playerpos, waterpos )
	--print("FindWalkableOffset:")
    local ignore_walls = true 
    local radius = WATER_CHECK_RADIUS

	local test = function(offset)
		local run_point = waterpos+offset
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)

        -- TODO: Also test for suitability - trees or too many objects
		if tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND then
			return false
		end
		if not ground.Pathfinder:IsClear(playerpos.x, playerpos.y, playerpos.z,
                                         run_point.x, run_point.y, run_point.z,
                                         {ignorewalls = ignore_walls, ignorecreep = true}) then
			return false
        end
        dprint("found valid ground pos",run_point)
		return true
	end
        -- FindValidPositionByFan(start_angle, radius, attempts, test_fn)
		-- returns offset, check_angle, deflected
        local cang = (TheCamera:GetHeading()%360)*DEGREES
	    local loc,landAngle,deflected = FindValidPositionByFan(cang, radius, 4, test)
        if loc then
            dprint("Fan angle=",landAngle)
            return waterpos+loc,landAngle,deflected
        end
end


function PenguinSpawner:FindSpawnLocation()
	local player = GetPlayer()
	local playerPos = Vector3(player.Transform:GetWorldPosition())
    local radius = LAND_CHECK_RADIUS
    local loc,landPos,landAngle,deflected 
    local tmpAng

	local test = function(offset)
		local run_point = playerPos+offset
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
        -- Above ground, this should be water
		if tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND then
	        local loc,ang,def= FindLandNextToWater(playerPos,run_point)
            if loc then
                landPos = loc
                tmpAng = ang
                dprint("true angle",ang,ang/DEGREES)
                return true
            end
        else
			return false
		end
	end

    local cang = (TheCamera:GetHeading()%360)*DEGREES
    dprint("cang:",cang)
	local loc,landAngle,deflected = FindValidPositionByFan(cang, radius, 4, test)
    if loc then
        --dprint("Final findvalid angle=",landAngle,landAngle/DEGREES)
        --return landPos,landAngle,deflected
        dprint("FromWaterToLandAngle",tmpAng,tmpAng/DEGREES)
        return landPos,tmpAng,deflected
    else
        return
    end
end

function PenguinSpawner:Kill()
    for i,v in ipairs(self.colonies) do
        local members = v.members or {}
        for pengu,v in pairs(members) do
            pengu:Remove()
        end
    end
end


function PenguinSpawner:LostPenguin(pengu)
    for i,v in ipairs(self.colonies) do
        local members = v.members or {}
        if members[pengu] then
            -- dprint("|||||||||||||||||||||| Lost pengu:",pengu)
            members[pengu] = nil
            self.totalBirds = self.totalBirds-1
		    self.inst:RemoveEventCallback("death", pengu.deathfn, pengu)
		    self.inst:RemoveEventCallback("onremove", pengu.deathfn, pengu)
            return
        end
    end
end

function PenguinSpawner:AddToColony(colonyNum,pengu)
    local colony = self.colonies[colonyNum]
    if colony then
        dprint(pengu," added to ",colonyNum)
        colony.members = colony.members or {}
        colony.members[pengu] = true
        pengu.colonyNum = colonyNum
        self.totalBirds = self.totalBirds + 1
        self.seasonLimit = self.seasonLimit + 1
        -- NB. Have to create a separate function because
        --     RemoveEventCallback matches the specific function address
        pengu.deathfn = function() self:LostPenguin(pengu) end
        self.inst:ListenForEvent("death", pengu.deathfn, pengu )
        self.inst:ListenForEvent("onremove", pengu.deathfn, pengu )
        pengu.components.knownlocations:RememberLocation("rookery", colony.rookery)
        pengu.components.knownlocations:RememberLocation("home", colony.rookery) -- important for sleep
    end
end

local function SpawnPenguin(inst,spawner,colonyNum,pos,angle)

    -- Try to be on screen for this
    --[[
    if GetPlayer():GetDistanceSqToPoint(pos) > MAX_DIST_FROM_PLAYER*MAX_DIST_FROM_PLAYER then
        return
    end
    --]]

    if spawner.totalBirds >= spawner.maxPenguins or spawner.seasonLimit > SEASON_LIMIT then
        return
    end

    local pengu = SpawnPrefab("penguin")
    if pengu then
        --dprint(TheCamera:GetHeading()," spawnPenguin at",pos,"angle:",angle)

        pengu.Transform:SetPosition(pos.x,pos.y,pos.z)
        pengu.Transform:SetRotation(angle)
        pengu.sg:GoToState("appear")
        spawner:AddToColony(colonyNum,pengu)
    end
end

function PenguinSpawner:SpawnFlock(colonyNum,loc,check_angle)
	local ground = GetWorld()
    local flock = GetRandomWithVariance(self.flockSize,3)
    local spawned = 0
    local i = 0
    local chead = TheCamera:GetHeading()%360
    local pang = check_angle/DEGREES
    global("c_off")
    c_off = c_off or 0
    while spawned < flock and i < flock + 7 do
        local spawnPos = loc + Vector3(GetRandomWithVariance(0,0.5),0.0,GetRandomWithVariance(0,0.5))
        local tile = ground.Map:GetTileAtPoint(spawnPos.x, spawnPos.y, spawnPos.z)
        i = i + 1
        if not (tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND) then
            spawned = spawned + 1
            dprint(TheCamera:GetHeading()%360,"Spawn flock at:",spawnPos,(check_angle/DEGREES),"degrees"," c_off=",c_off)
            dprint("diff =",math.abs(chead-pang))
        --dprint(TheCamera:GetHeading()," spawnPenguin at",pos,"angle:",angle)
            --self.inst:DoTaskInTime(GetRandomWithVariance(3,2), SpawnPenguin, self, colonyNum, spawnPos,(check_angle/DEGREES)-180 )
            --self.inst:DoTaskInTime(GetRandomWithVariance(3,2), SpawnPenguin, self, colonyNum, spawnPos,(check_angle/DEGREES)+c_off)
            self.inst:DoTaskInTime(GetRandomWithVariance(1,1), SpawnPenguin, self, colonyNum, spawnPos,(check_angle/DEGREES)+c_off)
        end
    end
end

local SEARCH_RADIUS = 75
local SEARCH_RADIUS2 = SEARCH_RADIUS*SEARCH_RADIUS

function PenguinSpawner:EstablishColony(loc)

        local radius = SEARCH_RADIUS
        local pos
        local ignore_walls = true
        local check_los = true
        local colonies = self.colonies
        -- local badground= {}
        -- local badpath = {}
        -- local badclose = {}

        local testfn = function(offset)
            local run_point = loc+offset
            local ground = GetWorld()
            local tile = ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
            if tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND then
                --dprint("\tfailed, unwalkable ground.")
                -- badground[#badground+1] = run_point
                return false
            end
            if check_los and not ground.Pathfinder:IsClear(loc.x, loc.y, loc.z,
                                                             run_point.x, run_point.y, run_point.z,
                                                             {ignorewalls = ignore_walls, ignorecreep = true}) then
                -- badpath[#badpath+1] = run_point
                -- dprint("unclear path") 
                return false
            end
            -- Now check that the rookeries are not too close together
            local found = true
            for i,v in ipairs(colonies) do
                local pos = v.rookery
                -- What about penninsula effects? May have a long march
                --dprint("cdist=",math.sqrt(distsq(run_point,pos)),"rookery=",pos,"test=",run_point)
                --dprint("res=",distsq(run_point,pos) < self.spacing*self.spacing)
                if pos and distsq(run_point,pos) < self.spacing*self.spacing then
                    found = false
                end
            end
            -- badclose[#badclose+1] = run_point
            return found
        end

        -- Look for any nearby colonies with enough room
        -- return the colony if you find it
        for i,v in ipairs(self.colonies) do
            --dprint(i,"looking at size:",GetTableSize(v.members),v.rookery,"dist=",math.sqrt(distsq(loc,v.rookery)))
            if GetTableSize(v.members) <= (self.maxColonySize-(FLOCK_SIZE*.8)) then
                pos = v.rookery
                -- What about penninsula effects? May have a long march
                if pos and distsq(loc,pos) < SEARCH_RADIUS2+40 then
                    dprint("************* Found existing colony")
                    return i
                end
            end
        end
        -- Make a new colony
        local newFlock = { members={} }

        radius = SEARCH_RADIUS
        -- Otherwise, find another good spot far enough away from the other colonies
        while not newFlock.rookery and radius>30 do
            -- Starting angle set towards player (to reduce peninsula effects)
			local angle
            -- angle = GetRandomWithVariance(GetPlayer():GetAngleToPoint(loc)-180, 10)
			angle = GetRandomWithVariance(0, PI) -- otherwise will 
            --newFlock.rookery = FindWalkableOffset(loc, angle, radius, 16, true)
            --                  FindValidPositionByFan(start_angle, radius, attempts, test_fn)
	        newFlock.rookery =  FindValidPositionByFan(angle, radius, 16, testfn)
            radius = radius - 20
        end
        if newFlock.rookery then
            newFlock.rookery = newFlock.rookery + loc
        else
            -- dprint("can't find valid position")
            -- dprint("badground=",#badground,"badpath=",#badpath,"badclose=",#badclose)
            -- self.badground = badground
            -- self.badpath = badpath
            -- self.badclose = badclose
            return false
        end

        self.colonies[#self.colonies+1] = newFlock
        return #self.colonies

end

function PenguinSpawner:TryToSpawnFlock()

    if not CHEATS_ENABLED and (not GetSeasonManager():IsWinter() or GetSeasonManager():GetDaysLeftInSeason() <= 3) then
        return
    end

    dprint("Totalbirds=",self.totalBirds,self.maxPenguins)
    dprint("Totalcolonies=",#self.colonies)

    if self.totalBirds >= self.maxPenguins or self.seasonLimit > SEASON_LIMIT then
        dprint("TryToSpawn maxed out")
        return
    end

	local playerPos = Vector3(GetPlayer().Transform:GetWorldPosition())

    if (self.lastSpawnLoc and distsq(self.lastSpawnLoc,playerPos) < MIN_SPAWN_DIST*MIN_SPAWN_DIST) then
        dprint("player position too close")
        return
    end
    if (self.lastSpawnTime and (GetTime() - self.lastSpawnTime) < SPAWN_INTERVAL) then
        dprint("too soon to spawn")
        return
    end

    -- Go find a spot on land close to water
	-- returns offset, check_angle, deflected
	local loc,check_angle,deflected = self:FindSpawnLocation()
    if loc then	

        dprint("trying to spawn: Angle is",check_angle/DEGREES)
        local colony = self:EstablishColony(loc)

        if not colony then
            dprint("can't establish colony")
            return
        end

        self.lastSpawnTime = GetTime()
        self.lastSpawnLoc = loc

        self:SpawnFlock(colony,loc,check_angle)
    end
end

--[[
function PenguinSpawner:BadC()
    dprint("badpath",#self.badclose)
    local pos
    pos = self.lastSpawnTry
    if pos then
        GetPlayer().Transform:SetPosition(pos.x,pos.y,pos.z)
    end
	StartThread( function()
                    for i,v in pairs(self.badclose) do
                        Sleep(1.0)
                        dprint(v)
                        GetPlayer().Transform:SetPosition(v.x,v.y,v.z)
                        Sleep(1.0)
                    end
                    return
                    -- inst:Remove()
                end,
                self.GUID)
end

function PenguinSpawner:BadG(index)
    dprint("badground",#self.badground)
    if self.badground[index] then
        local pos = self.badground[index]
        GetPlayer().Transform:SetPosition(pos.x,pos.y,pos.z)
    end
end
--]]

function PenguinSpawner:OnLoad(data)
    --[[
    global("CHEATS_KEEP_SAVE")
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_USERNAME")

    CHEATS_KEEP_SAVE = true
    CHEATS_ENABLE_DPRINT = true
    DPRINT_USERNAME = "David Forsey"

    dprint("____________ LOADING PSpawner")
    --]]

    self.colonies = self.colonies or {}
    if data.colonies then
        for i,v in ipairs(data.colonies) do
            dprint(i,"+++++++ pos=",v[1],v[2],v[3])
            self.colonies[i] = { rookery = Vector3(v[1],v[2],v[3]), members={} }
        end
    end
end

function PenguinSpawner:OnSave()
	local data = {}
    dprint("________ ON SAVE COLONIES",#self.colonies)
    if #self.colonies >= 1 then
        dprint("START _____________________Colony:")
        data.colonies = {}
        for i,v in ipairs(self.colonies) do
            data.colonies[i] = {v.rookery.x,v.rookery.y,v.rookery.z}
            dprint("_____________________Colony:",i," PSpawner OnSave:",v.rookery)
        end
    else
        dprint("__NO COLONIES")
    end
	return data
end

function PenguinSpawner:LongUpdate(dt)
end

return PenguinSpawner

