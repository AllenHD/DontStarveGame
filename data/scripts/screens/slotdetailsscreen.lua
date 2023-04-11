require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "os"

SlotDetailsScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "LoadGameScreen")
    self.profile = Profile
    self.saveslot = slotnum

	local mode = SaveGameIndex:GetCurrentMode(slotnum)
	local day = SaveGameIndex:GetSlotDay(slotnum)
	local world = SaveGameIndex:GetSlotWorld(slotnum)
	local character = SaveGameIndex:GetSlotCharacter(slotnum) or "wilson"
	self.character = character

    
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
    self.bg = self.root:AddChild(Image("data/images/panel_saveslots.xml", "panel_saveslots.tex"))
    
	--[[self.cancelbutton = self.root:AddChild(AnimButton("button"))
	self.cancelbutton:SetScale(.8,.8,.8)
    self.cancelbutton:SetText(STRINGS.UI.SLOTDETAILSSCREEN.CANCEL)
    self.cancelbutton:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(35)
    self.cancelbutton.text:SetVAlign(ANCHOR_MIDDLE)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetPosition( 0, -235, 0)--]]
    
    --[[self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 0, 230, 0)
    self.title:SetRegionSize(250,70)
    self.title:SetString(STRINGS.UI.SLOTDETAILSSCREEN.TITLE .. " " .. tostring(slotnum))
    self.title:SetVAlign(ANCHOR_MIDDLE)--]]

    self.text = self.root:AddChild(Text(TITLEFONT, 60))
    self.text:SetPosition( 75, 135, 0)
    self.text:SetRegionSize(250,60)
    self.text:SetHAlign(ANCHOR_LEFT)


	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, character..".tex")
	self.portrait:SetPosition(-120, 135, 0)
    

    self:BuildMenu()
   
end)

function SlotDetailsScreen:BuildMenu()


	local mode = SaveGameIndex:GetCurrentMode(self.saveslot)
	local day = SaveGameIndex:GetSlotDay(self.saveslot)
	local world = SaveGameIndex:GetSlotWorld(self.saveslot)
	local character = SaveGameIndex:GetSlotCharacter(self.saveslot) or "wilson"


	if self.menu then
		self.menu:Kill()
	end

	self.menu = self.root:AddChild(Widget("menu"))

    local menuitems = 
    {
		{name = STRINGS.UI.SLOTDETAILSSCREEN.CONTINUE, fn = function() self:Continue() end},
		{name = STRINGS.UI.SLOTDETAILSSCREEN.DELETE, fn = function() self:Delete() end},
		{name = STRINGS.UI.SLOTDETAILSSCREEN.CANCEL, fn = function() TheFrontEnd:PopScreen(self) end},
		
	}

	if mode == "adventure" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
	elseif mode == "survival" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
	elseif mode == "cave" then
		self.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.CAVE, world, day))
	else
		--shouldn't actually happen...
		self.text:SetString(string.format("%s",STRINGS.UI.LOADGAMESCREEN.NEWGAME))
	end 
    
    for k,v in pairs(menuitems) do
    	local button = self.menu:AddChild(AnimButton("button"))
		--button:SetScale(.8,.8,.8)
		button:SetText(v.name)
		button:SetOnClick( v.fn )
		button:SetFont(BUTTONFONT)
		button:SetTextSize(40)
		button.text:SetVAlign(ANCHOR_MIDDLE)
		button.text:SetColour(0,0,0,1)
		button:SetPosition( 0, 50 - k*65, 0)
    end

end

function SlotDetailsScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		TheFrontEnd:PopScreen(self)
	end
end


function SlotDetailsScreen:Delete()

	local menu_items = 
	{
		-- ENTER
		{
			text=STRINGS.UI.MAINSCREEN.DELETE, 
			cb = function()
				SaveGameIndex:DeleteSlot(self.saveslot, function() TheFrontEnd:PopScreen(self) end)
			end
		},
		-- ESC
		{text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() end},
	}

	TheFrontEnd:PushScreen(
		PopupDialogScreen(STRINGS.UI.MAINSCREEN.DELETE.." "..STRINGS.UI.MAINSCREEN.SLOT.." "..self.saveslot, STRINGS.UI.MAINSCREEN.SURE, menu_items ) )

end

function SlotDetailsScreen:Continue()

	self.root:Disable()
	TheFrontEnd:Fade(false, 1, function() 
		TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = self.saveslot})
		TheSim:Reset()
	 end)
end
