require "class"

local Deployable = Class(function(self, inst)
    self.inst = inst
    self.min_spacing = 2
end)

function Deployable:CanDeploy(pt)
    return not self.test or self.test(self.inst, pt)
end

function Deployable:Deploy(pt, deployer)
    if not self.test or self.test(self.inst, pt, deployer) then
		if self.ondeploy then
	        self.ondeploy(self.inst, pt, deployer)
		end
		return true
	end
end

function Deployable:CollectPointActions(doer, pos, actions, right)
    if right then
        table.insert(actions, ACTIONS.DEPLOY)
    end
end

return Deployable

