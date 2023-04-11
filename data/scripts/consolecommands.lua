

local function Spawn(prefab)
    TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Console Functions -- These are simple helpers made to be typed at the console.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

-- Spawn At Cursor and select the new ent
-- Has a gimpy short name so it's easier to type from the console
function c_spawn(prefab, count)
	count = count or 1
	local inst = nil
	for i=1,count do
		inst = Spawn(prefab)
		inst.Transform:SetPosition(TheInput:GetMouseWorldPos():Get())
	end
	SetDebugEntity(inst)
	return inst
end

-- Get the currently selected entity, so it can be modified etc.
-- Has a gimpy short name so it's easier to type from the console
function c_sel()
	return GetDebugEntity()
end

function c_select(inst)
	return SetDebugEntity(inst)
end

-- Print the (visual) tile under the cursor
function c_tile()
	local s = ""

	local ground = GetWorld()
	local mx, my, mz = TheInput:GetMouseWorldPos():Get()
	local tx, ty = ground.Map:GetTileCoordsAtPoint(mx,my,mz)
	s = s..string.format("world[%f,%f,%f] tile[%d,%d] ", mx,my,mz, tx,ty)

	local tile = ground.Map:GetTileAtPoint(TheInput:GetMouseWorldPos():Get())
	for k,v in pairs(GROUND) do
		if v == tile then
			s = s..string.format("ground[%s] ", k)
			break
		end
	end

	print(s)
end

-- Apply a scenario script to the selection and run it.
function c_doscenario(scenario)
	local inst = GetDebugEntity()
	if not inst then
		print("Need to select an entity to apply the scenario to.")
		return
	end
	if inst.components.scenariorunner then
		inst.components.scenariorunner:ClearScenario()
	end

	-- force reload the script -- this is for testing after all!
	package.loaded["scenarios/"..scenario] = nil

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript(scenario)
	inst.components.scenariorunner:Run()
end


-- Some helper shortcut functions
function c_season() return GetWorld().components.seasonmanager end
function c_sel_health()
	if c_sel() then
		local health = c_sel().components.health
		if health then
			return health
		else
			print("Gah! Selection doesn't have a health component!")
			return
		end
	else
		print("Gah! Need to select something to access it's components!")
	end
end

function c_sethealth(n)
	GetPlayer().components.health:SetPercent(n)
end
function c_setsanity(n)
	GetPlayer().components.sanity:SetPercent(n)
end
function c_sethunger(n)
	GetPlayer().components.hunger:SetPercent(n)
end


-- Put an item(s) in the player's inventory
function c_give(prefab, count)
	count = count or 1

    local MainCharacter = GetPlayer()
    
	if MainCharacter then
		for i=1,count do
			local inst = Spawn(prefab)
			if inst then
				MainCharacter.components.inventory:GiveItem(inst)
			end
		end
	end
end

function c_pos(inst)
	return inst and Point(inst.Transform:GetWorldPosition())
end

function c_printpos(inst)
	print(c_pos(inst))
end

function c_teleport(x, y, z, inst)
	inst = inst or GetPlayer()
	inst.Transform:SetPosition(x, y, z)
end

function c_goto(dest, inst)
	inst = inst or GetPlayer()
	inst.Transform:SetPosition(dest.Transform:GetWorldPosition())
end

function c_inst(guid)
	return Ents[guid]
end

function c_list(prefab)
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001)
    for k,v in pairs(ents) do
    	if v.prefab == prefab then
	    	print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
    	end
    end
end

function c_listtag(tag)
    local tags = {tag}
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001, tags)
    for k,v in pairs(ents) do
    	print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
    end
end

local lastfound = -1
function c_findnext(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

    local trans = inst.Transform
    local found = nil
	local foundlowestid = nil
	local reallowest = nil
	local reallowestid = nil

	print("Finding a ",prefab)

    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
        	print(v.GUID,lastfound,foundlowestid )
			if v.GUID > lastfound and (foundlowestid == nil or v.GUID < foundlowestid) then
				found = v
				foundlowestid = v.GUID
			end
			if not reallowestid or v.GUID < reallowestid then
				reallowest = v
				reallowestid = v.GUID
			end
        end
    end
	if not found then
		found = reallowest
	end
	lastfound = found.GUID
    return found
end

local godmode = false
function c_godmode()
	godmode = not godmode
	GetPlayer().components.health:SetInvincible(godmode)
	print("God mode: ",godmode) 
end

function c_find(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

    local trans = inst.Transform
    local found = nil
    local founddistsq = nil

    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
            if not founddistsq or inst:GetDistanceSqToInst(v) < founddistsq then 
                found = v
                founddistsq = inst:GetDistanceSqToInst(v)
            end
        end
    end
    return found
end

function c_findtag(tag, radius, inst)
	return GetClosestInstWithTag(tag, inst or GetPlayer(), radius or 1000)
end

function c_gonext(name)
	c_goto(c_findnext(name))
end

function c_printtextureinfo( filename )
	TheSim:PrintTextureInfo( filename )
end