local PlayerActionPicker = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.LMBaction = nil
    self.RMBaction = nil
end)

function PlayerActionPicker:SortActionList(actions, target, useitem)
    if #actions > 0 then
        table.sort(actions, function(l, r) return l.priority > r.priority end)
        local ret = {}
        for k,v in ipairs(actions) do
            if not target then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem))
            elseif target:is_a(EntityScript) then
                table.insert(ret, BufferedAction(self.inst, target, v, useitem))
            elseif target:is_a(Vector3) then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem, target))
            end
        end
        return ret
    end
end

function PlayerActionPicker:GetSceneActions(targetobject, right)
    local actions = {}

    for k,v in pairs(targetobject.components) do
        if v.CollectSceneActions then
            v:CollectSceneActions(self.inst, actions, right)
        end
    end

	if targetobject.inherentsceneaction then
		table.insert(actions, targetobject.inherentsceneaction)
	end

    if #actions == 0 and targetobject.components.inspectable then
        table.insert(actions, ACTIONS.WALKTO)
    end

    return self:SortActionList(actions, targetobject)
end


function PlayerActionPicker:GetUseItemActions(target, useitem, right)
    local actions = {}

    
    for k,v in pairs(useitem.components) do
        if v.CollectUseActions and target:is_a(EntityScript) then
            v:CollectUseActions(self.inst, target, actions, right)
        end
        
    end

    return self:SortActionList(actions, target, useitem)
end

function PlayerActionPicker:GetPointActions(pos, useitem, right)
    local actions = {}
	local sorted_acts = nil
    if useitem then
		for k,v in pairs(useitem.components) do
			if v.CollectPointActions then
				v:CollectPointActions(self.inst, pos, actions, right)
			end
		end
		sorted_acts = self:SortActionList(actions, pos, useitem)
	end
	
	if sorted_acts then
		for k,v in pairs(sorted_acts) do
	        if v.action == ACTIONS.DROP then
				v.options.wholestack = not TheInput:IsKeyDown(KEY_CTRL)
			end
		end
	end
        
    return sorted_acts
end


function PlayerActionPicker:GetEquippedItemActions(target, useitem, right)
    local actions = {}

    for k,v in pairs(useitem.components) do
        if v.CollectEquippedActions then
            v:CollectEquippedActions(self.inst, target, actions, right)
        end
    end

    return self:SortActionList(actions, target, useitem)
end


function PlayerActionPicker:GetInventoryActions(useitem, right)
    if useitem then
        local actions = {}

        for k,v in pairs(useitem.components) do
            if v.CollectInventoryActions then
                v:CollectInventoryActions(self.inst, actions, right)
            end
        end
        
        local acts = self:SortActionList(actions, nil, useitem)
        if acts ~= nil then
            for k,v in pairs(acts) do
                if v.action == ACTIONS.DROP then
                    v.options.wholestack = not TheInput:IsKeyDown(KEY_CTRL)
                end
            end
        end
        
        return acts
    end
end

function PlayerActionPicker:ShouldForceInspect()
    return TheInput:IsKeyDown(KEY_SHIFT)
end

function PlayerActionPicker:ShouldForceAttack()
    return TheInput:IsKeyDown(KEY_CTRL)
end

function PlayerActionPicker:GetClickActions( target_ent, position )

    if self.leftclickoverride then
        return self.leftclickoverride(self.inst, target_ent, position)
    end
    

    local actions = nil
    local useitem = self.inst.components.inventory:GetActiveItem()
    local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    
    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem and useitem:IsValid() then

        if target_ent == self.inst then
            actions = self:GetInventoryActions(useitem, false)
        end

		--print ("!", self:ShouldForceDrop() , target_ent == nil , useitem.components.inventoryitem , useitem.components.inventoryitem.owner == self.inst)
        if not actions then
            if target_ent then
                actions = self:GetUseItemActions(target_ent, useitem)
            elseif passable then
                actions = self:GetPointActions(position, useitem)
            end
        end
    elseif target_ent then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it

        if self:ShouldForceInspect() and target_ent.components.inspectable then
            actions = self:SortActionList({ACTIONS.LOOKAT}, target_ent, nil)
        elseif self:ShouldForceAttack() and self.inst.components.combat:CanTarget(target_ent) then
            actions = self:SortActionList({ACTIONS.ATTACK}, target_ent, nil)
        elseif equipitem and equipitem:IsValid() then
            actions = self:GetEquippedItemActions(target_ent, equipitem)
        end
        
        if actions == nil or #actions == 0 then
			actions = self:GetSceneActions(target_ent)
        end
    end
    
    
    if not actions and position and not target_ent and passable then
    
		--can we use our equipped item at the point?
		if equipitem and equipitem:IsValid() then
			actions = self:GetPointActions(position, equipitem)
            --this is to make it so you don't auto-drop equipped items when you left click the ground. kinda ugly.
            if actions then
                for k,v in ipairs(actions) do
				    if v.action == ACTIONS.DROP then
					    table.remove(actions, k)
					    break
				    end
                end
            end
		end
		
		--if we're pointing at open ground, walk
		if not actions or #actions == 0 then
			--actions = { BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, position) }
		end
    end

    
    return actions or {}

