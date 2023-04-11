require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "os"

require "screens/worldgenscreen"
require "screens/popupdialog"
require "screens/playerhud"
require "screens/optionsscreen"
require "screens/emailsignupscreen"
require "screens/loadgamescreen"
require "screens/creditsscreen"
require "screens/modsscreen"


MainScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "MainScreen")
    self.profile = profile
	self.log = true
	self:AddEventHandler("onsetplayerid", function(...) self:OnSetPlayerID(...) end)
	self:DoInit() 
end)

function MainScreen:OnSetPlayerID(playerid)
	if self.playerid then
		self.playerid:SetString(STRINGS.UI.MAINSCREEN.GREETING.. " "..playerid)
	end
end

function MainScreen:OnGainFocus()
	self._base.OnGainFocus(self)
	--TheFrontEnd:DoFadeIn(2)
end

function MainScreen:OnLoseFocus()
end


function MainScreen:OnKeyUp( key )
	if CHEATS_ENABLED then
		if key == KEY_ENTER then
			if TheInput:IsKeyDown(KEY_CTRL) then
				SaveGameIndex:DeleteSlot(1,
					function() 
						TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = 1})
						TheSim:Reset()
					end)
			elseif not SaveGameIndex:GetCurrentMode(1) then
				local function onsaved()
				    local params = json.encode{reset_action="loadslot", save_slot = 1}
				    TheSim:SetInstanceParameters(params)
				    TheSim:Reset()
				end
				SaveGameIndex:StartSurvivalMode(1, "wilson", {}, onsaved)
			else
    			TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = 1})
    			TheSim:Reset()
    		end
		elseif key >= KEY_1 and key <= KEY_7 then
			local level_num = key - KEY_1 + 1
			
			local function onstart()
				TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = 1})
				TheSim:Reset()
			end
			SaveGameIndex:FakeAdventure(onstart, 1, level_num)    		
		elseif key == KEY_0 then
			local function onstart()
				TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = 1})
				TheSim:Reset()
			end
			SaveGameIndex:DeleteSlot(1, function() SaveGameIndex:EnterCave(onstart, 1, 1) end)
		elseif key == KEY_9 then
			local function onstart()
				TheSim:SetInstanceParameters(json.encode{reset_action="loadslot", save_slot = 1})
				TheSim:Reset()
			end
			SaveGameIndex:DeleteSlot(1, function() SaveGameIndex:EnterCave(onstart, 1, 1, 2) end)
		elseif key == KEY_MINUS then
			TheSim:SetInstanceParameters(json.encode{reset_action="test", save_slot = 1})
			TheSim:Reset()
		elseif key == KEY_M then
			self:OnModsButton()
		end
			
	    	
	elseif key == KEY_ESCAPE then
		self:MainMenu()
	end
end


local function MakeMenu(offset, menuitems)
	local menu = Widget("MainMenu")	
	local pos = Vector3(0,0,0)
	for k,v in ipairs(menuitems) do
		local button = menu:AddChild(AnimButton("button"))
	    button:SetPosition(pos)
	    button:SetText(v.text)
	    button.text:SetColour(0,0,0,1)
	    button:SetOnClick( v.cb )
	    button:SetFont(BUTTONFONT)
	    button:SetTextSize(40)    
	    pos = pos + offset  
	end
	return menu
end

function MainScreen:Buy()
	TheSim:SendJSMessage("MainScreen:Buy")
	TheFrontEnd:GetSound():KillSound("FEMusic")
end

function MainScreen:EnterKey()
	TheSim:SendJSMessage("MainScreen:EnterKey")
end

function MainScreen:SendGift()
	TheSim:SendJSMessage("MainScreen:Gift")
	TheFrontEnd:GetSound():KillSound("FEMusic")
end

function MainScreen:ProductKeys()
	TheSim:SendJSMessage("MainScreen:ProductKeys")
end

local function CheckTesting(fn)
	return function()
		
		if BRANCH == "staging" then
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.TESTING, STRINGS.UI.MAINSCREEN.TESTINGDETAIL,{
						{text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() fn() end},
						{text=STRINGS.UI.MAINSCREEN.TESTINGNO, cb = function() end}  
						}))
		else
			fn()
		end
	end
end


function MainScreen:Settings()
	TheFrontEnd:PushScreen(OptionsScreen(false))
end

function MainScreen:EmailSignup()
	TheFrontEnd:PushScreen(EmailSignupScreen())
end

function MainScreen:Forums()
	VisitURL("http://forums.kleientertainment.com/forumdisplay.php?20")
end

function MainScreen:Rate()
	TheSim:SendJSMessage("MainScreen:Rate")
end

