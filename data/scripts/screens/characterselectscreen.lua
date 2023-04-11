require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"

CharacterSelectScreen = Class(Screen, function(self, profile, cb, no_backbutton, default_character)
	Screen._ctor(self, "CharacterSelect")
    self.profile = profile
	self.log = true
    
    self.no_cancel = no_backbutton
    
    self.currentcharacter = nil

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

    self.fixed_root = self.root:AddChild(Widget("root"))
    self.fixed_root:SetPosition(-RESOLUTION_X/2, -RESOLUTION_Y/2, 0)
    
    self.heroportait = self.fixed_root:AddChild(Image())
    self.heroportait:SetVRegPoint(ANCHOR_BOTTOM)
    self.heroportait:SetHRegPoint(ANCHOR_LEFT)
    
    local adjust = 16
    
    self.biobox = self.fixed_root:AddChild(Image("data/images/biobox.xml", "biobox.tex"))
    self.biobox:SetPosition(822 + adjust,RESOLUTION_Y-489+30,0)
    
    self.charactername = self.fixed_root:AddChild(Text(TITLEFONT, 60))
    self.charactername:SetHAlign(ANCHOR_MIDDLE)
    self.charactername:SetPosition(820 + adjust, RESOLUTION_Y - 400+30,0)
	self.charactername:SetRegionSize( 500, 70 )

    self.characterquote = self.fixed_root:AddChild(Text(UIFONT, 30))
    self.characterquote:SetHAlign(ANCHOR_MIDDLE)
    self.characterquote:SetVAlign(ANCHOR_TOP)
    self.characterquote:SetPosition(820 + adjust, RESOLUTION_Y - 525 + 60+30,0)
	self.characterquote:SetRegionSize( 500, 60 )
	self.characterquote:EnableWordWrap( true )
	self.characterquote:SetString( "" )

    self.characterdetails = self.fixed_root:AddChild(Text(BODYTEXTFONT, 30))
    self.characterdetails:SetHAlign(ANCHOR_LEFT)
    self.characterdetails:SetVAlign(ANCHOR_TOP)
    self.characterdetails:SetPosition(820 + adjust, RESOLUTION_Y - 525 - 30+30,0)
	self.characterdetails:SetRegionSize( 450, 120 )
	self.characterdetails:EnableWordWrap( true )
	self.characterdetails:SetString( "" )

    
	self.startbutton = self.fixed_root:AddChild(AnimButton("button"))
	--button:SetScale(.8,.8,.8)
	self.startbutton:SetText(STRINGS.UI.CHARACTERSELECT.APPLY)
	self.startbutton:SetOnClick(
		function()
		    self.startbutton:Disable()
			TheFrontEnd:GetSound():KillSound("FEMusic")
			if self.cb then
				self.cb(self.currentcharacter)
			end
		end)	
	self.startbutton:SetFont(BUTTONFONT)
	self.startbutton:SetTextSize(40)
	--self.startbutton.text:SetVAlign(ANCHOR_MIDDLE)
	self.startbutton.text:SetColour(0,0,0,1)
	self.startbutton:SetPosition( 820+ adjust, 80, 0)


	if not no_backbutton then
	
		self.startbutton:SetPosition( 820 + 100+ adjust, 80, 0)

		self.backbutton = self.fixed_root:AddChild(AnimButton("button"))
		--button:SetScale(.8,.8,.8)
		self.backbutton:SetText(STRINGS.UI.CHARACTERSELECT.CANCEL)
		self.backbutton:SetOnClick( function() if self.cb then self.cb(nil) end end)
		self.backbutton:SetFont(BUTTONFONT)
		self.backbutton:SetTextSize(40)
		self.backbutton.text:SetColour(0,0,0,1)
		self.backbutton:SetPosition( 820 - 100+ adjust, 80, 0)
    end
    
	self.characters = JoinArrays(CHARACTERLIST, MODCHARACTERLIST)

	self.portrait_bgs = {}

    self.portraits = {}
    
	self.portrait_frames = {}

    for k = 1,3 do
		local ypos = 720-300+35
		local xbase = 640
		local width = 190
		local xpos = xbase + (k-1) * width

		local portrait_bg = self.fixed_root:AddChild(UIAnim())
		portrait_bg:GetAnimState():SetBuild("portrait_frame")
		portrait_bg:GetAnimState():SetBank("portrait_frame")
		portrait_bg:GetAnimState():PlayAnimation("idle")
		
		portrait_bg:SetPosition(xpos, ypos, 0)
		
		--portrait:SetVRegPoint(ANCHOR_BOTTOM)
		table.insert(self.portrait_bgs, portrait_bg)

		ypos = ypos + 80

		local portrait = self.fixed_root:AddChild(Image())
		portrait:SetPosition(xpos, ypos, 0)

		table.insert(self.portraits, portrait)

		local portrait_frame = self.fixed_root:AddChild(Image("images/selectscreen_portraits.xml", "frame.tex"))
		portrait_frame:SetMouseOverTexture("images/selectscreen_portraits.xml", "frame_mouse_over.tex")
		portrait_frame:SetPosition(xpos, ypos, 0)

		portrait_frame:SetLeftMouseDown(function() self:OnClickPortait(k) end)
		
		portrait_frame:SetMouseOver(function() if self.portrait_idx ~= k then portrait_bg:GetAnimState():PlayAnimation("mouseover") end end)
		portrait_frame:SetMouseOut(function() if self.portrait_idx ~= k then portrait_bg:GetAnimState():PlayAnimation("idle") end end)
		table.insert(self.portrait_frames, portrait_frame)
    end

	self.rightbutton = self.fixed_root:AddChild(AnimButton("scroll_arrow"))
    self.rightbutton:SetPosition(1129, RESOLUTION_Y-211, 0)
    self.rightbutton:SetOnClick( function() self:Scroll(1) end)

	self.leftbutton = self.fixed_root:AddChild(AnimButton("scroll_arrow"))
    self.leftbutton:SetPosition(516+15, RESOLUTION_Y-211, 0)
    self.leftbutton:SetScale(-1,1,1)
    self.leftbutton:SetOnClick( function() self:Scroll(-1) end)
    
    self:SetOffset(0)
    self:SelectPortrait(1)
    self.cb = cb
    
    --TheFrontEnd:DoFadeIn(2)
    self:SelectCharacter(default_character)
end)

