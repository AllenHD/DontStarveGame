local Fader = Class(function(self, inst)
    self.inst = inst

    self.values = {}
    self.numvals = 0
end)

function Fader:Fade(startval, endval, time, setter, atend)
    
    local rate = (endval-startval)/time
    table.insert(self.values, {val=startval, v2 = endval, t=time, rate = rate, fn = setter, atend = atend})
    
    self.numvals = self.numvals + 1
    
    if self.numvals == 1 then
        self.inst:StartUpdatingComponent(self)
    end
end

function Fader:StopAll()
    self.values = {}
    self.inst:StartUpdatingComponent(self)
end

function Fader:OnUpdate(dt)

    for k,v in pairs(self.values) do
        v.t = v.t - dt
        if v.t <= 0 then
            v.val = v.v2
        else
            v.val = v.val + v.rate*dt
        end
        
        v.fn(v.val)
        if v.t <= 0 then
        
            if v.atend then
                v.atend()
            end
            
            self.values[k] = nil
            self.numvals = self.numvals - 1
        end
    end
    
    if self.numvals == 0 then
        self.inst:StopUpdatingComponent(self)
    end

end

return Fader