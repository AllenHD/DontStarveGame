local Resurrector = Class(function(self, inst)
    self.inst = inst
	self.penalty = 0
end)



--this is a bit presentationally-specific for component land but whatever.
function Resurrector:Resurrect(dude)
	
    if self.doresurrect then
        self.doresurrect(self.inst, dude)
    end	
    self.used = true
    self.active = false
    self.penalty = 0
     
    --TheSim:SnapCamera()
end

function Resurrector:CanBeUsed()
    return not self.used and self.active
end

function Resurrector:OnBuilt(builder)
	if builder.components.health then
		builder.components.health:RecalculatePenalty()
	end
end


function Resurrector:OnSave()
    return {used = self.used, active = self.active, penalty = self.penalty}
end

function Resurrector:OnLoad(data)
    self.used = data.used or self.used
    self.active = data.active or self.active
	self.penalty = data.penalty or self.penalty
	
    if self.used and self.makeusedfn then 
        self.makeusedfn(self.inst)
    elseif self.active and self.makeactivefn then 
        self.makeactivefn(self.inst)
    end
end

return Resurrector
