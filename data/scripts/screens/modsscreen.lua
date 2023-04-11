require "screen"
require "animbutton"
require "spinner"
require "textbutton"
require "numericspinner"
require "screens/popupdialog"
require "widgets/toggle"

local spinner_atlas = "data/images/ui.xml"

local spinner_images = {
	arrow_normal = "spin_arrow.tex",
	arrow_over = "spin_arrow_over.tex",
	arrow_disabled = "spin_arrow_disabled.tex",
	bgtexture = "spinner.tex",
}

local text_font = DEFAULTFONT--NUMBERFONT
local spinnerFont = { font = text_font, size = 30 }
local spinnerHeight = 64

local display_rows = 5

local DISABLE = 0
local ENABLE = 1

ModsScreen = Class(Screen, function(self, cb)
    Widget._ctor(self, "ModsScreen")
	self.cb = cb

	-- save current mod index before user configuration
	KnownModIndex:CacheSaveData()

	self.modnames = ModManager:GetModNames()
	
    self.bg = self:AddChild(Image("data/images/ui.xml", "bg_plain.tex"))
    self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    local left_col =-RESOLUTION_X*.26
	local mid_col = RESOLUTION_X*.15
    local right_col = RESOLUTION_X*.41
    
    --menu buttons
    
	self.applybutton = self.root:AddChild(AnimButton("button"))
    self.applybutton:SetPosition(right_col, 60, 0)
    self.applybutton:SetText(STRINGS.UI.MODSSCREEN.APPLY)
    self.applybutton.text:SetColour(0,0,0,1)
    self.applybutton:SetOnClick( function() self:Apply() end )
    self.applybutton:SetFont(BUTTONFONT)
    self.applybutton:SetTextSize(40)    
    
	self.morebutton = self.root:AddChild(AnimButton("button"))
    self.morebutton:SetPosition(right_col, -50, 0)
    self.morebutton:SetText(STRINGS.UI.MODSSCREEN.MOREMODS)
    self.morebutton.text:SetColour(0,0,0,1)
    self.morebutton:SetOnClick( function() self:MoreMods() end )
    self.morebutton:SetFont(BUTTONFONT)
    self.morebutton:SetTextSize(40)
    
	self.cancelbutton = self.root:AddChild(AnimButton("button"))
    self.cancelbutton:SetPosition(right_col, -120, 0)
    self.cancelbutton:SetText(STRINGS.UI.MODSSCREEN.CANCEL)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetOnClick( function() self:Cancel() end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(40)

	-- mod details panel

    self.detailpanel = self.root:AddChild(Widget("detailpanel"))
    self.detailpanel:SetPosition(mid_col,0,0)
    self.detailpanelbg = self.detailpanel:AddChild(Image("data/images/panel_mod2.xml", "panel_mod2.tex"))
    self.detailpanelbg:SetScale(1,1, 1)

	self.detailimage = self.detailpanel:AddChild(Image("data/images/ui.xml", "portrait_bg.tex"))
	self.detailimage:SetScale(0.8,0.8,0.8) -- REMOVE THIS!! Just for testing with placeholder images
	self.detailimage:SetPosition(-130,157,0)

    self.detailtitle = self.detailpanel:AddChild(Text(TITLEFONT, 50))
    self.detailtitle:SetHAlign(ANCHOR_LEFT)
    self.detailtitle:SetPosition(70, 170, 0)
	self.detailtitle:SetRegionSize( 270, 70 )

    --self.detailversion = self.detailpanel:addchild(text(titlefont, 20))
    --self.detailversion:setvalign(anchor_top)
    --self.detailversion:sethalign(anchor_left)
    --self.detailversion:setposition(200, 100, 0)
	--self.detailversion:setregionsize( 180, 70 )

    self.detailauthor = self.detailpanel:AddChild(Text(TITLEFONT, 30))
	self.detailauthor:SetColour(0.9,0.8,0.6,1)
    self.detailauthor:SetHAlign(ANCHOR_LEFT)
    self.detailauthor:SetPosition(70, 125, 0)
	self.detailauthor:SetRegionSize( 270, 70 )
	self.detailauthor:EnableWordWrap(true)

    self.detaildesc = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25))
    self.detaildesc:SetPosition(6, 32, 0)
	self.detaildesc:SetRegionSize( 352, 140 )
    self.detaildesc:EnableWordWrap(true)

    self.detailwarning = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25))
	self.detailwarning:SetColour(0.9,0,0,1)
    self.detailwarning:SetPosition(112, -147, 0)
	self.detailwarning:SetRegionSize( 140, 117 )
    self.detailwarning:EnableWordWrap(true)
	
	self.modlinkbutton = self.detailpanel:AddChild(TextButton("modlinkbutton"))
	self.modlinkbutton:SetPosition(5, -62, 0)
	self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
	self.modlinkbutton:SetFont(BUTTONFONT)
	self.modlinkbutton:SetTextSize(30)
	self.modlinkbutton:SetColour(0.9,0.8,0.6,1)
	self.modlinkbutton:SetOverColour(1,1,1,1)
	self.modlinkbutton:SetOnClick( function() self:ModLinkCurrent() end )
    
	local enablespinnerfont = {font = BUTTONFONT, size = 40}
	local enableoptions = {{text="Disabled", data=DISABLE},{text="Enabled",data=ENABLE}}
	self.enablespinner = self.detailpanel:AddChild(Spinner(enableoptions, 100, 60, enablespinnerfont, spinner_atlas, spinner_images))
	self.enablespinner:SetTextColour(0,0,0,1)
    self.enablespinner:SetPosition(-80-self.enablespinner:GetWidth()/2, -150, 0)
	self.enablespinner.OnChanged = function( _, data )
		self:EnableCurrent(data)
	end

	--self.enablebutton = self.detailpanel:AddChild(AnimButton("button"))
    --self.enablebutton:SetPosition(-80, -150, 0)
    --self.enablebutton.text:SetColour(0,0,0,1)
    --self.enablebutton:SetOnClick( function() self:EnableCurrent() end )
    --self.enablebutton:SetFont(BUTTONFONT)
    --self.enablebutton:SetTextSize(40)
		
	--add the custom options panel
	
	
	self.option_offset = 0
    self.optionspanel = self.root:AddChild(Widget("optionspanel"))
    self.optionspanel:SetPosition(left_col,0,0)
    self.optionspanelbg = self.optionspanel:AddChild(Image("data/images/panel_mod1.xml", "panel_mod1.tex"))

	self.leftbutton = self.optionspanel:AddChild(AnimButton("scroll_arrow"))
    self.leftbutton:SetPosition(-240, 0, 0)
	self.leftbutton:SetScale(-1,1,1)
    self.leftbutton:SetOnClick( function() self:Scroll(-display_rows) end)
	
	self.rightbutton = self.optionspanel:AddChild(AnimButton("scroll_arrow"))
    self.rightbutton:SetPosition(240, 0, 0)
    self.rightbutton:SetOnClick( function() self:Scroll(display_rows) end)	

	self.optionwidgets = {}
	self:Scroll(0) -- resets the scroll arrows and populates the list

	self:ShowModDetails(1)
