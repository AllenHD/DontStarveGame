require "screen"
require "animbutton"
require "spinner"
require "numericspinner"
require "map/levels"
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

local customise = require("map/customise")
local options = {}

for k,v in pairs(customise.GROUP) do
	for kk, vv in pairs(v.items) do
		table.insert(options, {name = kk, image = vv.image, options = vv.desc or v.desc, default = vv.value, group = k, atlas = vv.atlas})
	end
end

local per_side = 7

CustomizationScreen = Class(Screen, function(self, profile, cb, defaults)
    Widget._ctor(self, "CustomizationScreen")
    self.profile = profile
	self.cb = cb
	
	if defaults then
		self.options = deepcopy(defaults)
		self.options.tweak = self.options.tweak or {}
		self.options.preset = self.options.preset or {}
	else
		self.options = 
		{ 
			preset = {},
			tweak = {}
		}
	end
	
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
    
    local left_col =-RESOLUTION_X*.25 - 50
    local right_col = RESOLUTION_X*.25 - 75
    
    --menu buttons
    
	self.applybutton = self.root:AddChild(AnimButton("button"))
    self.applybutton:SetPosition(left_col, -185, 0)
    self.applybutton:SetText(STRINGS.UI.CUSTOMIZATIONSCREEN.APPLY)
    self.applybutton.text:SetColour(0,0,0,1)
    self.applybutton:SetOnClick( function() self:Apply() end )
    self.applybutton:SetFont(BUTTONFONT)
    self.applybutton:SetTextSize(40)    
    
	self.cancelbutton = self.root:AddChild(AnimButton("button"))
    self.cancelbutton:SetPosition(left_col, -260, 0)
    self.cancelbutton:SetText(STRINGS.UI.CUSTOMIZATIONSCREEN.CANCEL)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetOnClick( function() self:Cancel() end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(40)

	--set up the preset spinner

	self.presets = {}
	for i, level in pairs(levels.sandbox_levels) do
		table.insert(self.presets, {text=level.name, data=level.id, desc = level.desc, overrides = level.overrides})
	end
    
    self.presetpanel = self.root:AddChild(Widget("presetpanel"))
    self.presetpanel:SetPosition(left_col,50,0)
    self.presetpanelbg = self.presetpanel:AddChild(Image("data/images/presetbox.xml", "presetbox.tex"))
    self.presetpanelbg:SetScale(1,.9, 1)

    self.presettitle = self.presetpanel:AddChild(Text(TITLEFONT, 50))
    self.presettitle:SetHAlign(ANCHOR_MIDDLE)
    self.presettitle:SetPosition(0, 105, 0)
	self.presettitle:SetRegionSize( 400, 70 )
    self.presettitle:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETTITLE)

    self.presetdesc = self.presetpanel:AddChild(Text(TITLEFONT, 35))
    self.presetdesc:SetHAlign(ANCHOR_MIDDLE)
    self.presetdesc:SetPosition(0, -60, 0)
	self.presetdesc:SetRegionSize( 300, 130 )
    self.presetdesc:SetString(self.presets[1].desc)
    self.presetdesc:EnableWordWrap(true)

	local presetspinnerFont = { font = BUTTONFONT, size = 30 }
	
	local w = 200
	self.presetspinner = self.presetpanel:AddChild(Spinner( self.presets, w, 50, presetspinnerFont, spinner_atlas, spinner_images ))
	self.presetspinner:SetPosition(-self.presetspinner:GetWidth()/2, 50, 0)
	self.presetspinner:SetTextColour(0,0,0,1)
	self.presetspinner.OnChanged =
		function( _, data )
		
			if self.dirty then
				TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESTITLE, STRINGS.UI.CUSTOMIZATIONSCREEN.LOSECHANGESBODY, 
					{{text=STRINGS.UI.CUSTOMIZATIONSCREEN.YES, cb = function() self.options.tweak = {} self:MakeClean() end},
					{text=STRINGS.UI.CUSTOMIZATIONSCREEN.NO, cb = function() self:MakeDirty() end}  }))
			else
				self:LoadPreset(data)
				self.options.tweak = {}				
			end
		end
		
	--add the custom options panel
	
	
	self.option_offset = 0
    self.optionspanel = self.root:AddChild(Widget("optionspanel"))
    self.optionspanel:SetPosition(right_col,0,0)
    self.optionspanelbg = self.optionspanel:AddChild(Image("data/images/panel_customization.xml", "panel_customization.tex"))

	self.rightbutton = self.optionspanel:AddChild(AnimButton("scroll_arrow"))
    self.rightbutton:SetPosition(340, 0, 0)
    self.rightbutton:SetOnClick( function() self:Scroll(per_side) end)
	--self.rightbutton:Hide()
	
	self.leftbutton = self.optionspanel:AddChild(AnimButton("scroll_arrow"))
    self.leftbutton:SetPosition(-340, 0, 0)
    self.leftbutton:SetScale(-1,1,1)
    self.leftbutton:SetOnClick( function() self:Scroll(-per_side) end)	
    self.leftbutton:Hide()
	
	self.optionwidgets = {}
	
	local preset = self.options.preset or self.presets[1].data
	self:LoadPreset(preset)
	if next(self.options.tweak) then
		self:MakeDirty()
	end

	self.hover = self:AddChild(HoverText(self))
	self.hover:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.hover.isFE = true
