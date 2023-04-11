require "widget"

local Tab = Class(Widget, function(self, tabgroup, name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imoverlay, selectfn, deselectfn)
    Widget._ctor(self, "Tab")
    self.group = tabgroup
    self.atlas = atlas
    self.icon_atlas = icon_atlas
    self.selectfn = selectfn
    self.deselectfn = deselectfn
    self.imnormal = imnorm
    self.imselected = imselected
    self.imhighlight = imhighlight
	self.basescale = .5
    self.selected = false
    self.highlighted = false
    self:SetTooltip(name)
	self:SetScale(self.basescale,self.basescale,self.basescale)    
    
    self.bg = self:AddChild(Image(atlas, imnorm))
    local w, h = self.bg:GetSize()    
    
    self.bg:SetPosition(w/2,0,0)
    self.icon = self:AddChild(Image(icon_atlas, icon))
    self.icon:SetClickable(false)
    self.icon:SetPosition(w/2,0,0)
    
    self.overlay = self:AddChild(Image(atlas, imoverlay))
    self.overlay:SetPosition(w/2,0,0)
    self.overlay:Hide()
    self.overlay:SetClickable(false)
    
    self.bg:SetLeftMouseDown( function() if self.selected then self:Deselect() else self:Select() end tabgroup:OnTabsChanged() end )
    
end)

function Tab:Overlay()
	if not self.overlayshow then
		self.overlayshow = true
		self.overlay:Show()
		local delay = nil
        if self.group.onoverlay then
            delay = self.group.onoverlay()
        end
        
		local applychange = function()
			self:ScaleTo(2*self.basescale,(self.selected and 1.25 or 1)*self.basescale,.25)
			self.overlay:Show()
        end
        
        if delay then 
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end        
	end
end

function Tab:HideOverlay()
	self.overlayshow = false
	self.overlay:Hide()
end

function Tab:Highlight(num)
    
    local change_scale = not self.highlightnum or self.highlightnum < num
    local change_texture = not self.selected and change_scale
    
    self.highlighted = true
    self.highlightnum = num
    
    if change_texture or change_scale then

        local delay = nil
        
        if self.group.onhighlight then
            delay = self.group.onhighlight()
        end
        
        local applychange = function()
            if change_texture then
                self.bg:SetTexture(self.atlas, self.imhighlight)
            end
                
            if change_scale then
                self:ScaleTo(2*self.basescale,(self.selected and 1.25 or 1)*self.basescale,.25)
            end
        end
        
        if delay then 
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
        
    end
    
    
end


function Tab:UnHighlight()
    if not self.selected then
        self.bg:SetTexture(self.atlas, self.imnormal)
    end
    
    if self.highlighted then
        self:ScaleTo(.75*self.basescale, (self.selected and 1.25 or 1)*self.basescale, .33)
    end
    
    self.highlighted = false
    self.highlightnum = nil
end


function Tab:Deselect()

    if self.selected then
        self:ScaleTo(1.25*self.basescale, 1*self.basescale, .125)
        if self.deselectfn then
            self.deselectfn()
        end
        self.bg:SetTexture(self.atlas, self.highlighted and self.imhighlight or self.imnormal)
        self.selected = false
    end
    
end

function Tab:Select()

    if not self.selected then
        self:ScaleTo(1*self.basescale, 1.25*self.basescale, .25)
        self.group:DeselectAll()

        if self.selectfn then
            self.selectfn()
        end
        
        self.bg:SetTexture(self.atlas, self.imselected)
        self.selected = true
        
    end
    
end


TabGroup = Class(Widget, function(self)
    Widget._ctor(self, "TabGroup")
    self.tabs = {}
    self.spacing = 70
    self.offset = Vector3(0,-1,0)
    self.hideoffset = Vector3(-64, 0, 0)
    self.selected = nil
    self.base_pos = {}
    self.shown = {}
end)

function TabGroup:HideTab(tab)
	if self.shown[tab] then
		if self.base_pos[tab] then
			tab:MoveTo(self.base_pos[tab], (self.base_pos[tab] + self.hideoffset), .33)
			self.shown[tab] = false
		end
	end
end

function TabGroup:ShowTab(tab)
	if not self.shown[tab] then
		if self.base_pos[tab] then
			tab:MoveTo((self.base_pos[tab] + self.hideoffset), self.base_pos[tab], .33)
			self.shown[tab] = true
		end
	end
end

function TabGroup:AddTab(name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imoverlay, highlightpos, onselect, ondeselect)

    local tab = self:AddChild(Tab(self, name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imoverlay, highlightpos, onselect, ondeselect))
    table.insert(self.tabs, tab)
    
    local numtabs = #self.tabs
    
    local scalar = -self.spacing*(numtabs-1)*.5
    local offset = self.offset*scalar
    
    for k,v in ipairs(self.tabs) do
        v:SetPosition(offset.x, offset.y, offset.z)
        self.base_pos[v] = Vector3(offset.x, offset.y, offset.z)
        offset = offset + self.offset*self.spacing
    end
    
    self.shown[tab] = true
    return tab
end


function TabGroup:OnTabsChanged()
    local selected = nil
    for k,v in pairs(self.tabs) do
        if v.selected then
            selected = v
            break
        end
    end
    
    if self.selected ~= selected then
        
        if self.selected and not selected then
            if self.onclose then self:onclose() end
        elseif not self.selected and selected then
            if self.onopen then self:onopen() end
        else
            if self.onchange then self:onchange() end
        end
        
        self.selected = selected
    end
end

function TabGroup:DeselectAll()
    
    for k,v in ipairs(self.tabs) do
        v:Deselect()
    end
    
end