end)

function ModsScreen:RefreshOptions()

	for k,v in pairs(self.optionwidgets) do
		v:Kill()
	end
	self.optionwidgets = {}
	
	
	local page_total = math.min(#self.modnames - self.option_offset, display_rows)
	for k = 1, page_total do
	
		local idx = self.option_offset+k

		local modname = self.modnames[idx]
		local modinfo = ModManager:GetModInfo(modname)
		
		local opt = self.optionspanel:AddChild(Widget("option"))
		
		opt.bg = opt:AddChild(UIAnim())
		opt.bg:GetAnimState():SetBuild("savetile")
		opt.bg:GetAnimState():SetBank("savetile")
		opt.bg:GetAnimState():PlayAnimation("anim")

		opt.image = opt:AddChild(Image("data/images/ui.xml", "portrait_bg.tex"))
		local imscale = .6
		opt.image:SetScale(imscale,imscale,imscale)
		opt.image:SetPosition(-115,0,0)
		if modinfo and modinfo.icon and modinfo.icon_atlas then
			opt.image:SetTexture("mods/"..modname.."/"..modinfo.icon_atlas, modinfo.icon)
		end

		opt.name = opt:AddChild(Text(TITLEFONT, 35))
		opt.name:SetVAlign(ANCHOR_MIDDLE)
		opt.name:SetPosition(40, 0, 0)
		opt.name:SetRegionSize( 245, 50 )
		opt.name:SetString(modname)
		if modinfo and modinfo.name then
			opt.name:SetString(modinfo.name)
		end

		if KnownModIndex:IsModEnabled(modname) then
			opt.image:SetTint(1,1,1,1)
			opt.name:SetColour(1,1,1,1)
		else
			opt.image:SetTint(1.0,0.5,0.5,1)
			opt.name:SetColour(.7,.7,.7,1)
		end
		
		local spacing = 105
		
		opt:SetMouseOver(
			function()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
				opt:SetScale(1.1,1.1,1)
				opt.bg:GetAnimState():PlayAnimation("over")
			end)

		opt:SetMouseOut(
			function()
				opt:SetScale(1,1,1)
				opt.bg:GetAnimState():PlayAnimation("anim")
			end)
			
		opt:SetLeftMouseUp( function() self:ShowModDetails(idx) end )
		
		opt:SetPosition(0, (display_rows-1)*spacing*.5 - (k-1)*spacing - 10, 0)
		
		table.insert(self.optionwidgets, opt)
	end
	
	
end

function ModsScreen:Scroll(dir)
	if (dir > 0 and (self.option_offset + display_rows) < #self.modnames) or
		(dir < 0 and self.option_offset + dir >= 0) then
	
		self.option_offset = self.option_offset + dir
	end
	
	self:RefreshOptions()

	if self.option_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.option_offset + display_rows < #self.modnames then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end
end

function ModsScreen:ShowModDetails(idx)
	self.currentmod = idx

	local modname = self.modnames[idx]
	local modinfo = ModManager:GetModInfo(modname)

	if modinfo.icon and modinfo.icon_atlas then
		self.detailimage:SetTexture("mods/"..modname.."/"..modinfo.icon_atlas, modinfo.icon)
	else
		self.detailimage:SetTexture("data/images/ui.xml", "portrait_bg.tex")
	end
	if modinfo.name then
		self.detailtitle:SetString(modinfo.name)
	else
		self.detailtitle:SetString(modname)
	end
	if modinfo.version then
		--self.detailversion:setstring( string.format(strings.ui.modsscreen.version, modinfo.version))
	else
		--self.detailversion:setstring( string.format(strings.ui.modsscreen.version, 0))
	end
	if modinfo.author then
		self.detailauthor:SetString( string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author))
	else
		self.detailauthor:SetString( string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, "unknown"))
	end
	if modinfo.description then
		self.detaildesc:SetString(modinfo.description)
	else
		self.detaildesc:SetString("")
	end

	if modinfo.forumthread then
		self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
	else
		self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINKGENERIC)
	end

	self.detailwarning:SetColour(1,1,1,1)
	if KnownModIndex:IsModEnabled(modname) then
		self.enablespinner:SetSelected(ENABLE)
		--self.enablebutton:SetText(STRINGS.UI.MODSSCREEN.DISABLE)

		if KnownModIndex:WasModEnabled(modname) then
			self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WORKING_NORMALLY)
		else
			self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WILL_ENABLE)
		end
	else
		self.enablespinner:SetSelected(DISABLE)
		--self.enablebutton:SetText(STRINGS.UI.MODSSCREEN.ENABLE)
		if KnownModIndex:WasModEnabled(modname) then
			self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WILL_DISABLE)
		else
			if ModManager:GetModInfo(modname).failed or KnownModIndex:IsModKnownBad(modname) then
				self.detailwarning:SetColour(0.9,0.3,0.3,1)
				self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_ERROR)
			elseif ModManager:GetModInfo(modname).old then
				self.detailwarning:SetColour(0.9,0.3,0.3,1)
				self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_OLD)
			else
				self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_MANUAL)
			end
		end
	end
end

function ModsScreen:EnableCurrent(data)
	local modname = self.modnames[self.currentmod]
	if data == DISABLE then
		KnownModIndex:Disable(modname)
	else
		KnownModIndex:Enable(modname)
	end
	self:Scroll(0)
	self:ShowModDetails(self.currentmod)
end

function ModsScreen:ModLinkCurrent()
	local modname = self.modnames[self.currentmod]
	local thread = ModManager:GetModInfo(modname).forumthread
	
	local url = ""
	if thread then
		url = "http://forums.kleientertainment.com/showthread.php?%s"
		url = string.format(url, ModManager:GetModInfo(modname).forumthread)
	else
		url = "http://forums.kleientertainment.com/forumdisplay.php?63-Don-t-Starve-Mods-and-tools"
	end
	VisitURL(url)
end

function ModsScreen:MoreMods()
	VisitURL("http://forums.kleientertainment.com/downloads.php")
end

function ModsScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		self:Cancel()
	end
end

function ModsScreen:Cancel()
	KnownModIndex:RestoreCachedSaveData()
	self.cb(false)
end

function ModsScreen:Apply()
	KnownModIndex:Save()
	self.cb(true)
end

