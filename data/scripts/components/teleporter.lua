local Teleporter = Class(function(self, inst)
    self.inst = inst
	self.targetTeleporter = nil
	self.onActivate = nil
	self.onActivateOther = nil
end)

function Teleporter:CollectSceneActions(doer, actions)
	if self.targetTeleporter ~= nil then
		table.insert(actions, ACTIONS.JUMPIN)
	end
end

function Teleporter:Activate(doer)
	if self.targetTeleporter == nil then
		return
	end
	
	if self.onActivate then
		self.onActivate(self.inst, doer)
	end

	if self.onActivateOther then
		self.onActivateOther(self.inst, self.targetTeleporter, doer)
	end
	
	self:Teleport(doer)

	if doer.components.leader then
		for follower,v in pairs(doer.components.leader.followers) do
			self:Teleport(follower)
		end
	end

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower)
						end
					end
				end
			end
		end
	end
end

-- You probably don't want this, call Activate instead.
function Teleporter:Teleport(obj)
	if self.targetTeleporter ~= nil then
		local offset = 2.0
		local angle = math.random()*360
		local target_x, target_y, target_z = self.targetTeleporter.Transform:GetWorldPosition()
		target_x = target_x + math.sin(angle)*offset
		target_z = target_z + math.cos(angle)*offset
		if obj.Physics then
			obj.Physics:Teleport( target_x, target_y, target_z )
		elseif obj.Transform then
			obj.Transform:SetPosition( target_x, target_y, target_z )
		end
	end
end


function Teleporter:Target(otherTeleporter)
	self.targetTeleporter = otherTeleporter
end

function Teleporter:OnSave()
	if self.targetTeleporter ~= nil then
		return { target=self.targetTeleporter.GUID }, {self.targetTeleporter.GUID}
	end
	return {}
end

function Teleporter:LoadPostPass(newents, savedata)
	if savedata and savedata.target then
		local targEnt = newents[savedata.target]
		if targEnt and targEnt.entity.components.teleporter then
			self.targetTeleporter = targEnt.entity
		end
	end
end



return Teleporter
