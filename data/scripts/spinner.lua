require "widget"
--
-- You should override the On* functions to implement desired behaviour.
--
-- For example, OnChanged gets called by Changed, the base function. Both get passed the newly selected item.


Spinner = Class(Widget, function( self, options, width, height, textinfo, atlas, textures, arrow_scale, editable )
    Widget._ctor(self, "SPINNER")

	arrow_scale = arrow_scale or 1

	self.editable = editable or false
	self.options = options
	self.selectedIndex = 1
	self.textsize = {width = width, height = height}
	self.textcolour = { 1, 1, 1, 1 }
	
	self.atlas = atlas
    self.leftimage = self:AddChild( Image() )
    self.rightimage = self:AddChild( Image() )

	self.scaled_arrow_width = 0

	if atlas and textures then
		self:SetArrowTexture( textures.arrow_normal )
		self:SetArrowMouseOverTexture( textures.arrow_over )
		self:SetArrowDisabledTexture( textures.arrow_disabled )

		if textures.bgtexture then
			self.bgimage = self:AddChild( Image() )
			self.bgimage:SetTexture( self.atlas, textures.bgtexture )
			self.bgimage:ScaleToSize( self.textsize.width, self.textsize.height )
		end

		local arrow_width, arrow_height = self.leftimage:GetSize()

		arrow_scale = arrow_scale * height / arrow_height
		
		self.leftimage:SetScale( -arrow_scale, arrow_scale, 1 )
		self.rightimage:SetScale( arrow_scale, arrow_scale, 1 )
		self.scaled_arrow_width = arrow_width * arrow_scale
	end
	
	self.fgimage = self:AddChild( Image() )

	if editable then
	    self.text = self:AddChild( TextEdit( textinfo.font, textinfo.size ) )
	else
	    self.text = self:AddChild( Text( textinfo.font, textinfo.size ) )
	end
	self.text:SetRegionSize( self.textsize.width, self.textsize.height )
    self.text:Show()

	self.updating = false

    self.leftimage:SetLeftMouseDown(
		function()
			self:Prev()
		end )

    self.rightimage:SetLeftMouseDown(
		function()
			self:Next()
		end )

	local this = self
	self.leftimage:SetMouseOver(
		function( self )
			if this.enabled and this.leftimage.enabled then
				this:OnMouseOver()
			end
		end )

	self.rightimage:SetMouseOver(
		function( self )
			if this.enabled and this.rightimage.enabled then
				this:OnMouseOver()
			end
		end )

	self:Layout()
	self:SetSelectedIndex(1)
end)

function Spinner:OnMouseOver()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
	Widget.OnMouseOver( self )
end

function Spinner:SetArrowTexture(tex)
    self.leftimage:SetTexture(self.atlas, tex)
    self.rightimage:SetTexture(self.atlas, tex)
end

function Spinner:SetTextColour(r,g,b,a)
	self.textcolour = { r, g, b, a }
	self.text:SetColour( r, g, b, a )
end

function Spinner:SetArrowMouseOverTexture(tex)
    self.leftimage:SetMouseOverTexture(self.atlas, tex)
    self.rightimage:SetMouseOverTexture(self.atlas, tex)
end

function Spinner:SetArrowDisabledTexture(tex)
	self.leftimage:SetDisabledTexture(self.atlas, tex)
	self.rightimage:SetDisabledTexture(self.atlas, tex)
end

function Spinner:Enable()
	self._base.Enable(self)
	self.text:SetColour( self.textcolour )
	self:UpdateState()
end

function Spinner:Disable()
	self._base.Disable(self)
	self.text:SetColour(.7,.7,.7,1)
	self.leftimage:Disable()
	self.rightimage:Disable()
end

function Spinner:SetFont(font)
	self.text:SetFont(font)
end

function Spinner:SetOnClick( fn )
    self.onclick = fn
end

function Spinner:SetImage(tex)
    self.normaltex = tex
    self.image:SetTexture(tex)
end

function Spinner:SetMouseOverImage(tex)
    self.mouseovertex = tex
end

function Spinner:SetDisabledImage(tex)
    self.disabledtex = tex
end

function Spinner:SetTextSize(sz)
	self.text:SetSize(sz)
end

