require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"

CreditsScreen = Class(Screen, function(self)
	Screen._ctor(self, "CreditsScreen")
    

    self.bg = self:AddChild(Image("data/images/ui.xml", "bg_plain.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.bgcolors = 
    {
        BGCOLOURS.RED,
        BGCOLOURS.YELLOW,
        BGCOLOURS.PURPLE
    }
    self.bg:SetTint(self.bgcolors[1][1],self.bgcolors[1][2],self.bgcolors[1][3], 1)


    self.klei_img = self:AddChild(Image("data/images/ui.xml", "klei_new_logo.tex"))
    self.klei_img:SetVAnchor(ANCHOR_MIDDLE)
    self.klei_img:SetHAnchor(ANCHOR_MIDDLE)
    self.klei_img:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.klei_img:SetPosition( 0, 25, 0)

    self.center_root = self:AddChild(Widget("root"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bottom_root = self:AddChild(Widget("root"))
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.worldanim = self.bottom_root:AddChild(UIAnim())
    self.worldanim:GetAnimState():SetBuild("credits")
    self.worldanim:GetAnimState():SetBank("credits")
    self.worldanim:GetAnimState():PlayAnimation("1", true)

    self.flavourtext = self.center_root:AddChild(Text(TITLEFONT, 70))
    self.thankyoutext = self.center_root:AddChild(Text(BODYTEXTFONT, 40))
    self.thankyoutext:SetString(STRINGS.UI.CREDITS.THANKS)
    self.thankyoutext:Hide()

    TheFrontEnd:DoFadeIn(2)
    
    self.positions = {
            {x=300,y=30, bg=1},
            {x=-220,y=30, bg=3},
            {x=-325,y=30, bg=2},
            {x=260,y=30, bg=1},
            {x=-300,y=30, bg=2},
            {x=220,y=0, bg=3, tx=220,ty=200},    -- EXTRA THANKS 
            {x=220,y=0, bg=1, tx=220,ty=200},    -- EXTRA THANKS - STEAM
            {x=0,y=0, bg=3, tx=0,ty=200},    -- ALTGAME
            {x=0,y=60, bg=1, tx=0,ty=180},    -- FMOD
            {x=0,y=180, bg=2, tx=0,ty=180},      -- THANKS
            {x=0,y=180, bg=1},      -- KLEI
        }
    
	local names = shuffleArray(STRINGS.UI.CREDITS.NAMES)
	self.page_contents = {}

    local page_idx = 1
    self.page_contents[page_idx] = ""

    local name_cnt = 0
    for i,name in ipairs(names) do
        self.page_contents[page_idx] = self.page_contents[page_idx]..name.."\n"
        name_cnt = name_cnt + 1 

        if page_idx ~=4 then
            if name_cnt % 4 == 0 then
                page_idx = page_idx + 1
                self.page_contents[page_idx] = ""
                name_cnt = 0
            end
        else
            if name_cnt % 5 == 0 then
                page_idx = page_idx + 1
                self.page_contents[page_idx] = ""
                name_cnt = 0
            end
        end  

    end
    self.page_contents[page_idx] = STRINGS.UI.CREDITS.EXTRA_THANKS
    page_idx = page_idx + 1
    self.page_contents[page_idx] = STRINGS.UI.CREDITS.EXTRA_THANKS_2
    page_idx = page_idx + 1
    local names = shuffleArray(STRINGS.UI.CREDITS.ALTGAMES.NAMES)
    self.page_contents[page_idx] = ""
    for i,name in ipairs(names) do
        self.page_contents[page_idx] = self.page_contents[page_idx]..name.."\n"
    end

    self.titletext = self.center_root:AddChild(Text(TITLEFONT, 70))
    self.titletext:SetPosition(0, 180, 0)
    self.titletext:SetString(STRINGS.UI.CREDITS.THANKYOU)
    self.titletext:Hide()

    self.pageidx = 1
    self.pagemax = 11
    self:ChangeFlavourText()
    
    TheFrontEnd:GetSound():PlaySound("dontstarve/music/gramaphone_ragtime", "creditsscreenmusic")    


    local left_pos_x = -1280/2+100
    local right_pos_x = 1280/2-100

    self.OK_button = self:AddChild(AnimButton("button"))
    self.OK_button:SetScale(.8,.8,.8)
    self.OK_button:SetText(STRINGS.UI.MAINSCREEN.EXIT)
    self.OK_button:SetOnClick( function() self:OnLoseFocus() TheFrontEnd:PopScreen(self) end )
    self.OK_button:SetFont(BUTTONFONT)
    self.OK_button:SetTextSize(35)
    self.OK_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.OK_button:SetHAnchor(ANCHOR_MIDDLE)
    self.OK_button:SetVAnchor(ANCHOR_BOTTOM)
    self.OK_button.text:SetColour(0,0,0,1)
    self.OK_button:SetPosition( right_pos_x, 55, 0)

    self.FB_button = self:AddChild(AnimButton("button"))
    self.FB_button:SetScale(.8,.8,.8)
    self.FB_button:SetText(STRINGS.UI.CREDITS.FACEBOOK)
    self.FB_button:SetOnClick( function() VisitURL("http://facebook.com/kleientertainment") end )
    self.FB_button:SetFont(BUTTONFONT)
    self.FB_button:SetTextSize(35)
    self.FB_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.FB_button:SetHAnchor(ANCHOR_MIDDLE)
    self.FB_button:SetVAnchor(ANCHOR_BOTTOM)
    self.FB_button.text:SetColour(0,0,0,1)
    self.FB_button:SetPosition( left_pos_x, 55*2, 0)

    self.TWIT_button = self:AddChild(AnimButton("button"))
    self.TWIT_button:SetScale(.8,.8,.8)
    self.TWIT_button:SetText(STRINGS.UI.CREDITS.TWITTER)
    self.TWIT_button:SetOnClick( function() VisitURL("http://twitter.com/klei", true) end )
    self.TWIT_button:SetFont(BUTTONFONT)
    self.TWIT_button:SetTextSize(35)
    self.TWIT_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.TWIT_button:SetHAnchor(ANCHOR_MIDDLE)
    self.TWIT_button:SetVAnchor(ANCHOR_BOTTOM)
    self.TWIT_button.text:SetColour(0,0,0,1)
    self.TWIT_button:SetPosition( left_pos_x, 55, 0)

    self.THANKS_button = self:AddChild(AnimButton("button"))
    self.THANKS_button:SetScale(.8,.8,.8)
    self.THANKS_button:SetText(STRINGS.UI.CREDITS.THANKYOU)
    self.THANKS_button:SetOnClick( function() VisitURL("http://www.dontstarvegame.com/Thank-You") end )
    self.THANKS_button:SetFont(BUTTONFONT)
    self.THANKS_button:SetTextSize(35)
    self.THANKS_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.THANKS_button:SetHAnchor(ANCHOR_MIDDLE)
    self.THANKS_button:SetVAnchor(ANCHOR_BOTTOM)
    self.THANKS_button.text:SetColour(0,0,0,1)
    self.THANKS_button:SetPosition( left_pos_x, 55*3, 0)
end)

function CreditsScreen:OnLoseFocus()
	Screen.OnLoseFocus(self)
	TheFrontEnd:GetSound():KillSound("creditsscreenmusic")    
    TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
end

function CreditsScreen:OnUpdate(dt)
end

function CreditsScreen:ChangeFlavourText()
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/creditpage_flip", "flippage")   
    local bgidx = self.positions[self.pageidx].bg

    self.bg:SetTint(self.bgcolors[bgidx][1],self.bgcolors[bgidx][2],self.bgcolors[bgidx][3], 1)

    self.flavourtext:Hide()
    self.thankyoutext:Hide()
    self.titletext:Hide()
    self.klei_img:Hide()

    local delay = 3.3
    if self.pageidx == self.pagemax then
         self.klei_img:Show()
    else
        if self.pageidx >= 6 then
            self.titletext:Show()
        end
         
         self.worldanim:Show()

        if self.pageidx < 7 then         
            self.worldanim:GetAnimState():PlayAnimation(tostring(self.pageidx), true)
        elseif self.pageidx == 7 then
            self.worldanim:GetAnimState():PlayAnimation(tostring(self.pageidx), false)
        else
            self.worldanim:Hide()
        end

        if self.pageidx == 10 then
            delay = 15
            self.titletext:SetPosition(self.positions[self.pageidx].tx, self.positions[self.pageidx].ty, 0)
            self.thankyoutext:Show()
        else
            self.flavourtext:Show()
        end
        
        self.flavourtext:SetPosition(self.positions[self.pageidx].x, self.positions[self.pageidx].y, 0)

        if self.pageidx == 8 then 
            self.titletext:SetString(STRINGS.UI.CREDITS.ALTGAMES.TITLE)
        else
            self.titletext:SetString(STRINGS.UI.CREDITS.THANKYOU)
        end

        if self.pageidx == 9 then
            self.titletext:Hide()
            self.titletext:SetPosition(self.positions[self.pageidx].tx, self.positions[self.pageidx].ty, 0)
            self.flavourtext:SetString(STRINGS.UI.CREDITS.FMOD)
        elseif self.pageidx == 6 or self.pageidx == 8 then  
            self.titletext:SetPosition(self.positions[self.pageidx].tx, self.positions[self.pageidx].ty, 0)
            self.titletext:Show()
            self.flavourtext:SetString(self.page_contents[self.pageidx])
        else
            self.flavourtext:SetString(self.page_contents[self.pageidx])
        end
    end
    --print("TEXT", self.pageidx, self.page_contents[self.pageidx])
    self.pageidx = (self.pageidx == self.pagemax) and 1 or (self.pageidx + 1)
	self.inst:DoTaskInTime(delay, function() self:ChangeFlavourText() end)
end
