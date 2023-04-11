local Activatable = Class(function(self, inst, activcb)
    self.inst = inst
    self.OnActivate = activcb
    self.inactive = true
end)

function Activatable:CollectSceneActions(doer, actions)
	if self.inactive then 
		table.insert(actions, ACTIONS.ACTIVATE)
	end
end

function Activatable:DoActivate(doer)
	if self.OnActivate ~= nil then
		self.OnActivate(self.inst, doer)
		self.inactive = false
	end
end

return Activatable