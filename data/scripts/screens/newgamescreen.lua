require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "os"
require "screens/worldgenscreen"
require "screens/customizationscreen"
require "screens/characterselectscreen"

NewGameScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "LoadGameScreen")
    self.profile = Profile
    self.saveslot = slotnum
    self.character = "wilson"

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bg = self.root:AddChild(Image("data/images/panel_saveslots.xml", "panel_saveslots.tex"))
    
	--[[self.cancelbutton = self.root:AddChild(AnimButton("button"))
	self.cancelbutton:SetScale(.8,.8,.8)
    self.cancelbutton:SetText(STRINGS.UI.NEWGAMESCREEN.CANCEL)
    self.cancelbutton:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(35)
    self.cancelbutton.text:SetVAlign(ANCHOR_MIDDLE)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetPosition( 0, -235, 0)
    --]]
    
    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 0, 200, 0)
    self.title:SetRegionSize(250,70)
    self.title:SetString(STRINGS.UI.NEWGAMESCREEN.TITLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)


	self.portraitbg = self.root:AddChild(Image("data/images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(0,100,0)	
	self.portraitbg:SetClickable(false)	


	self.portrait = self.root:AddChild(Image())
	self.portrait:SetVRegPoint(ANCHOR_MIDDLE)
   	self.portrait:SetHRegPoint(ANCHOR_MIDDLE)
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, self.character..".tex")
	self.portrait:SetPosition(0, 100, 0)
    
    local menuitems = 
    {
		{name = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, fn = function() self:ChangeCharacter() end},
		{name = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, fn = function() self:Customize() end},
		{name = STRINGS.UI.NEWGAMESCREEN.START, fn = function() self:Start() end},
		{name = STRINGS.UI.NEWGAMESCREEN.CANCEL, fn = function() TheFrontEnd:PopScreen(self) end},
		
    }
    
    for k,v in pairs(menuitems) do
    	local button = self.root:AddChild(AnimButton("button_long"))
		--button:SetScale(.8,.8,.8)
		button:SetText(v.name)
		button:SetOnClick( v.fn )
		button:SetFont(BUTTONFONT)
		button:SetTextSize(40)
		button.text:SetVAlign(ANCHOR_MIDDLE)
		button.text:SetColour(0,0,0,1)
		button:SetPosition( 0, 50 - k*65, 0)
    end
    
end)


function NewGameScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		TheFrontEnd:PopScreen(self)
	end
end

function NewGameScreen:Customize( )
	
	local function onSet(options)
		TheFrontEnd:PopScreen()
		if options then
			self.customoptions = options
		end
	end
	TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions))
end

function NewGameScreen:ChangeCharacter(  )
	
	local function onSet(character)
		TheFrontEnd:PopScreen()
		if character then

			self.character = character

			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
		end
	end
	TheFrontEnd:PushScreen(CharacterSelectScreen(Profile, onSet, false, self.character))
end



function NewGameScreen:Start()
	local function onsaved()
	    local params = json.encode{reset_action="loadslot", save_slot = self.saveslot}
	    TheSim:SetInstanceParameters(params)
	    TheSim:Reset()
	end

	self.root:Disable()
	TheFrontEnd:Fade(false, 1, function() SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved) end )
end
