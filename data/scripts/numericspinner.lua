require "spinner"
--
-- You should override the On* functions to implement desired behaviour.
--
-- For example, OnChanged gets called by Changed, the base function. Both get passed the newly selected item.

NumericSpinner = Class(Spinner, function( self, min, max, width, height, textinfo, atlas, textures, arrow_scale, editable )
	-- min/max need to be set before calling base class ctor as it calls SetSelectedIndex, which results in them being used
	-- aka. never call "virtual" functions during construction
	self.min = min
	self.max = max
	
    Spinner._ctor( self, {}, width, height, textinfo, atlas, textures, arrow_scale, editable )
end)

function NumericSpinner:GetSelected()
	return self:GetSelectedIndex()
end

function NumericSpinner:GetSelectedIndex()
	--print("NumericSpinner:GetSelectedIndex()", self.editable, self.selectedIndex, self:GetText())
	if not self.updating and self.editable and self:GetText() then
		--print("parsing input")
		local input = tonumber(self:GetText())
		if input then
			self.selectedIndex = math.max(self.min, math.min(self.max, input))
		end
	end
	return self.selectedIndex
end

function NumericSpinner:GetSelectedText()
	return tostring(self:GetSelected())
end

function NumericSpinner:GetSelectedData()
	return self:GetSelected()
end

function NumericSpinner:MinIndex()
	return self.min
end

function NumericSpinner:MaxIndex()
	return self.max
end

function NumericSpinner:OnKeyDown(key)
	if key == KEY_DOWN then
		self:Prev()
	elseif key == KEY_UP then
		self:Next()
	elseif self.editable then
		self.text:OnKeyDown(key)
	end
end

function NumericSpinner:OnKeyUp(key)
	if self.editable then
		self.text:OnKeyUp(key)
	end
end

function NumericSpinner:OnTextInput(text)
	if self.editable then
		self.text:OnTextInput(text)
	end
end

function NumericSpinner:OnGainFocus()
	if self.editable then
		self.text:OnGainFocus()
	end
end

function NumericSpinner:OnLoseFocus()
	if self.editable then
		self.text:OnLoseFocus()
	end
end