require "widget"

Button = Class(Widget, function(self, name)
    Widget._ctor(self, name or "BUTTON")
    self.atlas = nil
    self.image = self:AddChild(Image())
    self.text = self:AddChild(Text(DEFAULTFONT, 30))
    self.text:Hide()

    self.image:SetMouseOver(
        function()
            if self:IsEnabled() then
				if self.mouseovertex then
					self.image:SetTexture(self.atlas, self.mouseovertex)
				end
	            
			end
			self:OnMouseOver()
        end)

    self.image:SetMouseOut(
        function()
            if self.normaltex then
				if self:IsEnabled() or not self.disabledtex then
					self.image:SetTexture(self.atlas, self.normaltex)
				else
					self.image:SetTexture(self.atlas, self.disabledtex)
				end
            end
            
            if self:IsEnabled() then
				if self.o_pos then
					self:SetPosition(self.o_pos)
				end
			end
			self:OnMouseOut()
        end)
        
    self.image:SetLeftMouseDown(
        function()
			if self:IsEnabled() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				self.o_pos = self:GetLocalPosition()
				self:SetPosition(self.o_pos + Vector3(0,-3,0))
			end
        end)

    self.image:SetLeftMouseUp(
        function()
			if self:IsEnabled() then
				if self.o_pos then
					self:SetPosition(self.o_pos)
					if self.onclick then
						self.onclick()
					end
				end
			end
        end)        
end)

function Button:Enable()
	self._base.Enable(self)
	
	if not self.over then
		self.image:SetTexture(self.atlas, self.normaltex)
	end
	--self.text:SetColour(1,1,1,1)
end

function Button:Disable()
	self._base.Disable(self)
	self.image:SetTexture(self.atlas, self.disabledtex)
	--self.text:SetColour(.7,.7,.7,1)
	
end

function Button:SetFont(font)
	self.text:SetFont(font)
end

function Button:SetOnClick( fn )
    self.onclick = fn
end

function Button:GetSize()
    return self.image:GetSize()
end

function Button:SetImage(atlas, tex)
	self.atlas = atlas
    self.normaltex = tex
    
    if not self.mouseovertex or not self.over then
		self.image:SetTexture(atlas, tex)
	end
end

function Button:SetMouseOverImage(atlas, tex)
	self.atlas = atlas or self.atlas
    self.mouseovertex = tex
end

function Button:SetDisabledImage(atlas, tex)
	self.atlas = atlas or self.atlas
    self.disabledtex = tex
end

function Button:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Button:SetText(msg)
    if msg then
        self.text:SetString(msg)
        self.text:Show()
    else
        self.text:Hide()
    end
end

function Button:OnMouseOver()
	if self:IsEnabled() then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	end
	Widget.OnMouseOver( self )
end

