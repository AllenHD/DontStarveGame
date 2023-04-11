require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"


ScriptErrorScreen = Class(Screen, function(self, title, text, buttons, texthalign, additionaltext, textsize, timeout)
	Screen._ctor(self, "ScriptErrorScreen")

	--darken everything behind the dialog
	self.blackoverlay = self:AddChild(Image("data/images/global.xml", "square.tex"))
	local w, h = self.blackoverlay:GetSize()

	--throw up the background
	self.bg = self:AddChild(Image("data/images/ui.xml", "bg_plain.tex"))
    self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--title	
    self.title = self.root:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 170, 0)
    self.title:SetString(title)

	--text
	local defaulttextsize = 24
	if textsize then
		defaulttextsize = textsize
	end

	
    self.text = self.root:AddChild(Text(BODYTEXTFONT, defaulttextsize))
	self.text:SetVAlign(ANCHOR_TOP)

	if texthalign then
		self.text:SetHAlign(texthalign)
	end


    self.text:SetPosition(0, 40, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(480*2, 200)
    
    if additionaltext then
	    self.additionaltext = self.root:AddChild(Text(BODYTEXTFONT, 24))
		self.additionaltext:SetVAlign(ANCHOR_TOP)
	    self.additionaltext:SetPosition(0, -210, 0)
	    self.additionaltext:SetString(additionaltext)
	    self.additionaltext:EnableWordWrap(true)
	    self.additionaltext:SetRegionSize(480*2, 100)
    end
	
	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	self.menu = self.root:AddChild(Widget("menu"))
	local total_w = #buttons*button_w
	if #buttons > 1 then
		total_w = total_w + space_between*(#buttons-1) 
	end
	
	
	self.menu:SetPosition(-(total_w / 2) + button_w/2, -120,0) 
	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(buttons) do
		local button = self.menu:AddChild(AnimButton("button"))
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    if v.nopop == true then
	    	button:SetOnClick( function() v.cb() end )
	    else
	    	button:SetOnClick( function() TheFrontEnd:PopScreen(self) v.cb() end )
	    end
		button.text:SetColour(0,0,0,1)
	    button:SetFont(BUTTONFONT)
	    button:SetTextSize(40)    
	    pos = pos + Vector3(spacing, 0, 0)  
	end

	if timeout then
		self.timeout = timeout
	end
	
	self.buttons = buttons
end)



function ScriptErrorScreen:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end


function ScriptErrorScreen:OnKeyUp( key )
	if key == KEY_ENTER then
		if self.buttons[1] then
			TheFrontEnd:PopScreen(self) self.buttons[1].cb()
		end
	elseif key == KEY_ESCAPE then -- Last button
		if #self.buttons > 1 and self.buttons[#self.buttons] then
			TheFrontEnd:PopScreen(self) self.buttons[#self.buttons].cb()
		end
	end
end
