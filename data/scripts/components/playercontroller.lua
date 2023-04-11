require "class"
require "screens/pausescreen"
local easing = require "easing"

local trace = function() end

local CLICK_WALK_TIME = .5

local CameraRight = TheCamera:GetRightVec()
local CameraDown = TheCamera:GetDownVec()

local function UpdateCameraHeadings()
	CameraRight = TheCamera:GetRightVec()
	CameraDown = TheCamera:GetDownVec()
end

local PlayerController = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    
    
    self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_LEFT, true, function() self:OnLeftClick() end))
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_LEFT, false, function() self:OnLeftUp() end))
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_RIGHT, true, function() self:OnRightClick() end))

    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_SPACE, function() self:OnPressAction() end))
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_LEFT, function() self:RotLeft() end))
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_RIGHT, function() self:RotRight() end))
    
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_Q, function() self:RotLeft() end))
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_E, function() self:RotRight() end))

    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_P, function() if TheInput:IsKeyDown(KEY_CTRL) then TheCamera:SetPaused(not TheCamera.paused) end end))
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_H, function() 
		if TheInput:IsKeyDown(KEY_CTRL) then
			if self.inst.HUD.shown then 
				self.inst.HUD:Hide() 
			else 
				self.inst.HUD:Show() 
			end 
		end
	end))
    
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_UP, function() if not IsHUDPaused() and TheCamera:CanControl() then TheCamera:ZoomIn() end end))
    table.insert(self.inputhandlers, TheInput:AddKeyDownHandler(KEY_DOWN, function() if not IsHUDPaused() and TheCamera:CanControl() then TheCamera:ZoomOut() end end))

    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_SCROLLUP, true, function() if not IsHUDPaused() and TheCamera:CanControl() then TheCamera:ZoomIn() end end))
    table.insert(self.inputhandlers, TheInput:AddMouseButtonHandler(MOUSEBUTTON_SCROLLDOWN, true, function() if not IsHUDPaused() and TheCamera:CanControl() then TheCamera:ZoomOut() end end))


	self.inst:ListenForEvent( "death", function() TheInput:EnableMouseovers() end)
    self.inst:StartUpdatingComponent(self)
    self.draggingonground = false
    self.startdragtestpos = nil
    self.startdragtime = nil
end)

function PlayerController:RotLeft()
	local rotamount = GetWorld():IsCave() and 22.5 or 45
	if TheCamera:CanControl() then  
		
		if IsHUDPaused() then
			if GetPlayer().HUD:IsMapShowing() then
				TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
				TheCamera:Snap()
			end
		else
			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount) 
			UpdateCameraHeadings() 
		end
	end
end

function PlayerController:RotRight()
	local rotamount = GetWorld():IsCave() and 22.5 or 45
	if TheCamera:CanControl() then  
		
		if IsHUDPaused() then
			if GetPlayer().HUD:IsMapShowing() then
				TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
				TheCamera:Snap()
			end
		else
			TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount) 
			UpdateCameraHeadings() 
		end
	end
end

function PlayerController:OnRemoveEntity()
    for k,v in pairs(self.inputhandlers) do
        v:Remove()
    end
end


function PlayerController:GetHoverTextOverride()
	if self.placer_recipe then
		return STRINGS.UI.HUD.BUILD.. " " .. ( STRINGS.NAMES[string.upper(self.placer_recipe.name)] or STRINGS.UI.HUD.HERE )
	end
end

function PlayerController:CancelPlacement()
	if self.placer then
		self.placer:Remove()
		self.placer = nil
	end
	self.placer_recipe = nil
end


function PlayerController:StartBuildPlacementMode(recipe, testfn)
	self.placer_recipe = recipe
	if self.placer then
		self.placer:Remove()
		self.placer = nil
	end
	self.placer = SpawnPrefab(recipe.placer)
	self.placer.components.placer:SetBuilder(self.inst)
	self.placer.components.placer.testfn = testfn
