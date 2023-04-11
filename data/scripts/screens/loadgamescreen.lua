require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "os"
require "screens/slotdetailsscreen"
require "screens/newgamescreen"
require "fileutil"



LoadGameScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "LoadGameScreen")
    self.profile = profile
    
    self.black = self:AddChild(Image("data/images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
    self.bg = self.root:AddChild(Image("data/images/panel_saveslots.xml", "panel_saveslots.tex"))
    
    --self.bg:SetPosition(150, daysuntil_offset + 128, 0)
    --SetDebugEntity(self.daysuntilanim.inst)
	
	self.button = self.root:AddChild(AnimButton("button"))
	--self.button:SetScale(.8,.8,.8)
    self.button:SetText(STRINGS.UI.LOADGAMESCREEN.CANCEL)
    self.button:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
    self.button:SetFont(BUTTONFONT)
    self.button:SetTextSize(35)
    self.button.text:SetVAlign(ANCHOR_MIDDLE)
    self.button.text:SetColour(0,0,0,1)
    self.button:SetPosition( 0, -250, 0)
    
    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 0, 215, 0)
    self.title:SetRegionSize(250,70)
    self.title:SetString(STRINGS.UI.LOADGAMESCREEN.TITLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	self:RefreshFiles()  
end)


function LoadGameScreen:OnGainFocus()
	self._base.OnGainFocus(self)
	self:RefreshFiles()
end


function LoadGameScreen:RefreshFiles()
	if self.menu then
		self.menu:Kill()
	end

	self.menu = self.root:AddChild(Widget("menu"))
	for k = 1, 4 do
		local tile = self:MakeSaveTile(k)
		self.menu:AddChild(tile)
		tile:SetPosition(0, 235 - k * 100, 0)
	end
	
end

function LoadGameScreen:MakeSaveTile(slotnum)
	
	local widget = Widget("savetile")
	widget.base = widget:AddChild(Widget("base"))
	
	local mode = SaveGameIndex:GetCurrentMode(slotnum)
	local day = SaveGameIndex:GetSlotDay(slotnum)
	local world = SaveGameIndex:GetSlotWorld(slotnum)
	local character = SaveGameIndex:GetSlotCharacter(slotnum)
	
    widget.bg = widget.base:AddChild(UIAnim())
    widget.bg:GetAnimState():SetBuild("savetile")
    widget.bg:GetAnimState():SetBank("savetile")
    widget.bg:GetAnimState():PlayAnimation("anim")
	
	--[[widget.portrait_bg = widget.playerimage:AddChild(Image("data/images/hud.xml", "portrait_bg.tex"))
	widget.portrait_bg:SetClickable(false)		
	widget.portrait_bg:SetScale(.6,.6,1)
	widget.portrait_bg:SetVRegPoint(ANCHOR_MIDDLE)
   	widget.portrait_bg:SetHRegPoint(ANCHOR_MIDDLE)--]]
	
	widget.portraitbg = widget.base:AddChild(Image("data/images/saveslot_portraits.xml", "background.tex"))
	widget.portraitbg:SetScale(.65,.65,1)
	widget.portraitbg:SetPosition(-120 + 40, 2, 0)	
	widget.portraitbg:SetClickable(false)	
	
	widget.portrait = widget.base:AddChild(Image())
	--widget.portrait:SetVRegPoint(ANCHOR_MIDDLE)
   	--widget.portrait:SetHRegPoint(ANCHOR_MIDDLE)
	widget.portrait:SetClickable(false)	
	if character and mode then	
		local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
		widget.portrait:SetTexture(atlas, character..".tex")
	else
		widget.portraitbg:Hide()
	end
	widget.portrait:SetScale(.65,.65,1)
	widget.portrait:SetPosition(-120 + 40, 2, 0)	
	
	
    widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
    widget.text:SetPosition(40,0,0)
    widget.text:SetRegionSize(200 ,70)
    
    if not mode then
		widget.text:SetString(STRINGS.UI.LOADGAMESCREEN.NEWGAME)
		widget.text:SetPosition(0,0,0)
	elseif mode == "adventure" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
	elseif mode == "survival" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
	elseif mode == "cave" then
		local level = SaveGameIndex:GetCurrentCaveLevel(slotnum)
		widget.text:SetString(string.format("%s %d",STRINGS.UI.LOADGAMESCREEN.CAVE, level))
	end
	
    widget.text:SetVAlign(ANCHOR_MIDDLE)
    --widget.text:EnableWordWrap(true)
    
	widget:SetMouseOver(
        function()
        	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			widget:SetScale(1.1,1.1,1)
			widget.bg:GetAnimState():PlayAnimation("over")
        end)

    widget:SetMouseOut(
        function()
        	widget.base:SetPosition(0,0,0)
			widget:SetScale(1,1,1)
			widget.bg:GetAnimState():PlayAnimation("anim")
        end)
        
	widget:SetLeftMouseDown( function() widget.base:SetPosition(0,-5,0)end )
	widget:SetLeftMouseUp( function() widget.base:SetPosition(0,0,0) self:OnClickTile(slotnum) end )
        
	return widget
end

function LoadGameScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		TheFrontEnd:PopScreen(self)
	end
end

function LoadGameScreen:OnClickTile(slotnum)

	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")	
	if not SaveGameIndex:GetCurrentMode(slotnum) then
		TheFrontEnd:PushScreen(NewGameScreen(slotnum))
	else
		TheFrontEnd:PushScreen(SlotDetailsScreen(slotnum))
	end
end


