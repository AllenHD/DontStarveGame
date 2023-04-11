require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"


PopupDialogScreen = Class(Screen, function(self, title, text, buttons, timeout)
	Screen._ctor(self, "PopupDialogScreen")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("data/images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
    self.bg = self.proot:AddChild(Image("data/images/small_dialog.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2,1.2,1.2)
	
	if #buttons >2 then
		self.bg:SetScale(2,1.2,1.2)
	end
	
	--title	
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 65, 0)
    self.title:SetString(title)

	--text
    self.text = self.proot:AddChild(Text(BODYTEXTFONT, 30))

    self.text:SetPosition(0, 0, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(480, 70)
    
	
	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	self.menu = self.proot:AddChild(Widget("menu"))
	local total_w = #buttons*button_w
	if #buttons > 1 then
		total_w = total_w + space_between*(#buttons-1) 
	end
	
	self.menu:SetPosition(-(total_w / 2) + button_w/2, -65,0) 
	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(buttons) do
		local button = self.menu:AddChild(AnimButton("button"))
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    button:SetOnClick( function() TheFrontEnd:PopScreen(self) v.cb() end )
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



function PopupDialogScreen:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end


function PopupDialogScreen:OnKeyUp( key )
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