end


function PlayerController:Enable(val)
    self.enabled = val
end


function PlayerController:GetAttackTarget()

	local x,y,z = self.inst.Transform:GetWorldPosition()
	local force_attack = TheInput:IsKeyDown(KEY_CTRL)
	local rad = force_attack and 8 or 6 
	local nearby_ents = TheSim:FindEntities(x,y,z, rad)
	local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local has_weapon = tool and tool.components.weapon 
	
	for k,guy in ipairs(nearby_ents) do
		
		if guy ~= self.inst and
		   guy:IsValid() and 
		   not guy:IsInLimbo() and
		   not (guy.sg and guy.sg:HasStateTag("invisible")) and
		   guy.components.health and not guy.components.health:IsDead() and 
		   guy.components.combat and guy.components.combat:CanBeAttacked(self.inst) and
		   not (guy.components.follower and guy.components.follower.leader == self.inst) then
				if (guy:HasTag("monster") and has_weapon) or
					guy.components.combat.target == self.inst or
					force_attack then
						return guy
				end
						
		end
	end

end


--

function PlayerController:OnPressAction()

	if self.actionbuttonoverride then
		self.actionbuttonoverride(self.inst)
		return
	end

	if self.enabled and not (self.inst.sg:HasStateTag("working") or self.inst.sg:HasStateTag("doing")) then

		local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		--bug catching (has to go before combat)
		local force_attack = TheInput:IsKeyDown(KEY_CTRL)
		if tool and tool.components.tool and tool.components.tool:CanDoAction(ACTIONS.NET) and not force_attack then
			local target = FindEntity(self.inst, 5, 
				function(guy) 
					return  guy.components.health and not guy.components.health:IsDead() and 
							guy.components.workable and
							guy.components.workable.action == ACTIONS.NET
				end)
			if target then
			    local action = BufferedAction(self.inst, target, ACTIONS.NET, tool)
				self.inst.components.locomotor:PushAction(action, true)
				return
			end
		end
			
		local attack_target = self:GetAttackTarget() 			
		if attack_target then
			if self.inst.components.combat.target ~= attack_target or self.inst.sg:HasStateTag("idle") then
				local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
				self.inst.components.locomotor:PushAction(action, true)
			end
			return
		end
		 
		--catching
		local rad = 8
		local projectile = FindEntity(self.inst, rad, function(guy)
		    return guy.components.projectile
		           and guy.components.projectile:IsThrown()
		           and self.inst.components.catcher
		           and self.inst.components.catcher:CanCatch()
		end)
		if projectile then
			self.inst.components.locomotor:PushAction(BufferedAction(self.inst, projectile, ACTIONS.CATCH), true)
			return
		end
		
		rad = 6
		--pickup
		local pickup = FindEntity(self.inst, rad, function(guy) return (guy.components.inventoryitem and guy.components.inventoryitem.canbepickedup) or
																		(tool and tool.components.tool and guy.components.workable and tool.components.tool:CanDoAction(guy.components.workable.action)) or
																		(guy.components.pickable and guy.components.pickable:CanBePicked() and guy.components.pickable.caninteractwith) or
																		(guy.components.crop and guy.components.crop:IsReadyForHarvest()) or
																		(guy.components.harvestable and guy.components.harvestable:CanBeHarvested()) or
																		(guy.components.trap and guy.components.trap.issprung) or
																		(guy.components.stewer and guy.components.stewer.done) or
																		(guy.components.activatable and guy.components.activatable.inactive)
																		 end)

		local has_active_item = self.inst.components.inventory:GetActiveItem() ~= nil
		if pickup and not has_active_item then
			local action = nil
			
			if (tool and tool.components.tool and pickup.components.workable and tool.components.tool:CanDoAction(pickup.components.workable.action)) then
				action = pickup.components.workable.action
			elseif pickup.components.trap and pickup.components.trap.issprung then
				action = ACTIONS.CHECKTRAP
			elseif pickup.components.activatable and pickup.components.activatable.inactive then
				action = ACTIONS.ACTIVATE
			elseif pickup.components.inventoryitem and pickup.components.inventoryitem.canbepickedup then 
				action = ACTIONS.PICKUP 
			elseif pickup.components.pickable and pickup.components.pickable:CanBePicked() then 
				action = ACTIONS.PICK 
			elseif pickup.components.harvestable and pickup.components.harvestable:CanBeHarvested() then
				action = ACTIONS.HARVEST
			end
			
			if action then
			    self.inst.components.locomotor:PushAction(BufferedAction(self.inst, pickup, action, tool), true)
			end
			return
		end
	end
