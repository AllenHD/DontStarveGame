require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"

local function GetGenderStrings()
	local charactername = GetPlayer().profile:GetValue("characterinthrone") or "wilson"
	if charactername == "wilson" or
	charactername == "woodie" or
	charactername == "waxwell" or
	charactername == "wolfgang" or
	charactername == "wes" then
		return "MALE"
	elseif charactername == "willow" or
	charactername == "wendy" or
	charactername == "wickerbottom" then
		return "FEMALE"
	elseif charactername == "wx78" then
		return "ROBOT"
	else
		return "MALE"
	end
end



EndGameDialog = Class(Screen, function(self, buttons)
	Screen._ctor(self, "EndGameDialog")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("data/images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,1)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
    self.bg = self.proot:AddChild(Image("data/images/panel_upsell.xml", "panel_upsell.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(0.8,0.8,0.8)
	
	--title	
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 180, 0)
    self.title:SetString(STRINGS.UI.ENDGAME.TITLE)

	--text
    self.text = self.proot:AddChild(Text(BODYTEXTFONT, 30))
    self.text:SetVAlign(ANCHOR_TOP)

    self.text:SetPosition(0, -60, 0)
    self.text:SetString(STRINGS.UI.ENDGAME.BODY1..
    	STRINGS.CHARACTER_NAMES[GetPlayer().profile:GetValue("characterinthrone") or "wilson"]..
    	string.format(STRINGS.UI.ENDGAME.BODY2,STRINGS.UI.GENDERSTRINGS[GetGenderStrings()].ONE , STRINGS.UI.GENDERSTRINGS[GetGenderStrings()].TWO))
    self.text:EnableWordWrap(true)
    self.text:SetRegionSize(700, 350)
    
	
	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	self.menu = self.proot:AddChild(Widget("menu"))
	local total_w = #buttons*button_w
	if #buttons > 1 then
		total_w = total_w + space_between*(#buttons-1) 
	end
	
	self.menu:SetPosition(-(total_w / 2) + button_w/2, -220,0) 
	
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

	self.buttons = buttons
end)

function EndGameDialog:OnKeyUp( key )
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