function MainScreen:Logout()
	TheSim:SendJSMessage("MainScreen:Logout")
end

function MainScreen:Quit()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },{text=STRINGS.UI.MAINSCREEN.NO, cb = function() end}  }))
end

local function get_timezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end

local function GetDaysToUpdate()
    --require("date")
    local local_tz = get_timezone()
    
    local klei_tz = 28800--The time zone offset for vancouver
    local update_times =
		{
			os.time{year=2013, day=9, month=4, hour=13} - klei_tz,
			os.time{year=2013, day=18, month=4, hour=13} - klei_tz,
			os.time{year=2013, day=21, month=5, hour=13} - klei_tz,
			os.time{year=2013, day=11, month=6, hour=13} - klei_tz,
			os.time{year=2013, day=2, month=7, hour=13} - klei_tz,
			os.time{year=2013, day=23, month=7, hour=13} - klei_tz,
		}
    table.sort(update_times)
    
    local build_time = TheSim:GetBuildDate()
    
    local last_build = build_time
    local now = os.time() - local_tz
    
    for k,v in ipairs(update_times) do
		if v > build_time then
			local seconds = v - now
			return math.ceil( (((seconds / 60) / 60) / 24) ), math.ceil( ((((now - last_build) / 60) / 60) / 24) )
		else
			last_build = v
		end
    end
end


function MainScreen:OnExitButton()
	if PLATFORM == "NACL" then
		self:Logout()
	else
		self:Quit()
	end
end


	
	
function MainScreen:UpdateDaysUntil()
	local days_until, days_since = GetDaysToUpdate()
	if days_until and days_since then
		if days_since <= 1 then
			self.days_since_string = string.format(STRINGS.UI.MAINSCREEN.FRESHBUILD)
		else
			self.days_since_string = string.format(STRINGS.UI.MAINSCREEN.LASTBUILDDAYS, days_since)
		end
		
		if days_until <= 1 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTBUILDIMMINENT)
		else
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTUPDATEDAYS, days_until) 
		end

		if days_until < 2 then
			self.daysuntilanim:GetAnimState():PlayAnimation("coming", true)
		elseif days_until < 7 then
			self.daysuntilanim:GetAnimState():PlayAnimation("about", true)
		else
			self.daysuntilanim:GetAnimState():PlayAnimation("fresh", true)
		end
		
		self.daysuntiltext:SetString( self.days_until_string)
	    
		self.daysuntilanim:SetMouseOver(function() 
				self.daysuntiltext:SetString( self.days_since_string)
			end)

		self.daysuntilanim:SetMouseOut(function() 
				self.daysuntiltext:SetString( self.days_until_string)
			end)
	else
		self.daysuntilanim:Hide()
		self.daysuntiltext:Hide()
	end
end


function MainScreen:DoInit( )
	
	TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")

	if PLATFORM == "NACL" then	
		TheSim:RequestPlayerID()
	end

	self.bg = self:AddChild(Image("data/images/ui.xml", "bg_plain.tex"))
    self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    local left_buffer = 175
    
