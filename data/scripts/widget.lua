Widget = Class(function(self, name)
    self.children = {}
    self.callbacks = {}
    self.name = name
    self.inst = CreateEntity()
    self.inst:AddTag("UI")
    self.inst.entity:SetName(name)
    self.inst.entity:AddUITransform()
	self.inst.entity:CallPrefabConstructionComplete()
    
    self.inst:AddComponent("uianim")
    
    self.enabled = true
    self.shown = true
    
    self:HookCallback("rightmousedown", function( inst, data ) self:OnRightMouseDown( data ) end)
    self:HookCallback("rightmouseup", function( inst, data ) self:OnRightMouseUp( data ) end)
    self:HookCallback("leftmousedown", function( inst, data ) self:OnMouseDown( data ) end)
    self:HookCallback("leftmouseup", function( inst, data ) self:OnMouseUp( data ) end)

    self:HookCallback("mouseover", function( inst, data ) self:OnMouseOver( data ) end)
    self:HookCallback("mouseout", function( inst,data ) self:OnMouseOut( data ) end)
    
    self:HookCallback("keydown", function( inst, data ) self:OnKeyDown( data ) end)
    self:HookCallback("keyup", function( inst,data ) self:OnKeyUp( data ) end)    
    
    self:HookCallback("textinput", function( inst, data ) self:OnTextInput( data ) end)
    
    self.over = false
    self.mouse_over_self = false
    self.mouse_over_children = {}
end)


function Widget:ScaleTo(from, to, time, fn)
    self.inst.components.uianim:ScaleTo(from, to, time, fn)
end

function Widget:MoveTo(from, to, time, fn)
    self.inst.components.uianim:MoveTo(from, to, time, fn)
end

function Widget:IsEnabled()
    if not self.enabled then return false end

    if self.parent then
        return self.parent:IsEnabled()
    end

    return true
end

function Widget:GetParent()
    return self.parent
end

function Widget:IsMouseOver()
    return self.over
end

function Widget:Enable()
    self.enabled = true
	self:OnEnable()
end

function Widget:Disable()
    self.enabled = false
	self:OnDisable()
end

function Widget:OnEnable()
end

function Widget:OnDisable()
end

function Widget:RemoveChild(child)
    if child then
        self.children[child] = nil
        child.parent = nil
        child.inst.entity:SetParent(nil)
    end
end

function Widget:KillAllChildren()
    for k,v in pairs(self.children) do
        self:RemoveChild(k)
        k:Kill()
    end
end

function Widget:AddChild(child)
    self.children[child] = true
    child.parent = self
    child.inst.entity:SetParent(self.inst.entity)
    return child
end

function Widget:Hide()
    self.inst.entity:Hide(false)
    self.shown = false
	self:OnHide()
end

function Widget:Show()
    self.inst.entity:Show(false)
    self.shown = true
	self:OnShow()

end

function Widget:Kill()
	self:KillAllChildren()
    if self.parent then
        self.parent.children[self] = nil
    end
    self:StopFollowMouse()
    self.inst:Remove()
end

function Widget:GetWorldPosition()
    return Vector3(self.inst.UITransform:GetWorldPosition())
end

function Widget:GetPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:Nudge(offset)
    local o_pos = self:GetLocalPosition()
    local n_pos = o_pos + offset
    self:SetPosition(n_pos)
end

