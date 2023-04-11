InvSlot = Class(Widget, function(self, num, atlas, bgim, owner, container)
    Widget._ctor(self, "InventorySlot"..tostring(num))
    self.owner = owner

    self.bgimage = self:AddChild(Image(atlas, bgim))

    self.num = num
    self.tile = nil

    self.bgimage:SetMouseOver(function()
		local active_item = self.owner.components.inventory:GetActiveItem()
		if active_item then
			if container and not container:CanTakeItemInSlot(active_item, self.num) then
				return
			end
		elseif self.tile == nil then
			return
		end

        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
        if self.tile then
            self.tile:OnMouseOver()
        end
        self:ScaleTo(1, 1.3, .125)
        self.big = true
    end)

    self.bgimage:SetMouseOut(function()
		if self.big then    
			if self.tile then
				self.tile:OnMouseOut()
			end
			self:ScaleTo(1.3, 1, .25)
		self.big = nil
		end
		
    end)
end)


function InvSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

EquipSlot = Class(Widget, function(self, equipslot, atlas, bgim, owner)
    Widget._ctor(self, "EquipSlot"..tostring(equipslot))
    self.owner = owner

    self.equipslot = equipslot
    self.item = nil

    self.bgimage = self:AddChild(Image(atlas, bgim))
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(inst, data)
        if data.item and data.item.components.equippable and data.item.components.equippable.equipslot == self.equipslot then
            self:ScaleTo(1, 1.5, .125)
            self.highlight = true
        elseif self.highlight then
            self.highlight = false
            self:ScaleTo(1.5, 1, .125)
        end
    end, self.owner)


    self.bgimage:SetMouseOver(function()
		self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
        if self.tile then
            self.tile:OnMouseOver()
        end
        
        if not self.highlight then
            self:ScaleTo(1, 1.2, .125)
        end
    end)

    self.bgimage:SetMouseOut(function()
        if self.tile then
            self.tile:OnMouseOut()
        end
        if not self.highlight then
            self:ScaleTo(1.2, 1, .25)
        end
    end)

end)



function EquipSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end

end


ItemTile = Class(Widget, function(self, invitem, owner)
    Widget._ctor(self, "ItemTile"..tostring(invitem.prefab))
    self.owner = owner
    self.item = invitem

	-- NOT SURE WAHT YOU WANT HERE
	if invitem.components.inventoryitem == nil then
		print("NO INVENTORY ITEM COMPONENT"..tostring(invitem.prefab), invitem, owner)
		return
	end
	
	local hud_atlas = resolvefilepath( "data/images/hud.xml" )

	self.bg = self:AddChild(Image())
	self.bg:SetTexture(hud_atlas, "inv_slot_spoiled.tex")
	self.bg:Hide()
	self.bg:SetClickable(false)
	
	self.spoilage = self:AddChild(UIAnim())
	
    self.spoilage:GetAnimState():SetBank("spoiled_meter")
    self.spoilage:GetAnimState():SetBuild("spoiled_meter")
    self.spoilage:Hide()
    self.spoilage:SetClickable(false)
	
	
    self.image = self:AddChild(Image(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage()))
    self.image:SetClickable(false)

    local owner = self.item.components.inventoryitem.owner
    
    if self.item.prefab == "spoiled_food" or (self.item.components.edible and self.item.components.perishable) then
		self.bg:Show( )
	end
	
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:Show()
	end

    self.inst:ListenForEvent("imagechange", function() 
        self.image:SetTexture(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage())
    end, invitem)
    
    self.inst:ListenForEvent("stacksizechange",
            function(inst, data)
                if invitem.components.stackable then
                
					if data.src_pos then
						local dest_pos = self:GetWorldPosition()
						local im = Image(invitem.components.inventoryitem:GetAtlas(), invitem.components.inventoryitem:GetImage())
						im:MoveTo(data.src_pos, dest_pos, .3, function() 
							self:SetQuantity(invitem.components.stackable:StackSize())
							self:ScaleTo(2, 1, .25)
							im:Kill() end)
					else
	                    self:SetQuantity(invitem.components.stackable:StackSize())
						self:ScaleTo(2, 1, .25)
					end
                end
            end, invitem)


    if invitem.components.stackable then
        self:SetQuantity(invitem.components.stackable:StackSize())
    end

    self.inst:ListenForEvent("percentusedchange",
            function(inst, data)
                self:SetPercent(data.percent)
            end, invitem)
    self.inst:ListenForEvent("perishchange",
            function(inst, data)
                self:SetPerishPercent(data.percent)
            end, invitem)

    if invitem.components.fueled then
        self:SetPercent(invitem.components.fueled:GetPercent())
    end

    if invitem.components.finiteuses then
        self:SetPercent(invitem.components.finiteuses:GetPercent())
    end

    if invitem.components.perishable then
        self:SetPerishPercent(invitem.components.perishable:GetPercent())
    end
    
    
    if invitem.components.armor then
        self:SetPercent(invitem.components.armor:GetPercent())
    end
    

end)

