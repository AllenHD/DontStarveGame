local easing = require("easing")


local UIAnim = Class(function(self, inst)
    self.inst = inst
end)


function UIAnim:ScaleTo(start, dest, duration, whendone)
    self.scale_start = start
    self.scale_dest = dest
    self.scale_duration = duration
    self.scale_t = 0

    if self.scale_whendone then
		self.scale_whendone()
    end
    self.scale_whendone = whendone
    self.inst:StartUpdatingComponent(self)
end

function UIAnim:MoveTo(start, dest, duration, whendone)
    self.pos_start = start
    self.pos_dest = dest
    self.pos_duration = duration
    self.pos_t = 0
    
    if self.pos_whendone then
		self.pos_whendone()
    end
    self.pos_whendone = whendone
    
    
    self.inst:StartUpdatingComponent(self)
    self.inst.UITransform:SetPosition(start.x, start.y, start.z)
end

function UIAnim:OnUpdate(dt)
    if not self.inst:IsValid() then
		self.inst:StopUpdatingComponent(self)
		return
    end
    
    local done = false
    
    if self.scale_t then
        local val = 1
        local sx, sy, sz = self.inst.UITransform:GetScale()
        if sx and sy and sz then
	        
			self.scale_t = self.scale_t + dt
			if self.scale_t < self.scale_duration then
				val = easing.outCubic( self.scale_t, self.scale_start, self.scale_dest - self.scale_start, self.scale_duration)
			else
				val = self.scale_dest
				self.scale_t = nil
				
				if self.scale_whendone then
					self.scale_whendone()
					self.scale_whendone = nil
				end
				
			end
			self.inst.UITransform:SetScale(sx >= 0 and val or -val, sy >= 0 and val or -val, sz >= 0 and val or -val)
		end
    end

    if self.pos_t then
        local valx = 0
        local valy = 0
        local valz = 0
        --local sx, sy, sz = self.inst.UITransform:GetPosition()
        
        self.pos_t = self.pos_t + dt
        if self.pos_t < self.pos_duration then
            valx = easing.outCubic( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
            valy = easing.outCubic( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
            valz = easing.outCubic( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
        else
            valx= self.pos_dest.x
            valy= self.pos_dest.y
            valz= self.pos_dest.z
            self.pos_t = nil
            if self.pos_whendone then
				self.pos_whendone()
				self.pos_whendone = nil
            end
        end
        self.inst.UITransform:SetPosition(valx, valy, valz)
    end
    
    if not self.scale_t and not self.pos_t then
        self.inst:StopUpdatingComponent(self)
    end
end

return UIAnim