end)


function CustomizationScreen:RefreshOptions()
	
	for k,v in pairs(self.optionwidgets) do
		v.root:Kill()
	end
	self.optionwidgets = {}
	
	--these are in kind of a weird format, so convert it to something useful...
	local overrides = {}
	for k,v in pairs(self.presets) do
		if self.preset == v.data then
			for k,v in pairs(v.overrides) do
				overrides[v[1]] = v[2]
		end
	end
	end
	
	for k = 1, per_side*2 do
	
		local idx = self.option_offset+k
		
		if options[idx] then
			
			local spin_options = {} --{{text="default"..tostring(idx), data="default"},{text="2", data="2"}, }
			for k,v in ipairs(options[idx].options) do
				table.insert(spin_options, {text=v.text, data=v.data})
			end
			
			local opt = self.optionspanel:AddChild(Widget("option"))
			
			local bg = opt:AddChild(Image("data/images/ui.xml", "nondefault_customization.tex"))
			bg:Hide()
			local image = opt:AddChild(Image(options[idx].atlas or "data/images/customisation.xml", options[idx].image))
			
			local imscale = .5
			image:SetScale(imscale,imscale,imscale)
		    image:SetTooltip(options[idx].name)

			local spinfont = { font = BUTTONFONT, size = 30 }
			
			local spin_height = 50
			local w = 120
			local spinner = opt:AddChild(Spinner( spin_options, w, spin_height, spinfont, spinner_atlas, spinner_images ))
			spinner:SetTextColour(0,0,0,1)
			local default_value = overrides[options[idx].name] or options[idx].default
			
			spinner.OnChanged =
				function( _, data )
					if data ~= default_value then 
						bg:Show()
						if not self.options.tweak[options[idx].group] then
							self.options.tweak[options[idx].group] = {}
						end
						self.options.tweak[options[idx].group][options[idx].name] = data
					else
						bg:Hide()
						self.options.tweak[options[idx].group][options[idx].name] = nil
						if not next(self.options.tweak[options[idx].group]) then
							self.options.tweak[options[idx].group] = nil
						end
					end
					
					if next(self.options.tweak) then
						self:MakeDirty()
					else
						self:MakeClean()
					end
				end
				
			if self.options.tweak[options[idx].group] and self.options.tweak[options[idx].group][options[idx].name] then
				spinner:SetSelected(self.options.tweak[options[idx].group][options[idx].name])
				bg:Show()
			else
				spinner:SetSelected(default_value)
				bg:Hide()
			end
			
			
			spinner:SetPosition(-50,0,0 )
			image:SetPosition(-105,0,0)
			local spacing = 75
			
			if k <= per_side then
				opt:SetPosition(-150, (per_side-1)*spacing*.5 - (k-1)*spacing - 10, 0)
			else
				opt:SetPosition(150, (per_side-1)*spacing*.5 - (k-1-per_side)*spacing- 10, 0)
			end
			
			table.insert(self.optionwidgets, {root = opt, bg = bg})
		end
	end
	
	
end

function CustomizationScreen:Scroll(dir)
	if (dir > 0 and (self.option_offset + per_side*2) < #options) or
		(dir < 0 and self.option_offset + dir >= 0) then
	
		self.option_offset = self.option_offset + dir
		self:RefreshOptions()
	end
	
	if self.option_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.option_offset + per_side*2 < #options then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end
	
	
end

function CustomizationScreen:MakeDirty()
	self.dirty = true
	
	for k,v in pairs(self.presets) do
		if self.current_preset == v.data then
			self.presetdesc:SetString(STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOMDESC)
			self.presetspinner:UpdateText(v.text .. " " .. STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM)
		end
	end
end

function CustomizationScreen:MakeClean()
	self.dirty = false
	self:LoadPreset(self.presetspinner:GetSelectedData())
end

function CustomizationScreen:LoadPreset(preset)
	self.current_preset = preset
	self.dirty = false
	for k,v in pairs(self.presets) do
		if preset == v.data then
			self.presetdesc:SetString(v.desc)
			self.presetspinner:UpdateText(v.text)
		end
	end
	self.preset = preset
	self.options.preset = preset
	self:RefreshOptions()	
end

function CustomizationScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		self.cb()
	end
end

function CustomizationScreen:Cancel()
	self.cb()
end

function CustomizationScreen:Apply()
	self.cb(self.options)
end

function CustomizationScreen:ApplySettings()
end	

function CustomizationScreen:OnUpdate(dt)
	self.hover:Update()
end