function ItemTile:OnMouseOver()
    if self.item.components.inventoryitem then
        self.namedisp= self:AddChild(Text(UIFONT, 40))
		local adjective = self.item:GetAdjective()
		local str = nil
		if adjective then
			str = adjective .. " " .. self.item:GetDisplayName()
		else
			str = self.item:GetDisplayName()
		end
        
		self.namedisp:SetHAlign(ANCHOR_LEFT)
        local owner = self.item.components.inventoryitem and self.item.components.inventoryitem.owner
		local actionpicker = owner and owner.components.playeractionpicker or GetPlayer().components.playeractionpicker
		local inventory = owner and owner.components.inventory or GetPlayer().components.inventory
        if owner and inventory and actionpicker then
        
			local actions = nil
			if inventory:GetActiveItem() then
				actions = actionpicker:GetUseItemActions(self.item, inventory:GetActiveItem(), true)
			end
            if not actions then
				actions = actionpicker:GetInventoryActions(self.item)
			end
			
            if actions then
                str = str.."\n" .. STRINGS.RMB .. ": " .. actions[1]:GetActionString()
            end
        end
        
        self.namedisp:SetString(str)
        
        local scr_w, scr_h = TheSim:GetScreenSize()

        local w, h = self.namedisp:GetRegionSize()
        local pos = self:GetWorldPosition()
        pos.y = pos.y + 80
        local x = math.min(math.max(pos.x, w/2), scr_w - w/2)
        local y = math.min(math.max(pos.y, h/2 + 80), scr_h - h/2)

        if self.parent then
            local parentpos = self.parent:GetWorldPosition()
            x = x - parentpos.x
            y = y - parentpos.y
        end
        self.namedisp:SetPosition(x,y,0)
    end
    
    if self.namedisp then
        self.namedisp:Show()
    end
end

function ItemTile:SetQuantity(quantity)
    if not self.quantity then
        self.quantity = self:AddChild(Text(NUMBERFONT, 42))
        self.quantity:SetPosition(2,16,0)
    end
    self.quantity:SetString(tostring(quantity))
end

function ItemTile:SetPerishPercent(percent)
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:GetAnimState():SetPercent("anim", 1-self.item.components.perishable:GetPercent())
	end
end

function ItemTile:SetPercent(percent)
    --if not self.item.components.stackable then
        
	if not self.percent then
		self.percent = self:AddChild(Text(NUMBERFONT, 42))
		self.percent:SetPosition(5,-32+15,0)
	end
    local val_to_show = percent*100
    if val_to_show > 0 and val_to_show < 1 then
        val_to_show = 1
    end
	self.percent:SetString(string.format("%2.0f%%", val_to_show))
        
    --end
end

function ItemTile:OnMouseOut()
    if self.namedisp then
        self.namedisp:Hide()
    end
end

function ItemTile:CancelDrag()
    self:StopFollowMouse()
    
    if self.item.prefab == "spoiled_food" or (self.item.components.edible and self.item.components.perishable) then
		self.bg:Show( )
	end
	
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:Show()
	end
    
end

function ItemTile:StartDrag()
    self:SetScale(1,1,1)
    --self:FollowMouse(true)
    self.spoilage:Hide()
    self.bg:Hide( )
end
