require "util"
require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"
require "spinner"
require "numericspinner"
require "textedit"

require "screens/popupdialog"

local UI_ATLAS = "data/images/ui.xml"
local EMAIL_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@!#$%&'*+-/=?^_`{|}~"
local EMAIL_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local MIN_AGE = 3 -- ages less than this prompt error message, eg. if they didn't change the date at all

EmailSignupScreen = Class(Screen, function(self)
	Screen._ctor(self, "EmailSignupScreen")

	self:DoInit()

end)

function EmailSignupScreen:OnKeyUp( key )
	if key == KEY_ESCAPE then
		self:Close()
	else
		Screen.OnKeyUp(self, key)
	end
end

function EmailSignupScreen:Accept()
	if self:Save() then
		self:Close()

		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESSTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESS,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb =
					function()
					end
				} }
			  )
		)
	end
end

function EmailSignupScreen:Save()
	local email = self.email_edit:GetString()
	print ("EmailSignupScreen:Save()", email)
	
	local bmonth = self.monthSpinner:GetSelectedIndex()
	local bday = self.daySpinner:GetSelectedIndex()
	local byear = self.yearSpinner:GetSelectedIndex()
	
	if not self:IsValidEmail(email) then
		TheFrontEnd:PushScreen(
			
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDEMAILTITLE, STRINGS.UI.EMAILSCREEN.INVALIDEMAIL,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() end } }
			  )
		)
		return false
	end
	
	if not self:IsValidBirthdate(bday, bmonth, byear) then
		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDDATETITLE, STRINGS.UI.EMAILSCREEN.INVALIDDATE,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() end } }
			  )
		)
		return false
	end
	
	local birth_date = byear .. "-" .. bmonth .. "-" .. bday
	print ("Birthday:", birth_date)
	
	local query = GAME_SERVER.."/email/subscribe/" .. email

	TheSim:QueryServer(
		query,
		function( result, isSuccessful )
			-- callback ignored on Windows, don't do anything important here
			print('EmailSignupScreen:Save()', isSuccessful, result)
		end,
		"POST",
		json.encode({
			birthday = birth_date,
		}) 
	)
	return true
end

function EmailSignupScreen:IsValidBirthdate(day, month, year)
	print("EmailSignupScreen:IsValidBirthdate", day, month, year, self.minYear, self.maxYear)
	if day < 1 or day > 31 then
		return false
	end
	if month < 1 or month > 12 then
		return false
	end
	if year < self.minYear or year > self.maxYear - MIN_AGE then
		return false
	end
	return true
end

-- allow (anything)@(anything).(anything)
-- unless you want to write whatever unnecessarily complex expression would be required to be more accurate without excluding valid addresses
-- http://en.wikipedia.org/wiki/Email_address#Syntax

function EmailSignupScreen:IsValidEmail(email)
	local matchPattern = "^[%w%p]+@[%w%p]+%.[%w%p]+$"
	return string.match(email, matchPattern)
end

function EmailSignupScreen:Close()
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen()
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

function EmailSignupScreen:AddSpinners( data )
	self.birthday_group = self.root:AddChild( Widget( "SpinnerGroup" ) )
	self.birthday_group:SetPosition( -250, 0, 0 )

	local x = 0
	for idx, entry in ipairs( data ) do
		local width = entry[1]
		local spinner = entry[2]
		local defindex = entry[3]
		local maxlen = entry[4]

		local group = self.birthday_group:AddChild( Widget( "SpinnerGroup" ) )
		group:SetPosition( x, 0, 0 )

		group:AddChild( spinner )
		--spinner:SetPosition( 0, 0, 0 )
		spinner:SetSelectedIndex(defindex)
		if( spinner.editable ) then
			spinner.text:SetTextLengthLimit(maxlen)

			spinner.text:SetLeftMouseDown( function() self:SetFocus( spinner ) end )
			spinner.text:SetFocusedImage( spinner.bgimage, UI_ATLAS, "textbox_short_over.tex", "textbox_short.tex" )
			spinner.text:SetCharacterFilter( "0123456789" )
		end

		x = x + width
	end
end

