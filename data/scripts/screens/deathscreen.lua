require "screen"
require "animbutton"
local Progression = require "progressionconstants"


DeathScreen = Class(Screen, function(self, days_survived, start_xp, escaped)

    Widget._ctor(self, "Progress")
    self.owner = GetPlayer()
	self.log = true

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)



    self.bg = self.root:AddChild(Image("data/images/hud.xml", "death_BG.tex"))
    self.progbar = self.root:AddChild(UIAnim())
    
    self.progbar:GetAnimState():SetBank("progressbar")
    self.progbar:GetAnimState():SetBuild("progressbar")
    self.progbar:GetAnimState():PlayAnimation("anim", true)
    self.progbar:GetAnimState():SetPercent("anim", 0)
    self.progbar:SetPosition(Vector3(-316,-35,0))


    local font = BODYTEXTFONT
    

    self.title = self.root:AddChild(Text(TITLEFONT, 75))
    self.title:SetPosition(0,190,0)
    if escaped == nil then
		self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUAREDEAD)   	
	else   
 		self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUESCAPED)
	end

    self.t1 = self.root:AddChild(Text(font, 60))
    self.t1:SetPosition(-150,70,0)
    self.t1:SetString(STRINGS.UI.DEATHSCREEN.SURVIVEDDAYS)

    self.t2 = self.root:AddChild(Text(font, 60))
    self.t2:SetPosition(200,70,0)
    self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAYS)

    self.survivedtext = self.root:AddChild(Text(font, 50))
    self.survivedtext:SetPosition(75,70,0)

    self.leveltext = self.root:AddChild(Text(font, 50))
    self.leveltext:SetHAlign(ANCHOR_LEFT)
    self.leveltext:SetPosition(-260,-40,0)

    self.xptext = self.root:AddChild(Text(NUMBERFONT, 50))
    self.xptext:SetHAlign(ANCHOR_LEFT)
    self.xptext:SetPosition(-230,-110,0)
    
    self.menu = self.root:AddChild(Widget("menu"))
    self.menu:SetPosition(0, -195, 0)


    self.portrait = self.root:AddChild(Image("data/images/saveslot_portraits.xml", "wilson.tex"))
    self.portrait:SetPosition(Vector3(250,-145, 0))
    self.portrait:SetScale(1.5,1.5,1.5)
    self.portrait:SetTint(0,0,0,1)
    self.portrait:SetVRegPoint(ANCHOR_BOTTOM)
    self:ShowButtons(false)
    

    self.rewardtext = self.root:AddChild(Text(font, 40))
    self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.NEXTREWARD)
    self.rewardtext:SetHAlign(ANCHOR_LEFT)
    self.rewardtext:SetPosition(60,-110,0)

    local but_w = 192
    local spacing = 32
    local menu_items = 
    {
        {name = STRINGS.UI.DEATHSCREEN.MAINMENU, fn = function() self:OnMenu(escaped) end}
    }

    if escaped then
        table.insert(menu_items,  {name = STRINGS.UI.DEATHSCREEN.CONTINUE, fn = function() self:OnContinue() end})
    else
        table.insert(menu_items,  {name = STRINGS.UI.DEATHSCREEN.RETRY, fn = function() self:OnRetry() end})
    end

    local total_width = (but_w + spacing)*(#menu_items-1)  


    for k,v in ipairs(menu_items) do
        local button = self.menu:AddChild(AnimButton("button"))
        button:SetPosition(-total_width/2 + (but_w+spacing)*(k-1), 0, 0)
        button:SetText(v.name)
        button:SetOnClick(v.fn)
        button.text:SetColour(0,0,0,1)
        button:SetFont(BUTTONFONT)
        button:SetTextSize(40)
    end



    
    self:ShowResults(days_survived, start_xp)
end)

function DeathScreen:OnRetry()
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, function()
        local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot()}
        TheSim:SetInstanceParameters(params)
        TheSim:Reset()
    end)
end