--[[self.hand2 = self:AddChild(UIAnim())
    self.hand2:GetAnimState():SetBuild("creepy_hands")
    self.hand2:GetAnimState():SetBank("creepy_hands")
    self.hand2:GetAnimState():PlayAnimation("idle", true)
    self.hand2:GetAnimState():SetTime(0)
    self.hand2:SetVAnchor(ANCHOR_TOP)
    self.hand2:SetHAnchor(ANCHOR_RIGHT)
    self.hand2:SetPosition(-200, 0, 0)
    self.hand2:SetRotation(30)
    
    local hand_scale = 2
    local w,h = TheSim:GetScreenSize()
    if h < RESOLUTION_Y then
		hand_scale = 2*(h/RESOLUTION_Y)
    end
    self.hand2:SetScale(hand_scale,-hand_scale,hand_scale)
--]]
    
    self.shield = self.fixed_root:AddChild(Image("data/images/panel_shield.xml", "panel_shield.tex"))
    self.shield:SetVRegPoint(ANCHOR_MIDDLE)
    self.shield:SetHRegPoint(ANCHOR_MIDDLE)

    self.banner = self.shield:AddChild(Image("data/images/ui.xml", "update_banner.tex"))
    self.banner:SetVRegPoint(ANCHOR_MIDDLE)
    self.banner:SetHRegPoint(ANCHOR_MIDDLE)
    self.banner:SetPosition(0, -210, 0)
    self.updatename = self.banner:AddChild(Text(BUTTONFONT, 30))
    self.updatename:SetPosition(0,8,0)
    local suffix = ""
    if BRANCH == "dev" then
		suffix = " (internal)"
    elseif BRANCH == "staging" then
		suffix = " (preview)"
    end
    self.updatename:SetString(STRINGS.UI.MAINSCREEN.UPDATENAME .. suffix)
    self.updatename:SetColour(0,0,0,1)

	--bottom left node - days until update indicator and sign up button    
	self.bottom_left_stuff = self.fixed_root:AddChild(Widget("bl"))
	self.bottom_left_stuff:SetPosition(-RESOLUTION_X/2 + left_buffer, -RESOLUTION_Y/2 + 200, 0)
	
	self.signup_button = self.bottom_left_stuff:AddChild(AnimButton("button"))
    self.signup_button:SetPosition(0, -150, 0)
    self.signup_button:SetText(STRINGS.UI.MAINSCREEN.NOTIFY)
    self.signup_button.text:SetColour(0,0,0,1)
    self.signup_button:SetFont(BUTTONFONT)
    self.signup_button:SetTextSize(40)    
    self.signup_button:SetOnClick( function() self:EmailSignup() end )

    self.daysuntilanim = self.bottom_left_stuff:AddChild(UIAnim())
    self.daysuntilanim:GetAnimState():SetBuild("build_status")
    self.daysuntilanim:GetAnimState():SetBank("build_status")
    self.daysuntilanim:SetPosition(20,0,0)
    
    self.daysuntiltext = self.bottom_left_stuff:AddChild(Text(UIFONT, 30))
    self.daysuntiltext:SetHAlign(ANCHOR_MIDDLE)
    self.daysuntiltext:SetPosition(0,-80,0)
	self.daysuntiltext:SetRegionSize( 200, 50 )
	self.daysuntiltext:SetClickable(false)
	self:UpdateDaysUntil()
	
    
	self.motd = self.fixed_root:AddChild(Widget("motd"))
	self.motd:SetScale(.9,.9,.9)
	self.motd:SetPosition(-RESOLUTION_X/2+left_buffer, RESOLUTION_Y/2-200, 0)
	
	self.motdbg = self.motd:AddChild( Image( "data/images/panel.xml", "panel.tex" ) )
	self.motdbg:SetScale(.75*.9,.75,.75)
	self.motd.motdtitle = self.motdbg:AddChild(Text(TITLEFONT, 50))
    self.motd.motdtitle:SetPosition(0, 130, 0)
	self.motd.motdtitle:SetRegionSize( 350, 60)
	self.motd.motdtitle:SetString(STRINGS.UI.MAINSCREEN.MOTDTITLE)

	self.motd.motdtext = self.motd:AddChild(Text(NUMBERFONT, 30))
    self.motd.motdtext:SetHAlign(ANCHOR_MIDDLE)
    self.motd.motdtext:SetVAlign(ANCHOR_TOP)
    self.motd.motdtext:SetPosition(0, -20, 0)
	self.motd.motdtext:SetRegionSize( 250, 160)
	self.motd.motdtext:SetString(STRINGS.UI.MAINSCREEN.MOTD)
	
	self.motd.button = self.motd:AddChild(AnimButton("button"))
    self.motd.button:SetPosition(0, -100, 0)
    self.motd.button:SetText(STRINGS.UI.MAINSCREEN.MOTDBUTTON)
    self.motd.button.text:SetColour(0,0,0,1) 
    self.motd.button:SetOnClick( function() VisitURL("http://bit.ly/ds-soundtrack") end )
    self.motd.button:SetFont(BUTTONFONT)
    self.motd.button:SetTextSize(40)    
	self.motd.motdtext:EnableWordWrap(true)   
	
    
	self.playerid = self.fixed_root:AddChild(Text(NUMBERFONT, 35))
	self.playerid:SetPosition(RESOLUTION_X/2 -400, RESOLUTION_Y/2 -60, 0)    
	self.playerid:SetRegionSize( 600, 50)
	self.playerid:SetHAlign(ANCHOR_RIGHT)
	self:MainMenu()
end


local menu_spacing = 60
local bottom_offset = 60


function MainScreen:Refresh()
	self:MainMenu()
	TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
end