function EmailSignupScreen:DoInit()

	TheInput:EnableDebugToggle(false)

	self.maxYear = tonumber(os.date("%Y"))
	self.minYear = self.maxYear - 130

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
	
	self.root = self.proot:AddChild(Widget("ROOT"))
    --self.root:SetPosition(-RESOLUTION_X/2,-RESOLUTION_Y/2,0)
    


	

	--throw up the background
    self.bg = self.root:AddChild(Image("data/images/small_dialog.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.6, 2, 1)    
	local menu_items = {
		{ text = STRINGS.UI.EMAILSCREEN.SUBSCRIBE, cb = function() self:Accept() end },
		{ text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function() self:Close() end },
	}

	if self.menu then
		self.menu:Kill()
	end	

    local title_size = 300
    local title_offset = 120

    self.title = self.root:AddChild(Text(TITLEFONT, 50))

    self.title:SetString(STRINGS.UI.EMAILSCREEN.TITLE)
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	--self.title:SetRegionSize( title_size, 50 )
    self.title:SetPosition(0, title_offset, 0)


	local label_width = 200
	local label_height = 50
	local label_offset = 275

	local space_between = 30
	local height_offset = 60

	local email_fontsize = 30

	
	
	
	self.email_label = self.root:AddChild( Text( BODYTEXTFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.EMAIL ) )
	self.email_label:SetPosition( -(label_width * .5 + label_offset), height_offset, 0 )
	self.email_label:SetRegionSize( label_width, label_height )
	self.email_label:SetHAlign(ANCHOR_RIGHT)

	self.bday_label = self.root:AddChild( Text( BODYTEXTFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.BIRTHDAY ) )
	self.bday_label:SetPosition( -(label_width * .5 + label_offset), 0, 0 )
	self.bday_label:SetRegionSize( label_width, label_height )
	self.bday_label:SetHAlign(ANCHOR_RIGHT)

	local edit_width = 550
	local edit_bg_padding = 60
	
	self.bday_message = self.root:AddChild( Text( BODYTEXTFONT, 24,  STRINGS.UI.EMAILSCREEN.BIRTHDAYREASON ) )
	self.bday_message:SetPosition( 0, -height_offset, 0 )
	self.bday_message:SetRegionSize( edit_width, label_height * 2 )
	self.bday_message:EnableWordWrap(true)
	--self.bday_message:SetHAlign(ANCHOR_LEFT)


    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "data/images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.email_edit = self.root:AddChild( TextEdit( BODYTEXTFONT, email_fontsize, "" ) )
	self.email_edit:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.email_edit:SetRegionSize( edit_width, label_height )
	self.email_edit:SetHAlign(ANCHOR_LEFT)
	self.email_edit:SetLeftMouseDown( function() self:SetFocus( self.email_edit ) end )
	self.email_edit:SetFocusedImage( self.edit_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.email_edit:SetTextLengthLimit(EMAIL_MAX_LENGTH)
	self.email_edit:SetCharacterFilter( EMAIL_VALID_CHARS )

	local spinner_images = {
		arrow_normal = "arrow_right.tex",
		arrow_over = "arrow_right_over.tex",
		arrow_disabled = "arrow_right_disabled.tex",
		bgtexture = "textbox_short.tex",
	}

	local text_font = BODYTEXTFONT


	local months = {
		{ text = STRINGS.UI.EMAILSCREEN.JAN},
		{ text = STRINGS.UI.EMAILSCREEN.FEB},
		{ text = STRINGS.UI.EMAILSCREEN.MAR},
		{ text = STRINGS.UI.EMAILSCREEN.APR},
		{ text = STRINGS.UI.EMAILSCREEN.MAY},
		{ text = STRINGS.UI.EMAILSCREEN.JUN},
		{ text = STRINGS.UI.EMAILSCREEN.JUL},
		{ text = STRINGS.UI.EMAILSCREEN.AUG},
		{ text = STRINGS.UI.EMAILSCREEN.SEP},
		{ text = STRINGS.UI.EMAILSCREEN.OCT},
		{ text = STRINGS.UI.EMAILSCREEN.NOV},
		{ text = STRINGS.UI.EMAILSCREEN.DEC},
	}

	self.monthSpinner = Spinner( months, 100, 50, { font = text_font, size = email_fontsize}, UI_ATLAS, spinner_images, 0.5, false )
	self.daySpinner = NumericSpinner( 1, 31, 50, 50, { font = text_font, size = email_fontsize }, UI_ATLAS, spinner_images, 0.5, true )
	self.yearSpinner = NumericSpinner( self.minYear, self.maxYear, 100, 50, { font = text_font, size = email_fontsize }, UI_ATLAS, spinner_images, 0.5, true )

	local spinners = {}

	table.insert( spinners, { 160, self.monthSpinner, tonumber(os.date("%m")), 2 } )
	table.insert( spinners, { 110, self.daySpinner, tonumber(os.date("%d")), 2 } )
	table.insert( spinners, { 110, self.yearSpinner, tonumber(os.date("%Y")), 4 } )

	self:AddSpinners( spinners )
	
	self.monthSpinner:SetWrapEnabled(true)
	self.daySpinner:SetWrapEnabled(true)
	self.yearSpinner:SetWrapEnabled(false)
	
	local month_edit_w = 20 + edit_bg_padding
	local day_edit_w = 20 + edit_bg_padding
	local year_edit_w = 50 + edit_bg_padding
	
	
	local bday_fields = { 
		{ name=STRINGS.UI.EMAILSCREEN.MONTH, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.DAY, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.YEAR, width=50 },
	}
	
	local button_w = 200
	local menu_spacing = button_w + space_between

	self.menu = self.root:AddChild( MakeMenu( Vector3(menu_spacing, 0, 0), menu_items) )
	self.menu:SetPosition(-115, -120, 0) 
	
	self:PushFocusWidget(self.email_edit)
	--self:PushFocusWidget(self.monthSpinner)
	self:PushFocusWidget(self.daySpinner)
	self:PushFocusWidget(self.yearSpinner)
end
