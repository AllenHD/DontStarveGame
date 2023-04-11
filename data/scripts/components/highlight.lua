local easing = require("easing")

local Highlight = Class(function(self, inst)
    self.inst = inst
    self.mouseover = nil
	self.base_add_colour = Vector3(0,0,0)
	self.highlight_add_colour = Vector3(0,0,0)
end)


function Highlight:SetAddColour(col)
	self.base_add_colour = col
	self:ApplyColour()
end

function Highlight:Flash(toadd, timein, timeout)
    self.flashadd = toadd
    self.flashtimein = timein
    self.flashtimeout = timeout
    self.t = 0
    self.flashing = true
    self.goingin = true
    
    self.inst:StartUpdatingComponent(self)
    
end

function Highlight:OnUpdate(dt)

    if not self.inst:IsValid() then
		self.inst:StopUpdatingComponent(self)
		self.flashing = false
		return
    end
    
    self.t = self.t + dt
    if self.flashing then
        
        local val = 0
        if self.goingin then
            if self.t > self.flashtimein then
                self.goingin = false
                self.t = 0
            end
            val = easing.outCubic( self.t, 0, self.flashadd, self.flashtimein)             
        end
    
        if not self.goingin then
            if self.t > self.flashtimeout then
                self.flashing = false
            end
            val = easing.outCubic( self.t, self.flashadd, 0, self.flashtimeout)                     
        end
        
        if self.mouseover then
            val = val + .2
        end
        
        self.highlight_add_colour = Vector3(val,val,val)
    end


    if not self.flashing then
        self.inst:StopUpdatingComponent(self)
        local val = 0
        
        if self.mouseover then
            val = .2
        end
        
        self.highlight_add_colour = Vector3(val,val,val)
    end

	self:ApplyColour()

end

function Highlight:ApplyColour()
    if self.inst.AnimState then
		self.inst.AnimState:SetAddColour(self.highlight_add_colour.x+ self.base_add_colour.x, self.highlight_add_colour.y + self.base_add_colour.y, self.highlight_add_colour.z + self.base_add_colour.z, 0)
	end
end

function Highlight:Highlight()
    self.mouseover = true
    
    if self.inst:IsValid() and self.inst:HasTag("player") or TheSim:GetLightAtPoint(self.inst.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF then
        local m = .2
		self.highlight_add_colour = Vector3(m,m,m)
    end

	self:ApplyColour()    
end

function Highlight:UnHighlight()
    self.mouseover = nil
	self.highlight_add_colour = Vector3(0,0,0)	
	self:ApplyColour()    
    
end

return Highlight