function MainScreen:ShowMenu(menu_items)
	if self.menu then
		self.menu:Kill()
	end	

	self.menu = self.fixed_root:AddChild(MakeMenu( Vector3(0, -menu_spacing, 0), menu_items))
	
	self.menu:SetPosition(RESOLUTION_X/2 -200 ,-RESOLUTION_Y/2 + bottom_offset + menu_spacing * (#menu_items-1),0)
	
	if PLATFORM == "NACL" then
		if self.purchasebutton then
			self.purchasebutton:Kill()
			self.purchasebutton = nil
		end
		
		self.purchasebutton = self.fixed_root:AddChild(Button())
		self.purchasebutton:SetImage("data/images/ui.xml", "special_button.tex")
		self.purchasebutton:SetMouseOverImage("data/images/ui.xml", "special_button_over.tex")
		self.purchasebutton:SetScale(.5,.5,.5)
		self.purchasebutton:SetPosition(RESOLUTION_X/2 -200 ,-RESOLUTION_Y/2 + bottom_offset + menu_spacing * (#menu_items) + 40,0)
		self.purchasebutton.text:SetColour(0,0,0,1)
		self.purchasebutton:SetFont(BUTTONFONT)
		self.purchasebutton:SetTextSize(80)

		if not IsGamePurchased() then
			self.purchasebutton:SetOnClick( function() self:Buy() end)
			self.purchasebutton:SetText( STRINGS.UI.MAINSCREEN.BUYNOW )
		else
			self.purchasebutton:SetOnClick( function() self:SendGift() end)
			self.purchasebutton:SetText( STRINGS.UI.MAINSCREEN.GIFT )
		end	
	end
end


function MainScreen:DoOptionsMenu()
	local menu_items = {}
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.SETTINGS, cb= function() self:Settings() end})
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.ENTERKEY, cb= function() self:EnterKey() end})
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.CANCEL, cb= function() self:MainMenu() end})
	self:ShowMenu(menu_items)
end

function MainScreen:OnModsButton()
	TheFrontEnd:PushScreen(ModsScreen(function(needs_reset)
		if needs_reset then
			TheSim:Reset()
		end

		TheFrontEnd:PopScreen()
	end))
end

function MainScreen:ResetProfile()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.RESETPROFILE, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:Reset() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() end}  }))
end

function MainScreen:UnlockEverything()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:UnlockEverything() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() end}  }))
end

function MainScreen:OnCreditsButton()
	TheFrontEnd:GetSound():KillSound("FEMusic")
	TheFrontEnd:PushScreen( CreditsScreen() )
end
	
function MainScreen:CheatMenu()
	local menu_items = {}
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, cb= function() self:UnlockEverything() end})
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.RESETPROFILE, cb= function() self:ResetProfile() end})
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.CANCEL, cb= function() self:MainMenu() end})
	self:ShowMenu(menu_items)
end

local function DoGenerateDEMOWorld()
	local saveslot = 1

	local function onComplete(savedata )
		local function onsaved()
			local success, world_table = RunInSandbox(savedata)
			if success then
				DoInitGame(SaveGameIndex:GetSlotCharacter(saveslot), world_table, Profile)
			end
		end

		SaveGameIndex:OnGenerateNewWorld(saveslot, savedata, onsaved)
	end

	local function LoadWorldGenScreen()
		local world_gen_options =
		{
			level_type = "survival",
			custom_options ={character ="wilson", current_mode="survival"},
			level_world = 1,
		}
		TheFrontEnd:PushScreen(WorldGenScreen(Profile, onComplete, world_gen_options))
	end
	
	SaveGameIndex:StartSurvivalMode(1,"wilson", nil, LoadWorldGenScreen)
end

function MainScreen:MainMenu()
	local menu_items = {}
	local purchased = IsGamePurchased()
	if purchased then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.PLAY, cb= function() 
			
			TheFrontEnd:PushScreen(LoadGameScreen())
		end})
		
		if PLATFORM == "NACL" then
			table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.RATE, cb=function() self:Rate() end})		
		end
	else
		table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.PLAYDEMO, cb= function() DoGenerateDEMOWorld() end})
		table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.ENTERPRODUCTKEY, cb= function() self:EnterKey() end})
	end

	
	if PLATFORM == "NACL" and purchased then
		table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.OPTIONS, cb= function() self:DoOptionsMenu() end})
	else
		table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.SETTINGS, cb= function() self:Settings() end})
	end
	
	if PLATFORM == "NACL" then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.ACCOUNTINFO, cb= function() self:ProductKeys() end})
	end
	
	if PLATFORM == "WIN32_STEAM" then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.MOREGAMES, cb= function() VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment") end})
	end
		
	table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.CREDITS, cb= function() self:OnCreditsButton() end})
	table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.FORUM, cb= function() self:Forums() end})
	
	if PLATFORM == "NACL" then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.LOGOUT, cb= function() self:OnExitButton() end})
	else
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.EXIT, cb= function() self:OnExitButton() end})
	end

	if PLATFORM ~= "NACL" then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.MODS, cb= function() self:OnModsButton() end})
	end


	if BRANCH ~= "release" then
		table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.CHEATS, cb= function() self:CheatMenu() end})
	end
	
	self:ShowMenu(menu_items)
end