function Spinner:GetWidth()
	return self.scaled_arrow_width + self.textsize.width
end

function Spinner:Layout()
	self.leftimage:SetPosition( 0, 0, 0 )
	local x = 0.5 * self.scaled_arrow_width + 0.5 * self.textsize.width
	if self.bgimage then
		self.bgimage:SetPosition( x, 0, 0 )
	end
	if self.fgimage then
		self.fgimage:SetPosition( x, 0, 0 )
	end
	self.text:SetPosition( x, 0, 0 )
	self.rightimage:SetPosition( self.scaled_arrow_width + self.textsize.width, 0, 0 )
end

function Spinner:SetTextHAlign( align )
    self.text:SetHAlign( align )
end

function Spinner:SetTextVAlign( align )
    self.text:SetVAlign( align )
end

function Spinner:Next()
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex + 1
			if newSelection > self:MaxIndex() then
				newSelection = self:MinIndex()
			end
		else
			newSelection = math.min( newSelection + 1, self:MaxIndex() )
		end
	end
	if newSelection ~= oldSelection then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		self:OnNext()
		self:SetSelectedIndex(newSelection)
		self:Changed()
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:Prev()
	local oldSelection = self.selectedIndex
	local newSelection = oldSelection
	if self.enabled then
		if self.enableWrap then
			newSelection = self.selectedIndex - 1
			if newSelection < self:MinIndex() then
				newSelection = self:MaxIndex()
			end
		else
			newSelection = math.max( self.selectedIndex - 1, self:MinIndex() )
		end
	end
	if newSelection ~= oldSelection then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		self:OnPrev()
		self:SetSelectedIndex(newSelection)
		self:Changed()
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
	end
end

function Spinner:GetSelected()
	return self.options[ self.selectedIndex ]
end

function Spinner:GetSelectedIndex()
	return self.selectedIndex
end

function Spinner:GetSelectedText()
	return self.options[ self.selectedIndex ].text
end

function Spinner:GetSelectedImage()
	return self.options[ self.selectedIndex ].image
end

function Spinner:GetSelectedData()
	return self.options[ self.selectedIndex ].data
end

function Spinner:SetSelectedIndex( idx )
	self.updating = true
	self.selectedIndex = math.max(self:MinIndex(), math.min(self:MaxIndex(), idx))
	
	local selected_text = self:GetSelectedText()	
	self:UpdateText( selected_text )
	
	if self.options[ self.selectedIndex ] ~= nil then 
		local selected_image = self:GetSelectedImage()
		if selected_image ~= nil then
			self.fgimage:SetTexture( selected_image )
		end
	end
	
	self:UpdateState()
	self.updating = false
end

function Spinner:SetSelected( data )
	
	for k,v in pairs(self.options) do
		if v.data == data then
			self:SetSelectedIndex(k)			
			return
		end
	end
end

function Spinner:UpdateText( msg )
	self.text:SetString(msg)
end

function Spinner:GetText()
	return self.text:GetString()
end

function Spinner:OnNext()
end

function Spinner:OnPrev()
end

function Spinner:Changed()
	if not self.updating then
		self:OnChanged( self:GetSelectedData() )
		self:UpdateState()
	end
end

function Spinner:OnChanged( selected )
end

function Spinner:MinIndex()
	return 1
end

function Spinner:MaxIndex()
	return #self.options
end

function Spinner:SetWrapEnabled(enable)
	self.enableWrap = enable
	self:UpdateState()
end

function Spinner:UpdateState()
	if self.enabled then
		self.leftimage:Enable()
		self.rightimage:Enable()
		if not self.enableWrap then
			if self.selectedIndex == self:MinIndex() then
				self.leftimage:Disable()
			end
			if self.selectedIndex == self:MaxIndex() then
				self.rightimage:Disable()
			end
		end
	else
		self.leftimage:Disable()
		self.rightimage:Disable()
	end
end

function Spinner:Update(dt)
	--print("Spinner:Update", dt)
end

function Spinner:OnUpdate(dt)
	--print("Spinner:OnUpdate", dt)
end

function Spinner:SetOptions( options )
	self.options = options
	if self.selectedIndex > #self.options then
		self:SetSelectedIndex( #self.options )
	end
	self:UpdateState()
end