function Widget:GetLocalPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:SetPosition(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetPosition(pos,y,z)
    else
        self.inst.UITransform:SetPosition(pos.x,pos.y,pos.z)
    end
end

function Widget:SetRotation(angle)
    self.inst.UITransform:SetRotation(angle)
end

	
function Widget:SetMaxPropUpscale(val)
	self.inst.UITransform:SetMaxPropUpscale(val)
end

function Widget:SetScaleMode(mode)
	self.inst.UITransform:SetScaleMode(mode)
end

function Widget:SetScale(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetScale(pos,y,z)
    else
        self.inst.UITransform:SetScale(pos.x,pos.y,pos.z)
    end
end

function Widget:HookCallback(event, fn)
    if self.callbacks[event] then
        self.inst:RemoveEventCallback(event, self.callbacks[event])
    end
    self.callbacks[event] = fn
    self.inst:ListenForEvent(event, fn)
end


function Widget:SetVAnchor(anchor)
    --assert(self.parent == nil)
    self.inst.UITransform:SetVAnchor(anchor)
end

function Widget:SetHAnchor(anchor)
    --assert(self.parent == nil)
    self.inst.UITransform:SetHAnchor(anchor)
end

function Widget:OnShow()
end

function Widget:OnHide()
end

function Widget:OnMouseDown( data )
	--print("Widget:OnMouseDown", self, self.domousedown)
    if self.domousedown and not self:domousedown( data ) then
		--print("...handled")
        return
    end

    if self.parent then
		--print("...bubbling up")
        self.parent:OnMouseDown( data )
    end
end

function Widget:OnMouseUp( data )
    if self.domouseup and not self:domouseup( data ) then
        return
    end

    if self.parent then
        self.parent:OnMouseUp( data )
    end
end

function Widget:OnRightMouseDown( data )
    if self.dorightmousedown and not self:dorightmousedown( data ) then
        return
    end

    if self.parent then
        self.parent:OnRightMouseDown( data )
    end
end

function Widget:OnRightMouseUp( data )
    if self.dorightmouseup and not self:dorightmouseup( data ) then
        return
    end

    if self.parent then
        self.parent:OnRightMouseUp( data )
    end
end

function Widget:UpdateMouseOver()
	

    local should_be_over = self.mouse_over_self
    for k,v in pairs(self.mouse_over_children) do
        should_be_over = true
        break
    end
    
    if not self.shown then
		should_be_over = false
    end
    
    if self.over ~= should_be_over then

        self.over = should_be_over
        
        if self.over then
            if self.domouseover then
                self.domouseover()
            end
            
            if self.parent then
                self.parent:OnMouseOverChild(self)
            end
            
        else
            if self.domouseout then
                self.domouseout()
            end
            
            if self.parent then
                self.parent:OnMouseOutChild(self)
            end
        end
    end
end

function Widget:SetTooltip(str)
    self.tooltip = str
end

function Widget:GetTooltip()
    if self.over then
        --print ("ov "..self.name)
        for k,v in pairs(self.children) do
            local str = k:GetTooltip()
            if str then
                return str
            end
        end
        return self.tooltip
    end
end


function Widget:OnMouseOverChild( child )
    self.mouse_over_children[child] = true
    
    self:UpdateMouseOver()
    
end

function Widget:OnMouseOutChild( child )
    self.mouse_over_children[child] = nil
    
    self:UpdateMouseOver()
end

function Widget:OnMouseOver()
	--print("Widget:OnMouseOver()", self.name)
    self.mouse_over_self = true

    if self.parent then
        self.parent:OnMouseOverChild(self)
    end

    self:UpdateMouseOver()
end

function Widget:OnMouseOut()
	--print("Widget:OnMouseOut()", self.name)
    self.mouse_over_self = false
    
    if self.parent then
        self.parent:OnMouseOutChild(self)
    end
    
    self:UpdateMouseOver()
end

function Widget:OnKeyDown(data)
	--print("Widget:OnKeyDown", data)
	if self.dokeydown then
		self:dokeydown( data )
	end
end

function Widget:OnKeyUp(data)
	--print("Widget:OnKeyUp", data)
	if self.dokeyup then
		self:dokeyup( data )
	end	
end

function Widget:OnTextInput(data)
	--print("Widget:OnTextInput", data)
	if self.dotextinput then
		self:dotextinput( data )
	end	
end

function Widget:SetLeftMouseDown(fn)
    self.domousedown = fn
end

function Widget:SetRightMouseDown(fn)
    self.dorightmousedown = fn
end

function Widget:SetRightMouseUp(fn)
    self.dorightmouseup = fn
end

function Widget:SetLeftMouseUp(fn)
    self.domouseup = fn
end

function Widget:SetMouseOut(fn)
    self.domouseout = fn
end

function Widget:SetMouseOver(fn)
    self.domouseover = fn
end

function Widget:SetKeyDown(fn)
	self.dokeydown = fn
end

function Widget:SetKeyUp(fn)
	self.dokeyup = fn
end

function Widget:SetTextInput(fn)
	self.dotextinput = fn
end

function Widget:SetClickable(val)
    self.inst.entity:SetClickable(val)
end

function Widget:OnMouseMove(x,y)
    self:SetPosition(x,y,0)
end

function Widget:FollowMouse()
    if not self.followhandler then
        self.followhandler = TheInput:AddMouseMoveHandler(function(x,y) self:OnMouseMove(x,y) end)
        self:SetPosition(TheInput:GetMouseScreenPos())
    end
end

function Widget:StopFollowMouse()
    if self.followhandler then
        self.followhandler:Remove()
    end
    self.followhandler = nil
end


function Widget:GetScale()

	local sx, sy, sz = self.inst.UITransform:GetScale()

	if self.parent then
		local scale = self.parent:GetScale()
		sx = sx*scale.x
		sy = sy*scale.y
		sz = sz*scale.z
	end
	
	return Vector3(sx,sy,sz)
end

function Widget:OnGainFocus()
	--print("Widget:OnGainFocus()")
	if self.dogainfocus then
		self:dogainfocus()
	end	
end

function Widget:OnLoseFocus()
	--print("Widget:OnLoseFocus()")
	if self.dolosefocus then
		self:dolosefocus()
	end	
end

function Widget:SetGainFocus(fn)
	self.dogainfocus = fn
end

function Widget:SetLoseFocus(fn)
	self.dolosefocus = fn
end
