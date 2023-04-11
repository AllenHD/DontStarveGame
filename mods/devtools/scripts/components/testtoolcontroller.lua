require("class")
require("map/map")

function AddTestToolController()
	local player = TheSim:FindFirstEntityWithTag("player")
	if not player.components.testtoolcontroller then
		player:AddComponent("testtoolcontroller")
	end
end

local function SpawnPrefabAtPoint(prefab, point)
	if not prefab or not point then
		return
	end

	local inst = SpawnPrefab(prefab)
	if inst then
		if inst.Physics then
			print("teleporting..")
			print("inst: ", inst)
			inst.Physics:Teleport(point:Get())
			if prefab == "smallbird" then
				inst.sg:GoToState("hatch")
			elseif prefab == "mandrake" then
                if TheGlobalInstance.components.clock:IsDay() then
                    inst.sg:GoToState("death")
                else
	                inst.userfunctions.MakeFollower(inst)
                    inst.sg:GoToState("idle")
                end
			end
		elseif inst.Transform then
			inst.Transform:SetPosition(point:Get())
		end
	end
end

local function SpawnPrefabInInv(prefab, inst)
	if not prefab then
		return
	end

	local item = SpawnPrefab(prefab)
	inst.components.inventory:GiveItem(item)
end

local function IsValidTile(point)
	local ground = TheSim:FindFirstEntityWithTag("ground")
	
	if ground and point then
		local tile = ground.Map:GetTileAtPoint(point.x, point.y, point.z)
		if tile ~= GROUND.IMPASSIBLE then
			return true
		end
	end	

	return false
end

local TestToolController = Class(function(self, inst)

  self.entityPrefab = nil
  self.itemPrefab = nil
  self.foodPrefab = nil
  self.objectPrefab = nil
  
  self.speed_multiplier = nil
  
  self.bookmarked_point = nil
  
  self.inst = inst
  self.enabled = true
  
  self.inputhandlers = {}
  
  -- God mode
  table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_G, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		if self.inst.components.health:IsInvincible() then
			self.inst.components.health:SetInvincible(false)
		else
			self.inst.components.health:SetInvincible(true)
		end
    end
  end))
	-- Entity
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_Z, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		local pt = Vector3(self.inst.Transform:GetWorldPosition())
		SpawnPrefabAtPoint(self.entityPrefab, pt)
	elseif TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = Vector3(TheInput:GetMouseWorldPos())
		SpawnPrefabAtPoint(self.entityPrefab, pt:Get())
	end
  end))
	-- Item
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_X, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		SpawnPrefabInInv(self.itemPrefab, self.inst)
	elseif TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = Vector3(TheInput:GetMouseWorldPos())
		SpawnPrefabAtPoint(self.itemPrefab, pt:Get())
	end
  end))
	-- Freebuild
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_C, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		if self.inst.components.builder.freebuildmode then
			self.inst.components.builder.freebuildmode = false
		else
			self.inst.components.builder.freebuildmode = true
		end

		self.inst:PushEvent("techlevelchange")
    end
  end))
	-- Run speed
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_R, function()
		----- delete
  end))
	-- Time scale
  	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_V, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		local timescaleIsIncreased = TheSim:GetTimeScale() > 1
		if timescaleIsIncreased then
			TheSim:SetTimeScale(1)
		else
			TheSim:SetTimeScale(500)
		end
    end
  end))
	-- Next day
  	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_F, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
		TheGlobalInstance.components.clock:MakeNextDay()
    end
  end))
	-- Next phase
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_G, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
		TheGlobalInstance.components.clock:NextPhase()
    end
	end))
	-- Food
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_T, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		SpawnPrefabInInv(self.foodPrefab, self.inst)
	elseif TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = Vector3(TheInput:GetMouseWorldPos())
		SpawnPrefabAtPoint(self.foodPrefab, pt:Get())
	end
  end)) 

  	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_R, function()
	-- Run speed
	if TheInput:IsKeyDown(KEY_CTRL) then
		local default_runspeed = TUNING.WILSON_RUN_SPEED
		if self.inst.components.locomotor.runspeed > default_runspeed then
			self.inst.components.locomotor.runspeed = default_runspeed
		else
			self.inst.components.locomotor.runspeed = default_runspeed * (self.speed_multiplier or 3)
		end
	-- Object
	elseif TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = Vector3(TheInput:GetMouseWorldPos())
		SpawnPrefabAtPoint(self.objectPrefab, pt:Get())
	-- Map reveal
	elseif TheInput:IsKeyDown(KEY_ALT) then
	
		local ground = TheSim:FindFirstEntityWithTag("ground")
		local width, height = ground.Map:GetSize()
	
		for i = 1, width - 1, 1 do
			for j = 1, height - 1, 1 do
				ground.Map:VisitTile(i, j)
			end
		end	
    end
  end))
	-- Map hide
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_T, function()
    if TheInput:IsKeyDown(KEY_ALT) then
		local ground = TheSim:FindFirstEntityWithTag("ground")
		ground.Map:ResetVisited()
    end
  end))
	-- Teleport player
	table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_LEFT, true, function()
		-- To mouse position
	if TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = TheInput:GetMouseWorldPos()
		
		if IsValidTile(pt) then
			self.inst.Physics:Teleport(pt.x, pt.y, pt.z)
		end
		-- To bookmarked point
	elseif  TheInput:IsKeyDown(KEY_ALT) then
		local pt = self.bookmarked_point
		if IsValidTile(pt) then
			self.inst.Physics:Teleport(pt.x, pt.y, pt.z)
		end	
	end
	end))
	-- Bookmark point
	table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_RIGHT, true, function()
	if TheInput:IsKeyDown(KEY_ALT) then
		self.bookmarked_point = Vector3(self.inst.Transform:GetWorldPosition())
	end
	end))	
	-- Delete
	table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_B, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then		
		local target = TheInput:GetWorldEntityUnderMouse()
		
		if target and not target:HasTag("player") then
			target:Remove()
		end		
    end
  end))
  
  self.inst:StartUpdatingComponent(self)
  
end)

return TestToolController


