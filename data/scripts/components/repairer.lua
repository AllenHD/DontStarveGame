local Repairer = Class(function(self, inst)
    self.inst = inst
    self.value = 0
	self.repairmaterial = nil

end)

function Repairer:CollectUseActions(doer, target, actions, right)
    
    if right and target.components.repairable and target.components.repairable.repairmaterial == self.repairmaterial and target.components.health and target.components.health:GetPercent() < 1 then
        table.insert(actions, ACTIONS.REPAIR)
    end
end


return Repairer
