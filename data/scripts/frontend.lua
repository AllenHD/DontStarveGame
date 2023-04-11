local easing = require("easing")


FrontEnd = Class(function(self, name)
	self.screenstack = {}
	
	self.screenroot = Widget("screenroot")
	self.overlayroot = Widget("overlayroot")
	
    self.blackoverlay = Image("data/images/global.xml", "square.tex")
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:Hide()
	self.overlayroot:AddChild(self.blackoverlay)
	
    
    self.title = Text(TITLEFONT, 100)
    self.title:SetPosition(0, -30, 0)
    self.title:Hide()
    self.title:SetVAnchor(ANCHOR_MIDDLE)
    self.title:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.title)
	
    self.subtitle = Text(TITLEFONT, 70)
    self.subtitle:SetPosition(0, 70, 0)
    self.subtitle:Hide()
    self.subtitle:SetVAnchor(ANCHOR_MIDDLE)
    self.subtitle:SetHAnchor(ANCHOR_MIDDLE)
	self.overlayroot:AddChild(self.subtitle)

	self.errorroot = Widget("errorroot")

	self.gameinterface = CreateEntity()
	self.gameinterface.entity:AddSoundEmitter()
	self.gameinterface.entity:AddGraphicsOptions()
	
	TheInput:AddKeyUpHandler(KEY_BACKSPACE, function() self:OnKeyBackspace() end )
	TheInput:AddKeyUpHandler(KEY_PAUSE, function() self:OnKeyPause() end )

	TheInput:AddKeyHandler(function(key, down) self:OnKey(key, down) end )
	TheInput:AddTextInputHandler(function(text) self:OnTextInput(text) end )

	self.displayingerror = false
end)

function FrontEnd:ShowTitle(text,subtext)
	self.title:SetString(text)
	self.title:Show()
	self.subtitle:SetString(subtext)
	self.subtitle:Show()
end

function FrontEnd:HideTitle()
	self.title:Hide()
	self.subtitle:Hide()
end

function FrontEnd:OnKeyPause()
	print("Toggle pause")
	
	TheSim:ToggleDebugPause()
	TheSim:ToggleDebugCamera()
	
	if TheSim:IsDebugPaused() then
		TheSim:SetDebugRenderEnabled(true)
		if TheCamera.targetpos then
			TheSim:SetDebugCameraTarget(TheCamera.targetpos.x, TheCamera.targetpos.y, TheCamera.targetpos.z)
		end
		
		if TheCamera.headingtarget then
			TheSim:SetDebugCameraRotation(-TheCamera.headingtarget-90)	
		end
	end
end

function FrontEnd:SendScreenEvent(type, message)
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:HandleEvent(type, message)
	end
end


function FrontEnd:GetSound()
	return self.gameinterface.SoundEmitter
end

function FrontEnd:GetGraphicsOptions()
	return self.gameinterface.GraphicsOptions
end

function FrontEnd:SetFadeLevel(alpha)
	--print ("SET FADE LEVEL", alpha)
	if alpha <= 0 then
		if self.blackoverlay then
			self.blackoverlay:Hide()
		end
	else
		self.blackoverlay:Show()
		self.blackoverlay:SetTint(0,0,0,alpha)
	end
end


function FrontEnd:Update(dt)
	dt = math.min(dt, 1/30)
	if self.fade_delay_time then
		self.fade_delay_time = self.fade_delay_time - dt
		if self.fade_delay_time <= 0 then
			self.fade_delay_time = nil
			if self.delayovercb then
				self.delayovercb()
				self.delayovercb = nil
			end
		end
		return
	elseif self.fadedir ~= nil then
		self.fade_time = self.fade_time + dt
		
		local alpha = 0
		if self.fadedir then
			alpha = easing.inOutCubic(self.fade_time, 1, -1, self.total_fade_time)
		else
			alpha = easing.outCubic(self.fade_time, 0, 1, self.total_fade_time)
		end
		
		self:SetFadeLevel(alpha)
		if self.fade_time >= self.total_fade_time then
			self.fadedir = nil
			if self.fadecb then
				local cb = self.fadecb
				self.fadecb = nil
				cb()
			end
		end
	end
	
	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnUpdate(dt)
	end	
