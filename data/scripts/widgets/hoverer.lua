
local YOFFSETUP = 40
local YOFFSETDOWN = 60

HoverText = Class(Widget, function(self, owner)
    Widget._ctor(self, "HoverText")
	self.owner = owner
    self.isFE = false
    self:SetClickable(false)
    --self:MakeNonClickable()
    self.text = self:AddChild(Text(UIFONT, 30))
    self.text:SetPosition(0,YOFFSETUP,0)
    self.secondarytext = self:AddChild(Text(UIFONT, 30))
    self.secondarytext:SetPosition(0,-YOFFSETDOWN,0)
    self:FollowMouseConstrained()
end)

function HoverText:Update()
	
    local str = nil
    if self.isFE == false then 
        str = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
    else
        str = self.owner:GetTooltip()
    end

    local secondarystr = nil
 
    if not str and self.isFE == false then
        local lmb = self.owner.components.playeractionpicker:GetLeftMouseAction()
        if lmb then
            
            str = lmb:GetActionString()
            
            if lmb.target and lmb.invobject == nil and lmb.target ~= lmb.doer then
				local name = lmb.target:GetDisplayName() or (lmb.target.components.named and lb.target.components.named.name)
                
                
                if name then
					local adjective = lmb.target:GetAdjective()
					
					if adjective then
						str = str.. " " .. adjective .. " " .. name
					else
						str = str.. " " .. name
					end
					
					if lmb.target.components.stackable and lmb.target.components.stackable.stacksize > 1 then
	                    str = str .. " x" .. tostring(lmb.target.components.stackable.stacksize)
					end
				end
            end
        end
        local rmb = self.owner.components.playeractionpicker:GetRightMouseAction()
        if rmb then
            secondarystr = STRINGS.RMB .. ": " .. rmb:GetActionString()
        end
    end

    if str then
        self.text:SetString(str)
        self.text:Show()
    else
        self.text:Hide()
    end
    if secondarystr then
        self.secondarytext:SetString(secondarystr)
        self.secondarytext:Show()
    else
        self.secondarytext:Hide()
    end

    local changed = (self.str ~= str) or (self.secondarystr ~= secondarystr)
    self.str = str
    self.secondarystr = secondarystr
    if changed then
        local pos = TheInput:GetMouseScreenPos()
        self:UpdatePosition(pos.x, pos.y)
    end
end

function HoverText:UpdatePosition(x,y)


	local scale = self:GetScale()
	
    local scr_w, scr_h = TheSim:GetScreenSize()

    local w = 0
    local h = 0

    if self.text and self.str then
        local w0, h0 = self.text:GetRegionSize()
        w = math.max(w, w0)
        h = math.max(h, h0)
    end
    if self.secondarytext and self.secondarystr then
        local w1, h1 = self.secondarytext:GetRegionSize()
        w = math.max(w, w1)
        h = math.max(h, h1)
    end

	w = w*scale.x
	h = h*scale.y
	
    x = math.max(x, w/2)
    x = math.min(x, scr_w - w/2)

    y = math.max(y, h/2 + YOFFSETDOWN*scale.y)
    y = math.min(y, scr_h - h/2 - YOFFSETUP*scale.x)

    self:SetPosition(x,y,0)
end

function HoverText:FollowMouseConstrained()
    if not self.followhandler then
        self.followhandler = TheInput:AddMouseMoveHandler(function(x,y) self:UpdatePosition(x,y) end)
        local pos = TheInput:GetMouseScreenPos()
        self:UpdatePosition(pos.x, pos.y)
    end
end
