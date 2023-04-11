local Workable = Class(function(self, inst)
    self.inst = inst
    self.onwork = nil
    self.onfinish = nil
    self.action = ACTIONS.CHOP
    self.workleft = 10
end)

function Workable:GetDebugString()
    return "workleft"..self.workleft
end


function Workable:AddStage(amount)
    table.insert(self.stages, amount)
end

function Workable:SetWorkAction(act)
    self.action = act
end

function Workable:SetWorkLeft(work)
    self.workleft = work
end


function Workable:WorkedBy(worker, numworks)
    numworks = numworks or 1
    worker:PushEvent("working", {target = self.inst})
    self.inst:PushEvent("worked", {worker = worker})
    self.workleft = self.workleft - numworks
    
    if self.onwork then
        self.onwork(self.inst, worker, self.workleft)
    end

    if self.workleft <= 0 then        
        if self.onfinish then self.onfinish(self.inst, worker) end        
        self.inst:PushEvent("workfinished")

        worker:PushEvent("finishedwork", {target = self.inst, action = self.action})
    end
end

function Workable:IsActionValid(action, right)
    if action == ACTIONS.HAMMER and not right then
		return false
    end
    
    return self.workleft > 0 and action == self.action
    
end

function Workable:SetOnWorkCallback(fn)
    self.onwork = fn
end

function Workable:SetOnFinishCallback(fn)
    self.onfinish = fn
end

return Workable