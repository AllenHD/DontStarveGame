require "util"
require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "numericspinner"
require "textedit"

require "screens/popupdialog"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]
local CONSOLE_HISTORY = {}

ConsoleScreen = Class(Screen, function(self)
	Screen._ctor(self, "ConsoleScreen")
	self:DoInit()
end)

function ConsoleScreen:OnKeyDown( key )
	if key == KEY_ESCAPE or key == KEY_TILDE or (key == KEY_L and TheInput:IsKeyDown(KEY_CTRL) ) then
		self:Close()
	elseif key == KEY_TAB then
		self:AutoComplete()
	elseif key == KEY_ENTER then
		self:Run()
		--if TheInput:IsKeyDown(KEY_CTRL) then
			self:Close()
		--end
	elseif key == KEY_UP then
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				self.history_idx = math.max( 1, self.history_idx - 1 )
			else
				self.history_idx = len
			end
			self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
		end
	elseif key == KEY_DOWN then
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				if self.history_idx == len then
					self.console_edit:SetString( "" )
				else
					self.history_idx = math.min( len, self.history_idx + 1 )
					self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
				end
			end
		end
	else
		self.autocompletePrefix = nil
		self.autocompleteObjName = ""
		self.autocompleteObj = nil
		self.autocompleteOffset = -1
		Screen.OnKeyDown(self, key)
	end
end

function ConsoleScreen:Run()
	local fnstr = self.console_edit:GetString()
	
	if fnstr ~= "" then
		table.insert( CONSOLE_HISTORY, fnstr )
	end
	
	local status, r = pcall( loadstring( fnstr ) )
	if not status then
		print(r)
	end	
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- For this to be improved, you really need to start knowing about the language that's
-- being autocompleted and the string must be tokenized and fed into a lexer.
--
-- For instance, what should you autocomplete here:
--		print(TheSim:Get<tab>
--
-- Given understanding of the language, we know that the object to get is TheSim and
-- it's the metatable from that to autocomplete from. However, you need to know that
-- "print(" is not part of that object.
--
-- Conversely, if I have "SomeFunction().GetTheSim():Get<tab>" then I need to include
-- "SomeFunction()." as opposed to stripping it off. Again, we're back to understanding
-- the language.
--
-- Something that might work is to cheat by starting from the last token, then iterating
-- backwards evaluating pcalls until you don't get an error or you reach the front of the
-- string.
function ConsoleScreen:AutoComplete()
	local str = self.console_edit:GetString()

	if self.autocompletePrefix == nil and self.autocompleteObj == nil then
		local autocomplete_obj_name = nil
		local autocomplete_prefix = str
		
		local rev_str = string.reverse( str )
		local idx = string.find( rev_str, ".", 1, true )
		if idx == nil then
			idx = string.find( rev_str, ":", 1, true )
		end
		if idx ~= nil then
			autocomplete_obj_name = string.sub( str, 1, string.len( str ) - idx )
			autocomplete_prefix = string.sub( str, string.len( str ) - idx + 2, string.len( str ) - 1 )
		end
		
		self.autocompletePrefix = autocomplete_prefix

		if autocomplete_obj_name ~= nil then
			local status, r = pcall( loadstring( "__KLEI_AUTOCOMPLETE=" .. autocomplete_obj_name ) )
			if status then
				self.autocompleteObjName = string.sub( str, 1, string.len( str ) - idx + 1 ) -- must include that last character!
				self.autocompleteObj = getmetatable( __KLEI_AUTOCOMPLETE )
				if self.autocompleteObj == nil then
					self.autocompleteObj = __KLEI_AUTOCOMPLETE
				end
			end
		end
	end
	
	local autocomplete_obj = self.autocompleteObj or _G
	local len = string.len( self.autocompletePrefix )
	
	local found = false
	local counter = 0
	for k, v in pairs( autocomplete_obj ) do
		if string.starts( k, self.autocompletePrefix ) then
			if self.autocompleteOffset == -1 or self.autocompleteOffset < counter then
				self.console_edit:SetString( self.autocompleteObjName .. k )
				self.autocompleteOffset = counter
				found = true
				break
			end	
			counter = counter + 1
		end
	end

	if not found then
		self.autocompleteOffset = -1
		for k, v in pairs( autocomplete_obj ) do
			if string.starts( k, self.autocompletePrefix ) then
				self.console_edit:SetString( self.autocompleteObjName .. k )
				self.autocompleteOffset = 0
			end
		end		
	end
end

function ConsoleScreen:Close()
	SetHUDPause(false)
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen()
end

function ConsoleScreen:DoInit()
	SetHUDPause(true,"console")
	TheInput:EnableDebugToggle(false)

	local label_width = 200
	local label_height = 50
	local label_offset = 450

	local space_between = 30
	local height_offset = -270

	local fontsize = 30
	
	local edit_width = 900
	local edit_bg_padding = 100
	
	self.autocompleteOffset = -1	
	self.autocompletePrefix = nil
	self.autocompleteObj = nil
	self.autocompleteObjName = ""
	
	
	self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_BOTTOM)
    --self.root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.root = self.root:AddChild(Widget(""))
	self.root:SetPosition(0,120,0)
	
    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "data/images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( 0,0,0)
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.console_edit = self.root:AddChild( TextEdit( DEFAULTFONT, fontsize, "" ) )
	self.console_edit:SetPosition( 0,0,0)
	self.console_edit:SetRegionSize( edit_width, label_height )
	self.console_edit:SetHAlign(ANCHOR_LEFT)
	self.console_edit:SetLeftMouseDown( function() self:SetFocus( self.console_edit ) end )
	self.console_edit:SetFocusedImage( self.edit_bg, "data/images/ui.xml", "textbox_long.tex" )
	self.console_edit:SetCharacterFilter( VALID_CHARS )

	self:PushFocusWidget(self.console_edit)

	self.console_edit:SetString("")
	self.history_idx = nil
end
