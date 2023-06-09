RunAway = Class(BehaviourNode, function(self, inst, hunterparams, see_dist, safe_dist, fn, runhome)
    BehaviourNode._ctor(self, "RunAway")
    self.safe_dist = safe_dist
    self.see_dist = see_dist
    self.hunterparams = hunterparams
    self.inst = inst
    self.runshomewhenchased = runhome
    self.shouldrunfn = fn
end)

function RunAway:__tostring()
    return string.format("RUNAWAY %f from: %s", self.safe_dist, tostring(self.hunter))
end

function RunAway:GetRunAngle(pt, hp)

    if self.avoid_angle then
        local avoid_time = GetTime() - self.avoid_time
        if avoid_time < 1 then
            return self.avoid_angle
        else
            self.avoid_time = nil
            self.avoid_angle = nil
        end
    end

    local angle = self.inst:GetAngleToPoint(hp) + 180 -- + math.random(30)-15
    if angle > 360 then angle = angle - 360 end

    --print(string.format("RunAway:GetRunAngle me: %s, hunter: %s, run: %2.2f", tostring(pt), tostring(hp), angle))
    
	local radius = 6

    local result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, false) -- try avoiding walls
    if not result_angle then
        result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, true) -- ok don't try to avoid walls, but at least avoid water
    end
    if not result_angle then
        return angle -- ok whatever, just run
    end

	if result_angle then
		result_angle = result_angle/DEGREES
		if deflected then
			self.avoid_time = GetTime()
			self.avoid_angle = result_angle
		end
		return result_angle
	end

    return nil
end

function RunAway:Visit()
    
    if self.status == READY then
		if type(self.hunterparams) == "string" then
			self.hunter = FindEntity(self.inst, self.see_dist, function(guy)
			    return not guy:HasTag("notarget")
			end, {self.hunterparams})
		else
			self.hunter = FindEntity(self.inst, self.see_dist, self.hunterparams)
		end
        
        if self.hunter and self.shouldrunfn and not self.shouldrunfn(self.hunter) then
            self.hunter = nil
        end
        
        if self.hunter then
            self.status = RUNNING
        else
            self.status = FAILED
        end
        
    end

    if self.status == RUNNING then
        if not self.hunter or not self.hunter.entity:IsValid() then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
        else
        
            if self.runshomewhenchased and
	           self.inst.components.homeseeker then
	            self.inst.components.homeseeker:GoHome(true)
            else
                local pt = Point(self.inst.Transform:GetWorldPosition())
                local hp = Point(self.hunter.Transform:GetWorldPosition())

                local angle = self:GetRunAngle(pt, hp)
                if angle then
                    self.inst.components.locomotor:RunInDirection(angle)
                else
                    self.status = FAILED
                    self.inst.components.locomotor:Stop()
                end
        
                if distsq(hp, pt) > self.safe_dist*self.safe_dist then
                    self.status = SUCCESS
                    self.inst.components.locomotor:Stop()
                end
            end
            
            
        end
    end
end
