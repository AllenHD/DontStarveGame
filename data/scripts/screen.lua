require "widget"
require "image"

Screen = Class(Widget, function(self, name)
    Widget._ctor(self, name)
    self.active = false

	self.focusstack = {}
	self.focusindex = 0
	self.handlers = {}
end)

function Screen:OnLoseFocus()
	self.active = false
	self:Disable()
end

function Screen:OnGainFocus()
	TheSim:SetUIRoot(self.inst.entity)
	self.active = true
	self:Enable()
	--self:Show()
end

function Screen:OnCreate()
end

function Screen:OnDestroy()
	self:Kill()
end


function Screen:OnUpdate(dt)
	return true
end

function Screen:PushFocusWidget(widget)
	table.insert(self.focusstack, widget)
	if self.focusindex == 0 then
		self.focusindex = 1
		self.focusstack[self.focusindex]:OnGainFocus()
	end
end

function Screen:RemoveFocusWidget(widget)
	for k,v in ipairs(self.focusstack) do
		if v == widget then
			v:OnLoseFocus()
			table.remove(self.focusstack, k)
			
			self.focusindex = self.focusindex - 1
			if self.focusindex > 0 then
				self.focusstack[self.focusindex]:OnGainFocus()
			end
			
			break
		end
	end
end

function Screen:GetActiveFocusWidget()
	if self.focusstack and #self.focusstack > 0 and self.focusindex > 0 then
		return self.focusstack[self.focusindex]
	else
		return nil
	end
end

function Screen:ClearFocusWidgets()
	if #self.focusstack > 0 and self.focusindex > 0 then
		self.focusstack[self.focusindex]:OnLoseFocus()
	end

	self.focusstack = {}
	self.focusindex = 0
end

function Screen:AdvanceFocus( forward )
	--print("Screen:AdvanceFocus", #self.focusstack, self.focusindex, forward)
	if self.focusstack and #self.focusstack > 0 and self.focusindex > 0 then
		local oldindex = self.focusindex
		--print("...old", oldindex)
		if forward then
			self.focusindex = self.focusindex + 1
			if self.focusindex > #self.focusstack then
				self.focusindex = 1
			end
		else
			self.focusindex = self.focusindex - 1
			if self.focusindex < 1 then
				self.focusindex = #self.focusstack
			end
		end
		--print("...new", self.focusindex)
		if oldindex ~= self.focusindex then
			--print("...switching focus", self.focusstack[oldindex], self.focusstack[self.focusindex])
			self.focusstack[oldindex]:OnLoseFocus()
			self.focusstack[self.focusindex]:OnGainFocus()
		end
	end
end

function Screen:SetFocus(widget)
	--print("Screen:SetFocus", #self.focusstack, self.focusindex)
	for index,v in ipairs(self.focusstack) do
		if v == widget then
			--print("..." .. index)
			if index ~= self.focusindex then
				self.focusstack[self.focusindex]:OnLoseFocus()
				self.focusindex = index
				self.focusstack[self.focusindex]:OnGainFocus()
			end
			break
		end
	end
end


function Screen:OnKeyUp( key )
	local focused = self:GetActiveFocusWidget()
	if focused then
		focused:OnKeyUp(key)
	end
end

function Screen:OnKeyDown( key )
	--print("Screen:OnKeyDown", KEY_TAB, key)
	if key == KEY_TAB then
		--print("... is tab")
		self:AdvanceFocus( not TheInput:IsKeyDown(KEY_SHIFT) )
	else
		local focused = self:GetActiveFocusWidget()
		if focused then
			focused:OnKeyDown(key)
		end
	end
end

function Screen:OnTextInput(text)
	--print("Screen:OnTextInput()", text)
	local focused = self:GetActiveFocusWidget()
	if focused then
		focused:OnTextInput(text)
	end
end

function Screen:AddEventHandler(event, fn)
	if not self.handlers[event] then
		self.handlers[event] = {}
	end
	
	self.handlers[event][fn] = true
	
	return fn
end

function Screen:RemoveEventHandler(event, fn)
	if self.handlers[event] then
		self.handlers[event][fn] = nil
	end
end

function Screen:HandleEvent(type, ...)
	local handlers = self.handlers[type]
	if handlers then
		for k,v in pairs(handlers) do
			k(...)
		end
	end
	
end