end



function PlayerController:OnUpdate(dt)
    if not self.enabled then 
		TheInput:EnableMouseovers()
		return 
    end  

	local active_item = self.inst.components.inventory:GetActiveItem()
	
	
	local action = self.inst.components.playeractionpicker:GetLeftMouseAction()	
	local action_r = self.inst.components.playeractionpicker:GetRightMouseAction()	
	
	local terraform_l =	(action and action.action == ACTIONS.TERRAFORM and action.pos and action.invobject)
	local terraform_r =	(action_r and action_r.action == ACTIONS.TERRAFORM and action_r.pos and action_r.invobject)
	local terraform = terraform_l or terraform_r
	
	if terraform then
		if not self.terraformplacer then
			local act = terraform_l and action or action_r
			self.terraformplacer = SpawnPrefab("gridplacer")
			self.terraformplacer.components.placer:SetBuilder(self.inst)
			self.terraformplacer.components.placer.testfn = function(pt) 
				return act.invobject.components.terraformer:CanTerraformPoint(pt) 
			end 
			
		end
	else
		if self.terraformplacer then
			self.terraformplacer:Remove()
			self.terraformplacer = nil
		end
	end
	
	local show_deploy_placer = active_item and active_item.components.deployable and ((action and action.action == ACTIONS.DEPLOY) or (action_r and action_r.action == ACTIONS.DEPLOY))
	
	if show_deploy_placer then
		local placer_name = active_item.components.deployable.placer or ((active_item.prefab or "") .. "_placer")
		if self.deployplacer and self.deployplacer.prefab ~= placer_name then
			self.deployplacer:Remove()
			self.deployplacer = nil
		end
		
		if not self.deployplacer then
			self.deployplacer = SpawnPrefab(placer_name)
			if self.deployplacer then
				self.deployplacer.components.placer:SetBuilder(self.inst)
				self.deployplacer.components.placer.testfn = function(pt) 
						local action = self.inst.components.playeractionpicker:GetLeftMouseAction()
						local action_r = self.inst.components.playeractionpicker:GetRightMouseAction()
						return (action and action.action == ACTIONS.DEPLOY and action.invobject and action.invobject.components.deployable and action.invobject.components.deployable:CanDeploy(pt)) or
							   (action_r and action_r.action == ACTIONS.DEPLOY and action_r.invobject and action_r.invobject.components.deployable and action_r.invobject.components.deployable:CanDeploy(pt))
						
					end
				self.deployplacer.components.placer:OnUpdate(0)  --so that our position is accurate on the first frame
			end
		end
	else
		if self.deployplacer then
			self.deployplacer:Remove()
			self.deployplacer = nil
		end
	end
	    
    --if self.placer_recipe then return end

    -- if self.startdragtestpos and not self.draggingonground then
    --     local pt = TheInput:GetMouseWorldPos()
    --     if distsq(pt, self.startdragtestpos) > 1.5*1.5 then
    --         self.draggingonground = true
    --     end
    -- end
    
    if self.startdragtime and not self.draggingonground then
        local now = GetTime()
        if now - self.startdragtime > CLICK_WALK_TIME then
            self.draggingonground = true
        end
    end

	if not self.inst.sg:HasStateTag("busy") then
		if self.startdragtime then
			local pt = TheInput:GetMouseWorldPos()
			local dst = distsq(pt, Vector3(self.inst.Transform:GetWorldPosition()))
			if dst > 1 then
				local angle = self.inst:GetAngleToPoint(pt)
				--self.inst.components.locomotor:GoToPoint(pt, nil, true)
				self.inst.components.locomotor:RunInDirection(angle)
				self.inst:ClearBufferedAction()
				TheInput:DisableMouseovers()            
			end
			self.directwalking = false
		else
	        
			--WASD walking!
			local xwalk = 0
			local ywalk = 0
			if TheInput:IsKeyDown(KEY_W) then
				ywalk = ywalk + 1
			end

			if TheInput:IsKeyDown(KEY_S) then
				ywalk = ywalk - 1
			end

			if TheInput:IsKeyDown(KEY_A) then
				xwalk = xwalk - 1
			end
	        
			if TheInput:IsKeyDown(KEY_D) then
				xwalk = xwalk + 1
			end

			if not 	TheInput:IsKeyDown(KEY_W) and not --We only want to update headings if no keys are pressed.
					TheInput:IsKeyDown(KEY_A) and not
					TheInput:IsKeyDown(KEY_S) and not
					TheInput:IsKeyDown(KEY_D) then

					
					CameraRight = TheCamera:GetRightVec()
					CameraDown = TheCamera:GetDownVec()
			end
	        
			if xwalk ~= 0 or ywalk ~= 0 then
				--self.inst.components.inventory:DropActiveItem()

				local dir = CameraRight * xwalk - CameraDown * ywalk
				dir = dir:GetNormalized()
				--local pt = Vector3(self.inst.Transform:GetWorldPosition()) + dir
				--self.inst.components.locomotor:GoToPoint(pt, nil, true)
				local ang = -math.atan2(dir.z, dir.x)/DEGREES
				self.inst.components.locomotor:WalkInDirection(ang, true)
				self.directwalking = true
				self.inst.components.locomotor:SetBufferedAction(nil)
				self.inst:ClearBufferedAction()
				
				if not self.inst.sg:HasStateTag("attack") then
					self.inst.components.combat:SetTarget(nil)
				end
			else
				if self.directwalking then
					self.inst.components.locomotor:Stop()
					self.directwalking = false
				end
			end
		end
    end
    