function CharacterSelectScreen:OnKeyUp( key )
	if key == KEY_ESCAPE and not self.no_cancel then
		if self.cb then self.cb(nil) end
	elseif key == KEY_ENTER then
		if self.currentcharacter then
			self.cb(self.currentcharacter)
		end
	end
end

function CharacterSelectScreen:OnGainFocus()
    self._base.OnGainFocus(self)
    self.startbutton:Enable()
end

function CharacterSelectScreen:OnClickPortait(portrait)
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	local character = self:GetCharacterForPortrait(portrait)
	self:SelectPortrait(portrait)
end

function CharacterSelectScreen:SelectCharacter(character)
	for k,v in ipairs(self.characters) do
		if v == character then
			self:SetOffset(k-1)
			self:SelectPortrait(1)
		end
	end
end

function CharacterSelectScreen:Scroll(scroll)
	if self.portrait_idx then
		self.portrait_idx = self.portrait_idx - scroll
	end
	self:SetOffset( self.offset + scroll )
end

function CharacterSelectScreen:GetCharacterForPortrait(portrait)
	local idx = (portrait-1 + self.offset) % #self.characters + 1 
	return self.characters[idx]
end

function CharacterSelectScreen:SetOffset(offset)
	self.offset = offset
	for k = 1,3 do
		local character = self:GetCharacterForPortrait(k)
		
		self.portrait_bgs[k]:GetAnimState():PlayAnimation(k == self.portrait_idx and "selected" or "idle", true)

		local atlas = (table.contains(MODCHARACTERLIST, character) and "images/selectscreen_portraits/"..character..".xml") or "images/selectscreen_portraits.xml"
		local atlas_silho = (table.contains(MODCHARACTERLIST, character) and "images/selectscreen_portraits/"..character.."_silho.xml") or "images/selectscreen_portraits.xml"

		if not self.profile:IsCharacterUnlocked(character) then
			self.portraits[k]:SetTexture( atlas_silho, character.."_silho.tex")
		else
			self.portraits[k]:SetTexture( atlas, character..".tex")
		end
	end	
end

function CharacterSelectScreen:SelectPortrait(portrait)
	local character = self:GetCharacterForPortrait(portrait)

	self.portrait_idx = portrait
	for k,v in pairs(self.portrait_bgs) do
		v:GetAnimState():PlayAnimation("idle")
	end

	if self.portrait_bgs[portrait] then
		self.portrait_bgs[portrait]:GetAnimState():PlayAnimation("selected", true)
	end

	if character and self.profile:IsCharacterUnlocked(character) then
		self.heroportait:SetTexture("bigportraits/"..character..".xml", character..".tex")
		self.currentcharacter = character
		self.charactername:SetString(STRINGS.CHARACTER_TITLES[character] or "")
		self.characterquote:SetString(STRINGS.CHARACTER_QUOTES[character] or "")
		self.characterdetails:SetString(STRINGS.CHARACTER_DESCRIPTIONS[character] or "")
		self.startbutton:Enable()
	else
		self.heroportait:SetTexture("bigportraits/locked.xml", "locked.tex")
		self.charactername:SetString(STRINGS.CHARACTER_NAMES.unknown)
		self.characterquote:SetString("")
		self.characterdetails:SetString("")
		self.startbutton:Disable()
	end
end

