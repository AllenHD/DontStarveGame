
--this is shared between the inventory bar and containers. Yay duck typing!
function HandleContainerUIClick(character, inventory, container, slot_number)


    local container_item = container:GetItemInSlot(slot_number)
    local active_item = inventory:GetActiveItem()
    
	local inspect_mod = TheInput:IsKeyDown(KEY_SHIFT)
    local stack_mod = TheInput:IsKeyDown(KEY_CTRL)


	--this mess is to automatically shuffle items between your inventory and open containers/backpacks
	if inspect_mod and stack_mod and character and inventory and container_item then
		local dest_inst = container ~= inventory and character or nil
		for k,v in pairs(inventory.opencontainers) do
			if k ~= container.inst and (not dest_inst or not k.components.equippable) then
				local dest = k.components.inventory or k.components.container
				if dest then
					if dest:CanTakeItemInSlot(container_item) then
						if dest:IsFull() and dest.acceptsstacks then
							--check the container to see if an item of that type is in it already and can be put in.
							for c,v in pairs(dest.slots) do
								if v.prefab == container_item.prefab then
									dest_inst = k
								end
							end
						else
							dest_inst = k
						end
					end
				end
			end	
		end
		
		if dest_inst then
			local dest = dest_inst.components.inventory or dest_inst.components.container
			if dest then
				local item = nil
				if container_item.components.stackable then				
					item = container_item.components.stackable:Get(math.floor(container_item.components.stackable:StackSize() / 2))
					if item.components.stackable.stacksize < 1 then
						item = nil
						return
					end
				else
					item = container:RemoveItemBySlot(slot_number)
				end
				if not dest:GiveItem(item) then
					container:GiveItem(item, slot_number)
				end
				return
			end
		end
	elseif inspect_mod and not stack_mod and character and inventory and container_item then
		local dest_inst = container ~= inventory and character or nil
		for k,v in pairs(inventory.opencontainers) do
			if k ~= container.inst and (not dest_inst or not k.components.equippable) then
				local dest = k.components.inventory or k.components.container
				if dest then
				if dest:CanTakeItemInSlot(container_item) then
						if dest:IsFull() and dest.acceptsstacks then
							--check the container to see if an item of that type is in it already and can be put in.
							for c,v in pairs(dest.slots) do
								if v.prefab == container_item.prefab then
									dest_inst = k
								end
							end
						else
							dest_inst = k
						end
					end
				end
			end	
		end
		
		if dest_inst then
			local dest = dest_inst.components.inventory or dest_inst.components.container
			if dest then
				local item = container:RemoveItemBySlot(slot_number)
				if not dest:GiveItem(item) then
					container:GiveItem(item, slot_number)
				end
				return
			end
		end
	end

	--if that's no an option...


	if inspect_mod and container_item then
        character.components.locomotor:PushAction(BufferedAction(character, container_item, ACTIONS.LOOKAT), true)
		return
    end
	
	local can_take_active_item = active_item and (not container.CanTakeItemInSlot or container:CanTakeItemInSlot(active_item, slot_number))
	
 
	if active_item and not container_item then
		
		if can_take_active_item then

			if active_item.components.stackable and active_item.components.stackable:StackSize() > 1 and (stack_mod or not container.acceptsstacks) then
				container:GiveItem( active_item.components.stackable:Get(), slot_number)
			else
				inventory:RemoveItem(active_item, true)
				container:GiveItem(active_item, slot_number)
			end
			
			character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")    
			
		else
			character.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
		end
		
	elseif container_item and not active_item then
		
		if stack_mod and container_item.components.stackable and container_item.components.stackable:StackSize() > 1 then
			
			inventory:GiveActiveItem( container_item.components.stackable:Get(math.floor(container_item.components.stackable:StackSize() / 2)))
		else
			container:RemoveItemBySlot(slot_number)
			inventory:GiveActiveItem(container_item)
		end

		character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")    
		
	elseif container_item and active_item then
		if can_take_active_item then
			local same_prefab = container_item and active_item and container_item.prefab == active_item.prefab
			local stacked = same_prefab and container_item.components.stackable and container.acceptsstacks			
			if stacked then
				if stack_mod and active_item.components.stackable.stacksize > 1 and not container_item.components.stackable:IsFull() then
					container_item.components.stackable:Put(active_item.components.stackable:Get())				
				else
					local leftovers = container_item.components.stackable:Put(active_item)
					inventory:SetActiveItem(leftovers)
				end				
			else
				local cant_trade_stack = not container.acceptsstacks and (active_item.components.stackable and active_item.components.stackable:StackSize() > 1)
				
				if not cant_trade_stack then
					inventory:RemoveItem(active_item, true)
					container:RemoveItemBySlot(slot_number)
					inventory:GiveActiveItem(container_item)
					container:GiveItem(active_item, slot_number)
				end
			end
			
			character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")    
			
		else
			character.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
		end
	end    
end
