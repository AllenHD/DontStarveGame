require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "screens/optionsscreen"

local function dorestart()
	local player = GetPlayer()
	local purchased = IsGamePurchased()
	local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
	
	local postsavefn = function()
		if purchased then
			local player = GetPlayer()
			if player then
				player:PushEvent("quit", {})
			else
				TheSim:SetInstanceParameters()
				TheSim:Reset()
			end
		else
			ShowUpsellScreen(true)
			DEMO_QUITTING = true
		end	
	end
	
	local ground = GetWorld()
	assert(ground, "Must have some terrain to get the map info.")
		
	local level_number = ground.topology.level_number or 1
	local level_type = ground.topology.level_type or "free"
	local day_number = GetClock().numcycles + 1
							
	TheFrontEnd:Fade(false, 1, function() 
		if can_save then
			SaveGameIndex:SaveCurrent(postsavefn)
		else
			postsavefn()
		end
	end)
end


PauseScreen = Class(Screen, function(self)
	Screen._ctor(self, "PauseScreen")

	SetHUDPause(true,"pause")
	
	self:CreateButtons()
	self:CreateMenu()
end)

 function PauseScreen:doconfirmquit()
	local player = GetPlayer()
	local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
	local function doquit()
		self.menu:Disable()
		dorestart()
	end

	if can_save then
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.PAUSEMENU.SAVEANDQUITTITLE, STRINGS.UI.PAUSEMENU.SAVEANDQUITBODY, {{text=STRINGS.UI.PAUSEMENU.SAVEANDQUITYES, cb = doquit},{text=STRINGS.UI.PAUSEMENU.SAVEANDQUITNO, cb = function() end}  }))
	else
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.PAUSEMENU.QUITTITLE, STRINGS.UI.PAUSEMENU.QUITBODY, {{text=STRINGS.UI.PAUSEMENU.QUITYES, cb = doquit},{text=STRINGS.UI.PAUSEMENU.QUITNO, cb = function() end}  }))
	end
end

function PauseScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		TheFrontEnd:PopScreen(self) 
		SetHUDPause(false)
	end
end

function PauseScreen:CreateButtons()
	local player = GetPlayer()
	local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()

	PauseScreen.button_w = 150
	PauseScreen.space_between = 15
	PauseScreen.buttons = {
		{text=STRINGS.UI.PAUSEMENU.OPTIONS, cb=function() 
			TheFrontEnd:PushScreen( OptionsScreen(true))
		end },
		{text=can_save and STRINGS.UI.PAUSEMENU.SAVEANDQUIT or STRINGS.UI.PAUSEMENU.QUIT, cb=function() self:doconfirmquit() end},
		{text=STRINGS.UI.PAUSEMENU.CONTINUE, cb=function() TheFrontEnd:PopScreen(self) SetHUDPause(false) end },
	}


end

function PauseScreen:CreateMenu()
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
	
	--title	
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 50, 0)
    self.title:SetString(STRINGS.UI.PAUSEMENU.TITLE)

	--create the menu itself
	local spacing = PauseScreen.button_w + PauseScreen.space_between
	
	self.menu = self.proot:AddChild(Widget("menu"))
	local total_w = #PauseScreen.buttons*PauseScreen.button_w
	if #PauseScreen.buttons > 1 then
		total_w = total_w + PauseScreen.space_between*(#PauseScreen.buttons-1) 
	end
	
	self.menu:SetPosition(-(total_w / 2) + PauseScreen.button_w/2, -40,0) 
	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(PauseScreen.buttons) do
		local button = self.menu:AddChild(AnimButton("button"))
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    button:SetOnClick( function() v.cb() end )
		button.text:SetColour(0,0,0,1)
	    button:SetFont(BUTTONFONT)
	    button:SetTextSize(40)    
	    pos = pos + Vector3(spacing, 0, 0)  
	end
end

