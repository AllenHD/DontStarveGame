local Inspectable = Class(function(self, inst)
    self.inst = inst
    self.description = nil
end)


--can be a string, a table of strings, or a function
function Inspectable:SetDescription(desc)
    self.description = desc
end


function Inspectable:CollectSceneActions(doer, actions)
    if not self.onlyforcedinspect then
        if not (doer.sg and doer.sg:HasStateTag("moving")) then
            table.insert(actions, ACTIONS.LOOKAT)
        end
    end
end

function Inspectable:CollectInventoryActions(doer, actions)
    if not self.onlyforcedinspect then
        table.insert(actions, ACTIONS.LOOKAT)
    end
end

function Inspectable:GetStatus(viewer)
    local status = self.getstatus and self.getstatus(self.inst, viewer)
    if not status then
        if self.inst.components.health and self.inst.components.health:IsDead() then
            status = "DEAD"
        elseif self.inst.components.sleeper and self.inst.components.sleeper:IsAsleep() then
            status = "SLEEPING"
        elseif self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
            status = "BURNING"
		elseif self.inst.components.pickable and self.inst.components.pickable:IsBarren() then
			return "BARREN"
        elseif self.inst.components.pickable and not self.inst.components.pickable:CanBePicked() then
            status = "PICKED"
        elseif self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeld() then
            status = "HELD"
        elseif self.inst.components.occupiable and self.inst.components.occupiable:IsOccupied() then
            status = "OCCUPIED"
        end
    end
    return status
end

function Inspectable:GetDescription(viewer)
    local desc = self.description
    if desc == nil then
        desc = GetDescription(string.upper(viewer.prefab), string.upper(self.nameoverride or self.inst.prefab), self:GetStatus(viewer) )
    end

    if TheSim:GetLightAtPoint(self.inst.Transform:GetWorldPosition()) < TUNING.DARK_CUTOFF then
        desc = GetString(viewer.prefab, "DESCRIBE_TOODARK")
    end
        
    return desc
end




return Inspectable