end


function PlayerController:OnLeftUp()
    
	Print(VERBOSITY.DEBUG, "OnLeftUp")

	local walk_key_down = TheInput:IsKeyDown(KEY_W) or TheInput:IsKeyDown(KEY_A) or TheInput:IsKeyDown(KEY_S) or TheInput:IsKeyDown(KEY_D)

    if not self.enabled then return end    
    
    if not self.ignore_left_up and not TheInput:GetHUDEntityUnderMouse() then 
        if self.inst.components.inventory:GetActiveItem() then
            self:DoAction()
        else
			self.directwalking = false
   			if self.draggingonground then
				Print(VERBOSITY.DEBUG, "    stopping")
				if not walk_key_down then
					self.inst.components.locomotor:Stop()
				end
			elseif self.startdragtime then
   				Print(VERBOSITY.DEBUG, "    not dragging")
				local pt = TheInput:GetMouseWorldPos()
				local dst = distsq(pt, Vector3(self.inst.Transform:GetWorldPosition()))
				if dst > 1 then
					Print(VERBOSITY.DEBUG, "    ending with pathfind")
					--local angle = self.inst:GetAngleToPoint(pt)
					self.inst.components.locomotor:GoToPoint(pt, nil, true)
					--self.inst.components.locomotor:RunInDirection(angle)
					self.inst:ClearBufferedAction()
					--TheInput:DisableMouseovers()
				else
					Print(VERBOSITY.DEBUG, "    stopping")
					self.inst.components.locomotor:Stop()
				end
			 --    local action = BufferedAction(self.inst, target, ACTIONS.WALKTO)
				-- self.inst:ClearBufferedAction()
				-- self.inst.components.locomotor:PushAction(action, true)

			end
        end
    end

    self.ignore_left_up = false
    self.draggingonground = false
    self.startdragtestpos = nil
    self.startdragtime = nil
    TheInput:EnableMouseovers()