function DeathScreen:OnContinue()
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, function()
        local params = json.encode{reset_action="loadslot", save_slot = SaveGameIndex:GetCurrentSaveSlot()}
        TheSim:SetInstanceParameters(params)
        TheSim:Reset()
    end)
end

function DeathScreen:OnMenu(escaped)
	
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, function()

        if escaped then
            TheSim:SetInstanceParameters()
            TheSim:Reset()
        else
            SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function() 
                TheSim:SetInstanceParameters()
                TheSim:Reset()
            end)
        end
    end)
end

function DeathScreen:ShowButtons(show)
    if show then
		self.menu:Show()
    else
		self.menu:Hide()
    end
end


function DeathScreen:SetStatus(xp, ignore_image)
    local level, percent = Progression.GetLevelForXP(xp)

    if not ignore_image then
        self.portrait:SetTint(0,0,0,1)
        local reward = Progression.GetRewardForLevel(level)
        if reward then
            self.portrait:Show()

			--print("data/images/saveslot_portraits/"..reward..".tex")
            self.portrait:SetTexture("data/images/saveslot_portraits.xml", reward..".tex")
        else
            self.portrait:Hide()
        end
    end
    
    
    self.leveltext:SetString(STRINGS.UI.DEATHSCREEN.LEVEL.." "..tostring(level+1))
    self.progbar:GetAnimState():SetPercent("anim", percent)
    
	self.xptext:SetString(string.format("XP: %d", xp))
    
    if xp >= Progression.GetXPCap() then
		self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.ATCAP)
	end
	
end

function DeathScreen:ShowResults(days_survived, start_xp)
    
    self:Show()
    local xpreward = Progression.GetXPForDays(days_survived)
    local xpcap = Progression.GetXPCap()
    if start_xp + xpreward > xpcap then
		xpreward = xpcap - start_xp
    end
    
    
    if self.thread then
        KillThread(self.thread)
    end
        self:SetStatus(start_xp)
        
        self.thread = self.inst:StartThread( function() 
        self:ShowButtons(false)
        local end_xp = start_xp + xpreward
        self.survivedtext:SetString(tostring(days_survived))
        
        if days_survived == 1 then
			self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAY)
		end
		
        local start_level, start_percent = Progression.GetLevelForXP(start_xp)
        local end_level, end_percent = Progression.GetLevelForXP(end_xp)
        
        local fills = end_level - start_level + 1
        local dt = GetTickTime()
        
        local xplevel = start_level 
        local short = fills > 1
        local total_fill_time = short and 2 or 5
        
        local fill_rate = 1/total_fill_time
        --print (start_level, start_percent, "TO", end_level, end_percent, "->", fills)
        
        for k = 1, fills do
            
            local xp_for_level, level_xp_size = Progression.GetXPForLevel(xplevel)
            if xp_for_level then
                local end_p = k == fills and end_percent or 1
                local p = k == 1 and start_percent or 0
                if end_p > p then
                    
                    --print (k, xplevel, xp_for_level, level_xp_size, p, end_p, total_fill_time)
                    
                    if short then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_fast", "fillsound")
                    else
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_slow", "fillsound")
                    end
                    
                    repeat
                        p = p + dt*fill_rate
                        local xp = xp_for_level + math.min(end_p,p)*level_xp_size
                        self:SetStatus(xp, p >= 1)
                        
                        self.progbar:GetAnimState():SetPercent("anim", p)
                        Yield()
                    until p >= end_p
                    self.owner.SoundEmitter:KillSound("fillsound")
                    if end_p >= 1 then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_unlock")
                        self.progbar:GetAnimState():SetPercent("anim", 1)
                        self.portrait:SetTint(1,1,1,1)
                        self.portrait:ScaleTo(2, 1.5, .25)
                        Sleep(1)
                    end
                end
            end
            xplevel = xplevel + 1
        end
        
        
        self:ShowButtons(true)
        self.thread = nil
    end )
    
    return xpreward
end

