local function onattacked(inst,data )
	
	if inst.components.follower.leader == data.attacker then
		inst.components.follower:SetLeader(nil)
	end

end

local Follower = Class(function(self, inst)
    self.inst = inst
    self.leader = nil
    self.targettime = nil
    self.maxfollowtime = nil
    self.canaccepttarget = true

    self.inst:ListenForEvent("attacked", onattacked)
end)

--[[
local willStopFollowing = {}
local function FollowerUpdate(dt)
	local tick = TheSim:GetTick()
	if willStopFollowing[tick] then
		for k,v in pairs(willStopFollowing[tick]) do
			if v:IsValid() and v.components.follower then
			    v:PushEvent("loseloyalty", {leader=v.components.follower.leader})
				v.components.follower:SetLeader(nil)
				v.components.follower.targettime = nil
				v.components.follower.targettick = nil
			end
		end
		willStopFollowing[tick] = nil
	end	
end
--]]

function Follower:GetDebugString()
    local str = "Following "..tostring(self.leader)
	if self.targettime then
		str = str..string.format(" Stop in %2.2fs, %2.2f%%", self.targettime - GetTime(), 100*self:GetLoyaltyPercent())
	end
	return str
end

function Follower:SetLeader(inst)
    if self.leader and self.leader.components.leader then
        self.leader.components.leader:RemoveFollower(self.inst)
    end
    if inst and inst.components.leader then
        inst.components.leader:AddFollower(self.inst)
    end
    self.leader = inst
    
    if inst == nil then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
    end
end


function Follower:GetLoyaltyPercent()
    if self.targettime and self.maxfollowtime then
        local timeLeft = math.max(0, self.targettime - GetTime())
        return timeLeft / self.maxfollowtime
    end
    return 0
end


local function stopfollow(inst)
	if inst:IsValid() and inst.components.follower then
		inst:PushEvent("loseloyalty", {leader=inst.components.follower.leader})
		inst.components.follower:SetLeader(nil)
	end
end

function Follower:AddLoyaltyTime(time)
    
    local currentTime = GetTime()
    local timeLeft = self.targettime or 0
    timeLeft = math.max(0, timeLeft - currentTime)
    timeLeft = math.min(self.maxfollowtime or 0, timeLeft + time)
    
    self.targettime = currentTime + timeLeft

	if self.task then
		self.task:Cancel()
		self.task = nil
	end
	self.task = self.inst:DoTaskInTime(timeLeft, stopfollow)

end

function Follower:StopFollowing()
	if self.inst:IsValid() then
		self.inst:PushEvent("loseloyalty", {leader=self.inst.components.follower.leader})
		self.inst.components.follower:SetLeader(nil)
	end
end

function Follower:IsNearLeader(dist)
    return self.leader and self.inst:IsNear(self.leader, dist)
end

function Follower:OnSave()
    local time = GetTime()
    if self.targettime and self.targettime > time then
        return {time = math.floor(self.targettime - time) }
    end
end

function Follower:OnLoad(data)
    if data.time then
        self:AddLoyaltyTime(data.time)
    end
end

function Follower:LongUpdate(dt)
	if self.leader and self.task and self.targettime then
		
		self.task:Cancel()
		self.task = nil
		
		local time = GetTime()
		local time_left = self.targettime - GetTime() - dt
		if time_left < 0 then
			self:SetLeader(nil)	
		else
			self.targettime = GetTime() + time_left
			self.task = self.inst:DoTaskInTime(time_left, stopfollow)
		end
	end
end

--RegisterStaticComponentUpdate("follower", FollowerUpdate)

return Follower