end



function PlayerController:DoAction(buffaction)
	Print(VERBOSITY.DEBUG, "PlayerController:DoAction")
    if buffaction then
    
        if self.inst.bufferedaction then
            if self.inst.bufferedaction.action == buffaction.action and self.inst.bufferedaction.target == buffaction.target then
                return;
            end
        end
        
        if buffaction.target and buffaction.target.components.highlight then
            buffaction.target.components.highlight:Flash(.2, .125, .1)
        end
		
		Print(VERBOSITY.DEBUG, "Performing Action: ["..buffaction.action.id.."]")
        if  buffaction.invobject and 
            buffaction.invobject.components.equippable and 
            buffaction.invobject.components.equippable.equipslot == EQUIPSLOTS.HANDS and 
            (buffaction.action ~= ACTIONS.DROP and buffaction.action ~= ACTIONS.STORE) then
            
                if not buffaction.invobject.components.equippable.isequipped then 
                    self.inst.components.inventory:Equip(buffaction.invobject)
                end
                
                if self.inst.components.inventory:GetActiveItem() == buffaction.invobject then
                    self.inst.components.inventory:SetActiveItem(nil)
                end
        end
        
        self.inst.components.locomotor:PushAction(buffaction, true)
    end    

end


function PlayerController:OnLeftClick()
    
    self.startdragtime = nil

    if not self.enabled then return end
    
    if TheInput:GetHUDEntityUnderMouse() then 
		self:CancelPlacement()
		return 
    end

	if self.placer_recipe then
		--do the placement
		if self.placer.components.placer.can_build then
			self.inst.components.builder:MakeRecipe(self.placer_recipe, TheInput:GetMouseWorldPos())
			self:CancelPlacement()
		end
		return
	end
    
    if self.inst.components.inventory:GetActiveItem() then
        self.ignore_left_up = true
    end
    
    self.inst.components.combat.target = nil
    
    if self.inst.inbed then
        self.inst.inbed.components.bed:StopSleeping()
        return
    end
    
    local action = self.inst.components.playeractionpicker:GetLeftMouseAction()
    if action then
	    self:DoAction( action )
	else
	    local clicked = TheInput:GetWorldEntityUnderMouse()
	    if not clicked then
	        self.startdragtime = GetTime()
	    end
    end
    
end


function PlayerController:OnRightClick()

    self.startdragtime = nil

	if self.placer_recipe then 
		self:CancelPlacement()
	end

    if not self.enabled then return end
    
    if TheInput:GetHUDEntityUnderMouse() then return end

    if not self.inst.components.playeractionpicker:GetRightMouseAction() then
        self.inst.components.inventory:ReturnActiveItem()
    end
    
    if self.inst.inbed then
        self.inst.inbed.components.bed:StopSleeping()
        return
    end
    
    local action = self.inst.components.playeractionpicker:GetRightMouseAction()
    if action then
		self:DoAction(action )
	end
		
    
end

function PlayerController:ShakeCamera(inst, shakeType, duration, speed, maxShake, maxDist)
    local distSq = self.inst:GetDistanceSqToInst(inst)
    local t = math.max(0, math.min(1, distSq / (maxDist*maxDist) ) )
    local scale = easing.outQuad(t, maxShake, -maxShake, 1)
    if scale > 0 then
        TheCamera:Shake(shakeType, duration, speed, scale)
    end
end

return PlayerController
