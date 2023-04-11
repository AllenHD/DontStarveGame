require "button"

TextButton = Class(Widget, function(self, name)
	Widget._ctor(self, name or "TEXTBUTTON")

    self.image = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self.text = self:AddChild(Text(DEFAULTFONT, 30))

	self.colour = {1,1,1,1}
	self.overcolour = {0,0,1,1}

	self.image:SetMouseOver(
		function()
			if self:IsEnabled() then
				self.text:SetColour(self.overcolour)
				self.image:SetSize(self.text:GetRegionSize())
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			end
			self:OnMouseOver()
		end)

	self.image:SetMouseOut(
		function()
			if self:IsEnabled() then
				self.text:SetColour(self.colour)
				self.image:SetSize(self.text:GetRegionSize())

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


function TextButton:SetTextSize(sz)
	self.text:SetSize(sz)
end

function TextButton:SetText(msg)
    if msg then
        self.text:SetString(msg)
        self.text:Show()
    else
        self.text:Hide()
    end
	self.image:SetSize(self.text:GetRegionSize())
end

function TextButton:SetFont(font)
	self.text:SetFont(font)
end

function TextButton:SetColour(r,g,b,a)
	if type(r) == "number" then
		self.colour = {r,g,b,a}
	else
		self.colour = r
	end
	self.text:SetColour(self.colour)
end

function TextButton:SetOverColour(r,g,b,a)
	if type(r) == "number" then
		self.overcolour = {r,g,b,a}
	else
		self.overcolour = r
	end
end

function TextButton:SetOnClick( fn )
    self.onclick = fn
end