end

function FrontEnd:PushScreen(screen)

	--jcheng: don't allow any other screens to push if we're displaying an error
	if not TheFrontEnd:IsDisplayingError() then
		Print(VERBOSITY.DEBUG, 'FrontEnd:PushScreen', screen.name)
		if #self.screenstack > 0 then
			self.screenstack[#self.screenstack]:OnLoseFocus()
		end
		self.screenroot:AddChild(screen)
		table.insert(self.screenstack, screen)
		
		screen:OnGainFocus()
		--self:Fade(true, 2)
	end
end

function FrontEnd:ClearScreens()

	if #self.screenstack > 0 then
		self.screenstack[#self.screenstack]:OnLoseFocus()
	end

	while #self.screenstack > 0 do
		self.screenstack[#self.screenstack]:OnDestroy()
		table.remove(self.screenstack, #self.screenstack)
	end

end

function FrontEnd:DoFadeIn(time_to_take)
	self:Fade(true, time_to_take)	
end

function FrontEnd:Fade(in_or_out, time_to_take, cb, fade_delay_time, delayovercb)
	
	self.fadedir = in_or_out
	self.total_fade_time = time_to_take
	self.fadecb = cb
	self.fade_time = 0
	if in_or_out then
		self:SetFadeLevel(1)
	end
	self.fade_delay_time = fade_delay_time
	self.delayovercb = delayovercb
end

function FrontEnd:PopScreen(screen)
	local old_head = #self.screenstack > 0 and self.screenstack[#self.screenstack]
	
	if screen then
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen', screen.name)
		for k,v in ipairs(self.screenstack) do
			if v == screen then
				table.remove(self.screenstack, k)
				screen:OnDestroy()
				self.screenroot:RemoveChild(screen)
				break
			end
		end
	else
		Print(VERBOSITY.DEBUG,'FrontEnd:PopScreen')
		if #self.screenstack > 0 then
			local screen = self.screenstack[#self.screenstack]
			table.remove(self.screenstack, #self.screenstack)
			screen:OnDestroy()
			self.screenroot:RemoveChild(screen)
		end
		
	end

	if #self.screenstack > 0 and old_head ~= self.screenstack[#self.screenstack] then
		self.screenstack[#self.screenstack]:OnGainFocus()
		--self:Fade(true, 1)
		
	end
end

function FrontEnd:GetActiveScreen()
	if #self.screenstack > 0 and self.screenstack[#self.screenstack] then
		return self.screenstack[#self.screenstack]
	else
		return nil
	end
end

function FrontEnd:ShowScreen(screen, cb)
	self:ClearScreens()	
	if screen then
		self:PushScreen(screen)
	end
end

function FrontEnd:OnKeyBackspace()
	--print("FrontEnd:OnKeyBackspace()")
	if TheInput:IsDebugToggleEnabled() then
		if TheInput:IsKeyDown(KEY_SHIFT) then
			TheSim:ToggleDebugCamera()
		else
			if TheInput:IsKeyDown(KEY_CTRL) then
				TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
			else
				TheSim:SetDebugRenderEnabled(not TheSim:GetDebugRenderEnabled())
			end
		end
	end
end

function FrontEnd:OnKey(key, down)
	--print("FrontEnd:OnKey()", key, down)
	local screen = self:GetActiveScreen()
    if screen then
		if down then
			screen.inst:PushEvent("keydown", key)
		else
			screen.inst:PushEvent("keyup", key)
		end
	end
end

function FrontEnd:OnTextInput(text)
	--print("FrontEnd:OnTextInput()", text)

	local screen = self:GetActiveScreen()
    if screen then
		screen.inst:PushEvent("textinput", text)
	end
end

function FrontEnd:DisplayError(screen)
	if self.displayingerror == false then
	    print("SCRIPT ERROR! Showing error screen")
		self.errorroot:AddChild(screen)
		screen:OnGainFocus()
		self.displayingerror = true
	end
end

function FrontEnd:IsDisplayingError()
	return self.displayingerror
end
