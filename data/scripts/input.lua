require "events"

Input = Class(function(self)
    self.onkey = EventProcessor()     -- all keys, down and up, with key param
    self.onkeyup = EventProcessor()   -- specific key up, no parameters
    self.onkeydown = EventProcessor() -- specific key down, no parameters
    self.onmouseup = EventProcessor()
    self.onmousedown = EventProcessor()
    self.onmousemove = EventProcessor()
    self.ontextinput = EventProcessor()
    self.ongesture = EventProcessor()
    
    self.hoverinst = nil
    self.mouseoversenabled = true
    
    self.enabledebugtoggle = true
end)

function Input:AddTextInputHandler( fn )
    return self.ontextinput:AddEventHandler("text", fn)
end

function Input:AddKeyUpHandler( key, fn )
    return self.onkeyup:AddEventHandler(key, fn)
end

function Input:AddKeyDownHandler( key, fn )
    return self.onkeydown:AddEventHandler(key, fn)
end

function Input:AddKeyHandler( fn )
    return self.onkey:AddEventHandler("onkey", fn)
end

function Input:AddMouseButtonHandler( button, down, fn)
    if down then
        return self.onmousedown:AddEventHandler(button, fn)
    else
        return self.onmouseup:AddEventHandler(button, fn)
    end
end

function Input:AddMouseMoveHandler( fn )
    return self.onmousemove:AddEventHandler("move", fn)
end

function Input:AddGestureHandler( gesture, fn )
    return self.ongesture:AddEventHandler(gesture, fn)
end

function Input:OnMouseMove(x,y)
    self.onmousemove:HandleEvent("move", x, y)
end

function Input:OnMouseButton(button, down, x,y)
    if down then
        self.onmousedown:HandleEvent(button, x, y)
    else
        self.onmouseup:HandleEvent(button, x, y)
    end
    
    if self.hoverinst then
        if button == MOUSEBUTTON_LEFT then
            self.hoverinst:PushEvent(down and "leftmousedown" or "leftmouseup", {x = x, y = y})
        elseif button == MOUSEBUTTON_RIGHT then
            self.hoverinst:PushEvent(down and "rightmousedown" or "rightmouseup", {x = x, y = y})
        end
    end
end

function Input:OnKey(key, down)
	self.onkey:HandleEvent("onkey", key, down)

	if down then
		self.onkeydown:HandleEvent(key)
	else
		self.onkeyup:HandleEvent(key)
	end
end

function Input:OnText(text)
	--print("Input:OnText", text)
	self.ontextinput:HandleEvent("text", text)
end

function Input:OnGesture(gesture)
	self.ongesture:HandleEvent(gesture)
end


function Input:OnFrameStart()
    self.hoverinst = nil
    self.hovervalid = false
end

function Input:GetMouseScreenPos()
    local x, y = TheSim:GetMousePos()
    return Vector3(x,y,0)
end

function Input:GetMouseWorldPos()
    local x,y,z = TheSim:ProjectScreenPos(TheSim:GetMousePos())
    if x and y and z then
        return Vector3(x,y,z)
    end
end

function Input:GetAllEntitiesUnderMouse()
    return self.entitiesundermouse or {}
end

function Input:GetWorldEntityUnderMouse()
    if self.hoverinst and self.hoverinst.Transform then
        return self.hoverinst 
    end
end

function Input:DisableMouseovers()
    self.mouseoversenabled = false

    if self.hoverinst then
        self.hoverinst:PushEvent("mouseout")
        self.hoverinst = nil
    end
end

function Input:EnableMouseovers()
    self.mouseoversenabled = true
end

function Input:EnableDebugToggle(enable)
    self.enabledebugtoggle = enable
end

function Input:IsDebugToggleEnabled()
    return self.enabledebugtoggle
end

function Input:GetHUDEntityUnderMouse()
    if self.hoverinst and not self.hoverinst.Transform then
        return self.hoverinst 
    end
end

function Input:IsMouseDown(button)
    return TheSim:GetMouseButtonState(button)
end

function Input:IsKeyDown(key)
    return TheSim:IsKeyDown(key)
end

function Input:IsKeyUp(key)
    return TheSim:IsKeyUp(key)
end


function Input:OnUpdate()
    if self.mouseoversenabled then

        self.entitiesundermouse = TheSim:GetEntitiesAtScreenPoint(TheSim:GetMousePos())
        
        local inst = self.entitiesundermouse[1]
        if inst ~= self.hoverinst then
            if inst then
                inst:PushEvent("mouseover")
            end

            if self.hoverinst then
                self.hoverinst:PushEvent("mouseout")
            end
            
            self.hoverinst = inst
        end
    end
end

---------------- Globals

TheInput = Input()

function OnMouseMove(x, y)
    TheInput:OnMouseMove(x,y)
end

function OnMouseButton(button, is_up, x, y)
    TheInput:OnMouseButton(button, is_up, x,y)
end

function OnInputKey(key, is_up)
    TheInput:OnKey(key, is_up)
end

function OnInputText(text)
	TheInput:OnText(text)
end

function OnGesture(gesture)
	TheInput:OnGesture(gesture)
end

return Input
