require "class"
require "widgets/inventoryslot"
require "widgets/common"
local DOUBLECLICKTIME = .33

ContainerWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "Container")
    local scale = .6
    self:SetScale(scale,scale,scale)
    self.open = false
    self.inv = {}
    self.owner = owner
    self:SetPosition(0, 0, 0)
    self.slotsperrow = 3
    
    self.bganim = self:AddChild(UIAnim())
	self.bgimage = self:AddChild(Image())
    self.isopen = false
end)

function ContainerWidget:Open(container, doer)
    self:Close()

	if container.components.container.widgetbgatlas and container.components.container.widgetbgimage then
		self.bgimage:SetTexture( container.components.container.widgetbgatlas, container.components.container.widgetbgimage )
	end
    
    if container.components.container.widgetanimbank then
		self.bganim:GetAnimState():SetBank(container.components.container.widgetanimbank)
	end
    
    if container.components.container.widgetanimbuild then
		self.bganim:GetAnimState():SetBuild(container.components.container.widgetanimbuild)
    end
    
    
    if container.components.container.widgetpos then
		self:SetPosition(container.components.container.widgetpos)
	end
	
	if container.components.container.widgetbuttoninfo then
		self.button = self:AddChild(AnimButton("button_small"))
	    self.button:SetPosition(container.components.container.widgetbuttoninfo.position)
	    self.button:SetText(container.components.container.widgetbuttoninfo.text)
	    self.button:SetOnClick( function() container.components.container.widgetbuttoninfo.fn(container, doer) end )
	    self.button:SetFont(BUTTONFONT)
	    self.button:SetTextSize(35)
	    self.button.text:SetVAlign(ANCHOR_MIDDLE)
	    self.button.text:SetColour(0,0,0,1)
	    
		if container.components.container.widgetbuttoninfo.validfn then
			if container.components.container.widgetbuttoninfo.validfn(container, doer) then
				self.button:Enable()
			else
				self.button:Disable()
			end
		end
	end
	
	
    self.isopen = true
    self:Show()
    
	if self.bgimage.texture then
		self.bgimage:Show()
	else
		self.bganim:GetAnimState():PlayAnimation("open")
	end
	    
    self.onitemlosefn = function(inst, data) self:OnItemLose(data) end
    self.inst:ListenForEvent("itemlose", self.onitemlosefn, container)

    self.onitemgetfn = function(inst, data) self:OnItemGet(data) end
    self.inst:ListenForEvent("itemget", self.onitemgetfn, container)
	
	local num_slots = math.min( container.components.container:GetNumSlots(), #container.components.container.widgetslotpos)
	
	local n = 1
	for k,v in ipairs(container.components.container.widgetslotpos) do
	
		local slot = InvSlot(n,"data/images/hud.xml", "inv_slot.tex", self.owner, container.components.container)
		self.inv[n] = self:AddChild(slot)

		slot:SetPosition(v)
		
		slot:SetLeftMouseDown(function() self:ClickInvSlot(slot) end)
		slot:SetRightMouseDown(function() self:RightClickInvSlot(slot) end)
		
		local obj = container.components.container:GetItemInSlot(n)
		if obj then
			local tile = ItemTile(obj, self)
			slot:SetTile(tile)
		end
		
		n = n + 1
	end

    self.container = container
    
end    


function ContainerWidget:RightClickInvSlot(slot)
	
	if self.owner and self.owner.components.inventory then
		
		local item = self.container.components.container:GetItemInSlot(slot.num)
		if item then
		
			if self.owner.components.inventory:GetActiveItem() then
				local actions = self.owner.components.playeractionpicker:GetUseItemActions(item, self.owner.components.inventory:GetActiveItem(), true)
				if actions then
					self.owner.components.locomotor:PushAction(actions[1], true)
				end
			else
				if item.components.equippable then
					self.owner.components.inventory:Equip(item)
				else
					local actions = self.owner.components.playeractionpicker:GetInventoryActions(item, true)
					if actions then
						self.owner.components.locomotor:PushAction(actions[1], true)
					end
				end
			end
	    end
	end
end

function ContainerWidget:ClickInvSlot(slot)
	HandleContainerUIClick(self.owner, self.owner.components.inventory, self.container.components.container, slot.num)
end

function ContainerWidget:OnItemGet(data)
    if data.slot and self.inv[data.slot] then
		local tile = ItemTile(data.item, self)
        self.inv[data.slot]:SetTile(tile)
        tile:Hide()

        if data.src_pos then
			local dest_pos = self.inv[data.slot]:GetWorldPosition()
			local inventoryitem = data.item.components.inventoryitem
			local im = Image(inventoryitem:GetAtlas(), inventoryitem:GetImage())
			im:MoveTo(data.src_pos, dest_pos, .3, function() tile:Show() tile:ScaleTo(2, 1, .25) im:Kill() end)
        else
			tile:Show() 
			tile:ScaleTo(2, 1, .25)
        end
	end
	
	if self.container and self.container.components.container.widgetbuttoninfo and self.container.components.container.widgetbuttoninfo.validfn then
		if self.container.components.container.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
end

function ContainerWidget:Update(dt)
	if self.isopen and self.owner and self.container then
		
		if not (self.container.components.inventoryitem and self.container.components.inventoryitem:IsHeldBy(self.owner)) then
			local distsq = self.owner:GetDistanceSqToInst(self.container)
			if distsq > 3*3 then
				self:Close()
			end
		end
	end
	
	return self.should_close_widget ~= true
end

function ContainerWidget:OnItemLose(data)
	local tileslot = self.inv[data.slot]
	if tileslot then
		tileslot:SetTile(nil)
	end
	
	if self.container and self.container.components.container.widgetbuttoninfo and self.container.components.container.widgetbuttoninfo.validfn then
		if self.container.components.container.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
	
end


function ContainerWidget:Close()
    if self.isopen then
		
		if self.button then
			self.button:Kill()
			self.button = nil
		end
		
		if self.container then
			self.container.components.container:Close()
			--self.inst:RemoveAllEventCallbacks()
			if self.onitemlosefn then
				self.inst:RemoveEventCallback("itemlose", self.onitemlosefn, self.container)
				self.onitemlosefn = nil
			end
			if self.onitemgetfn then
				self.inst:RemoveEventCallback("itemget", self.onitemgetfn, self.container)
				self.onitemgetfn = nil
			end
		end
		
	    
		for k,v in pairs(self.inv) do
--			self:RemoveChild(v)
			v:Kill()
		end
	    
		self.container = nil
		self.inv = {}
		if self.bgimage.texture then
			self.bgimage:Hide()
		else
			self.bganim:GetAnimState():PlayAnimation("close")
		end
		
		self.isopen = false
		
	    self.inst:DoTaskInTime(.3, function()self.should_close_widget = true  end)
		
	end
    --self:Hide()

end
