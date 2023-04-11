require "widget"

Toggle = Class(Widget, function(self, data)
    Widget._ctor(self, "TOGGLE")
    self.image = self:AddChild(Image())
    self.text = self:AddChild(Text(DEFAULTFONT, 30))
    self.text:Hide()
    
    self.state = data.state or "off"
	self.states = data.states or {"on", "off", "optional"}
	
	if data ~= nil then
		local is_good = true
		for i,state in ipairs(self.states) do
			if data[state] == nil then
				is_good = false
				break
			end
		end
		
		if is_good then
			self:SetImages(data)
		end
		if data.disabled ~= nil then
			self:SetDisabledImage(data.disabled)
		end
	end
    self.image:SetTexture(self.normaltex[self.state])
	
    self.image:SetMouseOver(
        function()
            if self.enabled then
				if self.mouseovertex then
					self.image:SetTexture(self.mouseovertex)
				end         
			end
			self:OnMouseOver()
        end)

    self.image:SetMouseOut(
        function()
            if self.normaltex then
				if self.enabled or not self.disabledtex then
					self.image:SetTexture(self.normaltex[self.state])
				else
					self.image:SetTexture(self.disabledtex)
				end
            end
            
            if self.enabled then
				if self.o_pos then
					self:SetPosition(self.o_pos)
				end
			end
			self:OnMouseOut()
        end)
        
    self.image:SetLeftMouseDown(
        function()
			if self.enabled then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				self.o_pos = self:GetLocalPosition()
				self:SetPosition(self.o_pos + Vector3(0,-3,0))
			end
        end)

    self.image:SetLeftMouseUp(
        function()
			if self.enabled then
				if self.o_pos then
					self:SetPosition(self.o_pos)
					self:DoToggle()
				end
			end
        end)   
end)

function Toggle:Enable()
	self._base.Enable(self)
    self.image:SetTexture(self.normaltex[self.state])
end

function Toggle:Disable()
	self._base.Disable(self)
	self.image:SetTexture(self.disabledtex)
end

function Toggle:SetFont(font)
	self.text:SetFont(font)
end

function Toggle:SetOnClick( fn )
    self.OnChanged = fn
end

function Toggle:GetSize()
    return self.image:GetSize()
end

function Toggle:SetImages(tex)
    self.normaltex = tex    
    self.image:SetTexture(self.normaltex[self.state])
end

function Toggle:SetMouseOverImage(tex)
    self.mouseovertex = tex
end

function Toggle:DoToggle(setval)
    --print("Toggle:",self.state,"-->",setval)
	if setval ~= nil then
    	self.state = setval
    else
    	for i,state in ipairs(self.states) do
    		if state == self.state then
    			--print("Toggle:",((i+1 )% #self.states)+1)
    			self.state = self.states[((i+1 )% #self.states)+1]
    			break
    		end
    	end
    end
    
    if self.OnChanged ~= nil then
    	self:OnChanged(self.state)
    end
    
    --print("Toggle:",self.state)
    self.image:SetTexture(self.normaltex[self.state])
end
 
function Toggle:SetDisabledImage(tex)
    self.disabledtex = tex
end

function Toggle:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Toggle:SetText(msg)
    if msg then
        self.text:SetString(msg)
        self.text:Show()
    else
        self.text:Hide()
    end
end

function Toggle:OnMouseOver()
	if self.enabled then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	end
	Widget.OnMouseOver( self )
end
