require "widget"

AnimButton = Class(Widget, function(self, animname, name)
    Widget._ctor(self, name or "BUTTON")
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBuild(animname)
    self.anim:GetAnimState():SetBank(animname)
    self.anim:GetAnimState():PlayAnimation("idle")
    self.anim:GetAnimState():SetRayTestOnBB(true);
    self.text = self:AddChild(Text(DEFAULTFONT, 30))
	self.text:SetVAlign(ANCHOR_MIDDLE)

    self.text:Hide()
    
    self.anim:SetMouseOver(
        function()
            if self:IsEnabled() then
				self.anim:GetAnimState():PlayAnimation("over")
			end
			self:OnMouseOver()
        end)

    self.anim:SetMouseOut(
        function()
			if self:IsEnabled() then
				self.anim:GetAnimState():PlayAnimation("idle")
            end
            
            if self:IsEnabled() then
				if self.o_pos then
					self:SetPosition(self.o_pos)
				end
			end
			self:OnMouseOut()
        end)
        
    self.anim:SetLeftMouseDown(
        function()
			if self:IsEnabled() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				self.o_pos = self:GetLocalPosition()
				self:SetPosition(self.o_pos + Vector3(0,-3,0))
			end
        end)

    self.anim:SetLeftMouseUp(
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

function AnimButton:Enable()
	self._base.Enable(self)
	self.anim:GetAnimState():PlayAnimation("idle")
	--self.text:SetColour(1,1,1,1)
end

function AnimButton:Disable()
	self._base.Disable(self)
	self.anim:GetAnimState():PlayAnimation("disabled")
	--self.text:SetColour(.7,.7,.7,1)
end

function AnimButton:SetFont(font)
	self.text:SetFont(font)
end

function AnimButton:SetOnClick( fn )
    self.onclick = fn
end

function AnimButton:GetSize()
    return self.image:GetSize()
end

function AnimButton:SetTextSize(sz)
	self.text:SetSize(sz)
end

function AnimButton:SetText(msg)
    if msg then
        self.text:SetString(msg)
        self.text:Show()
    else
        self.text:Hide()
    end
end

function AnimButton:OnMouseOver()
	if self:IsEnabled() then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	end
	Widget.OnMouseOver( self )
end

