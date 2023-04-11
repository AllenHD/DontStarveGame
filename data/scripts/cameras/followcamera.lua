require("camerashake")


FollowCamera = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self:SetDefault()
    self:Snap()
    
    self.time_since_zoom = nil

    self.currentpos = Vector3(0,0,0)
end)

function FollowCamera:SetDefault()
    self.targetpos = Vector3(0,0,0)
    self.targetoffset = Vector3(0,1.5,0)

    if self.headingtarget == nil then
        self.headingtarget = 45
    end

    self.fov = 35
    self.pangain = 4
    self.headinggain = 20
    self.distancegain = 1

    self.zoomstep = 4
    self.distancetarget = 30

    self.mindist = 15
    self.maxdist = 50 --40
    
    self.mindistpitch = 30
    self.maxdistpitch = 60--60 
    self.paused = false
    self.shake = nil
    self.controllable = true
    self.cutscene = false


    if GetWorld() and GetWorld():IsCave() then
        self.mindist = 15
        self.maxdist = 35
        self.mindistpitch = 25
        self.maxdistpitch = 40
        self.distancetarget = 25
    end

end

function FollowCamera:GetRightVec()
    return Vector3(math.cos((self.headingtarget + 90)*DEGREES), 0, math.sin((self.headingtarget+ 90)*DEGREES))
end

function FollowCamera:GetDownVec()
    return Vector3(math.cos((self.headingtarget)*DEGREES), 0, math.sin((self.headingtarget)*DEGREES))
end

function FollowCamera:SetPaused(val)
	self.paused = val
end

function FollowCamera:SetMinDistance(distance)
    self.mindist = distance
end

function FollowCamera:SetGains(pan, heading, distance)
    self.distancegain = distance
    self.pangain = pan
    self.headinggain = heading
end

function FollowCamera:IsControllable()
    return self.controllable
end

function FollowCamera:SetControllable(val)
    self.controllable = val
end

function FollowCamera:CanControl()
    return self.controllable
end

function FollowCamera:SetOffset(offset)
    self.targetoffset = offset
end

function FollowCamera:GetDistance()
    return self.distancetarget
end

function FollowCamera:SetDistance(dist)
    self.distancetarget = dist
end

function FollowCamera:Shake(type, duration, speed, scale)
    self.shake = CameraShake(type, duration, speed, scale)
end

function FollowCamera:SetTarget(inst)
    self.target = inst
    self.targetpos.x, self.targetpos.y, self.targetpos.z = self.target.Transform:GetWorldPosition()
    self.currentpos.x, self.currentpos.y, self.currentpos.z = self.target.Transform:GetWorldPosition()
end

function FollowCamera:Apply()
    
    local dir = Vector3(0,0,0)
    dir.x = -math.cos(self.pitch*DEGREES)*math.cos(self.heading*DEGREES)
    dir.y = -math.sin(self.pitch*DEGREES)
    dir.z = -math.cos(self.pitch*DEGREES)*math.sin(self.heading*DEGREES)

    local pos = dir*(-self.distance) + self.currentpos 
    local right = Vector3(math.cos((self.heading+90)*DEGREES), 0, math.sin((self.heading+90)*DEGREES))
    local up = dir:Cross(right)

	
    TheSim:SetCameraPos(pos.x,pos.y,pos.z)
    TheSim:SetCameraDir(dir.x,dir.y,dir.z)
    TheSim:SetCameraUp(up.x, up.y, up.z)
    TheSim:SetCameraFOV(self.fov)
    
    local listenpos = dir*(-self.distance*.1) + self.currentpos
    TheSim:SetListener(listenpos.x, listenpos.y, listenpos.z, dir.x, dir.y, dir.z, up.x, up.y, up.z)
    
end

local lerp = function(lower, upper, t)
   if t > 1 then t = 1 elseif t < 0 then t = 0 end
   return lower*(1-t)+upper*t 
end

function FollowCamera:GetHeading()
    return self.heading
end
function FollowCamera:GetHeadingTarget()
    return self.headingtarget
end

function FollowCamera:SetHeadingTarget(r)
    self.headingtarget = r
end

function FollowCamera:ZoomIn()
    self.distancetarget = self.distancetarget - self.zoomstep
    if self.distancetarget < self.mindist then
        self.distancetarget = self.mindist
        
    end
    self.time_since_zoom = 0
    
end

function FollowCamera:ZoomOut()
    self.distancetarget = self.distancetarget + self.zoomstep
    if self.distancetarget > self.maxdist then
        self.distancetarget = self.maxdist
    end    
	self.time_since_zoom = 0	
end


function FollowCamera:Snap()
    if self.target then
        self.targetpos = Vector3(self.target.Transform:GetWorldPosition()) + self.targetoffset
    else
        self.targetpos = self.targetoffset
    end

    self.currentpos = self.targetpos
    self.heading = self.headingtarget
    self.distance = self.distancetarget

    local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
    self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)
    
    self:Apply()
end

function FollowCamera:CutsceneMode(b)
    self.cutscene = b
end

function FollowCamera:SetCustomLocation(loc)
    self.targetpos = loc
end

function FollowCamera:Update(dt)

	if self.paused then
		return
	end

    if self.cutscene then

        self.currentpos = lerp(self.currentpos, self.targetpos + self.targetoffset, dt*self.pangain)


        if self.shake then
            local shakeOffset = self.shake:Update(dt)
            if shakeOffset then
                local upOffset = Vector3(0, shakeOffset.y, 0)
                local rightOffset = self:GetRightVec() * shakeOffset.x
                self.currentpos = self.currentpos + upOffset + rightOffset
            else
                self.shake = nil
            end
        end

        if math.abs(self.heading - self.headingtarget) > .01 then
            self.heading = lerp(self.heading, self.headingtarget, dt*self.headinggain)    
        end

        if math.abs(self.distance - self.distancetarget) > .01 then
            self.distance = lerp(self.distance, self.distancetarget, dt*self.distancegain)    
        end

        local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
        self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)

    else
    	if self.time_since_zoom then
    		self.time_since_zoom = self.time_since_zoom + dt
    	
    		if self.should_push_down and self.time_since_zoom > .25 then
    			self.distancetarget = self.distance - self.zoomstep
    		end
    	end

        if self.target then
            self.targetpos = Vector3(self.target.Transform:GetWorldPosition()) + self.targetoffset
        else
            self.targetpos = self.targetoffset
        end

        self.currentpos = lerp(self.currentpos, self.targetpos, dt*self.pangain)
        
        if self.shake then
            local shakeOffset = self.shake:Update(dt)
            if shakeOffset then
                local upOffset = Vector3(0, shakeOffset.y, 0)
                local rightOffset = self:GetRightVec() * shakeOffset.x
                self.currentpos = self.currentpos + upOffset + rightOffset
            else
                self.shake = nil
            end
        end
        
        if math.abs(self.heading - self.headingtarget) > .01 then
            self.heading = lerp(self.heading, self.headingtarget, dt*self.headinggain)    
        else
            self.heading = self.headingtarget
        end


        if math.abs(self.distance - self.distancetarget) > .01 then
            self.distance = lerp(self.distance, self.distancetarget, dt*self.distancegain)    
        else
            self.distance = self.distancetarget
        end
        
        local percent_d = (self.distance - self.mindist)/ (self.maxdist - self.mindist)
        self.pitch = lerp(self.mindistpitch, self.maxdistpitch, percent_d)
    end
    self:Apply()

    
end


return FollowCamera