end

function PlayerActionPicker:GetRightClickActions( target_ent, position )
    
    if self.rightclickoverride then
        return self.rightclickoverride(self.inst, target_ent, position)
    end

    local actions = nil
    local useitem = self.inst.components.inventory:GetActiveItem()
    local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    
    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem and useitem:IsValid() then

        if target_ent == self.inst then
            actions = self:GetInventoryActions(useitem, true)
        end

        if not actions then
            if target_ent then
                actions = self:GetUseItemActions(target_ent, useitem, true)
            elseif passable then
                actions = self:GetPointActions(position, useitem, true)
            end
        end
    elseif target_ent then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it

        if equipitem and equipitem:IsValid() then
            actions = self:GetEquippedItemActions(target_ent, equipitem, true)
        end

        if not actions then
            actions = self:GetSceneActions(target_ent, true)
        end
    end
    
    
    if not actions and position and not target_ent and passable and equipitem and equipitem:IsValid() then
		actions = self:GetPointActions(position, equipitem, true)
	end
    
    
    return actions or {}
end

function PlayerActionPicker:DoGetMouseActions( )
    
    local highlightdude = nil
    local action = nil
    local second_action = nil
    
    --if true then return end
    local hud = TheInput:GetHUDEntityUnderMouse()
    if not hud then
    
        local target = nil
        local ents = TheInput:GetAllEntitiesUnderMouse()
        
        
        --this should probably eventually turn into a system whereby we calculate actions for ALL of the possible items and then rank them. Until then, just apply a couple of special cases...
        local useitem = self.inst.components.inventory:GetActiveItem()
        
        --this is fugly
        local ignore_player = true
        if useitem then
			if (useitem.components.equippable and not useitem.components.equippable.isequipped )
			   or useitem.components.edible
			   or useitem.components.shaver
			   or useitem.components.instrument
			   or useitem.components.healer
			   or useitem.components.sleepingbag then
			    ignore_player = false
			end
		end
		
		if self.inst.components.catcher and self.inst.components.catcher:CanCatch() then
			ignore_player = false
		end
        
        for k,v in pairs(ents) do
            if not ignore_player or not v:HasTag("player") and v.Transform then
                target = v
                break
            end
        end
        
        local position = TheInput:GetMouseWorldPos()
        if (target and target:IsValid() and target.Transform and (target:HasTag("player") or TheSim:GetLightAtPoint(target.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF)) or TheSim:GetLightAtPoint(position.x,position.y,position.z) > TUNING.DARK_CUTOFF then
            local acts = self:GetClickActions(target, position)
            if acts and #acts > 0 then
            
                if self.inst.components.playercontroller.enabled then
                    highlightdude = acts[1].target
                end
                action = acts[1]
            end
        end

		if (target and target:IsValid() and target.Transform and (target:HasTag("player") or TheSim:GetLightAtPoint(target.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF)) or TheSim:GetLightAtPoint(position.x,position.y,position.z) > TUNING.DARK_CUTOFF then    
			local acts = self:GetRightClickActions(target, position)
			if acts[1] and (not action or acts[1].action ~= action.action) then
				second_action = acts[1]
				if not highlightdude and self.inst.components.playercontroller.enabled then
					highlightdude = acts[1].target
				end
			end
		end
    
    end
    
    if highlightdude ~= self.currenthighlight then
        if highlightdude and highlightdude.components.highlight then
            highlightdude.components.highlight:Highlight()
        end
        
        if self.currenthighlight and self.currenthighlight:IsValid() and self.currenthighlight.components.highlight then
            self.currenthighlight.components.highlight:UnHighlight()
        end
    end
    

    self.currenthighlight = highlightdude
    return action, second_action
    
end


function PlayerActionPicker:GetLeftMouseAction( )
    return self.LMBaction
end

function PlayerActionPicker:GetRightMouseAction( )
    return self.RMBaction
end

function PlayerActionPicker:OnUpdate(dt)
    self.LMBaction, self.RMBaction = self:DoGetMouseActions()
end


return PlayerActionPicker



