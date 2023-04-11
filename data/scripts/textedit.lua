require "widget"
require "text"

TextEdit = Class(Text, function(self, font, size, text)
    Text._ctor(self, font, size, text)

    self.inst.entity:AddTextEditWidget()
    self:SetString(text)
   
    self:SetTextInput( function() self:OnTextInput() end )

    self:SetGainFocus( function() self:OnGainFocus() end )
    self:SetLoseFocus( function() self:OnLoseFocus() end )

end)

function TextEdit:SetString(str)
	if self.inst and self.inst.TextEditWidget then
		self.inst.TextEditWidget:SetString(str or "")
	end
end

function TextEdit:OnTextInput(text)
	--print("TextEdit:OnTextInput()", text)

	if self.limit then
		local str = self:GetString()
		--print("len", string.len(str), "limit", self.limit)
		if string.len(str) >= self.limit then
			return
		end
	end

	if self.validchars then
		if not string.find(self.validchars, text, 1, true) then
			return
		end
	end
	
	self.inst.TextEditWidget:OnTextInput(text)
end

function TextEdit:OnKeyDown(key)
	--print("TextEdit:OnKeyDown()", key)
	self.inst.TextEditWidget:OnKeyDown(key)
end

function TextEdit:OnKeyUp(key)
	--print("TextEdit:OnKeyUp()", key)
	self.inst.TextEditWidget:OnKeyUp(key)
end

function TextEdit:OnGainFocus()
	--print("TextEdit:OnGainFocus()")
	self.inst.TextWidget:ShowEditCursor(true)
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	if self.focusimage then
		self.focusimage:SetTexture(self.atlas, self.focusedtex)
	end
end

function TextEdit:OnLoseFocus()
	--print("TextEdit:OnLoseFocus()")
	self.inst.TextWidget:ShowEditCursor(false)
	if self.focusimage then
		self.focusimage:SetTexture(self.atlas, self.unfocusedtex)
	end
end

function TextEdit:SetFocusedImage(widget, atlas, focused, unfocused)
	self.focusimage = widget
	self.atlas = atlas
	self.focusedtex = focused
	self.unfocusedtex = unfocused
end

function TextEdit:SetTextLengthLimit(limit)
	self.limit = limit
end

function TextEdit:SetCharacterFilter(validchars)
	self.validchars = validchars
end
