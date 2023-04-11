local function MineTest(inst)
    local mine = inst.components.mine
    if mine and mine.radius then
        local target = FindEntity(inst, mine.radius, function(dude)
            return (dude:HasTag("character") or dude:HasTag("monster") or dude:HasTag("animal") )
                   and not dude:HasTag(mine.alignment)
                   and dude.components.combat
                   and dude.components.combat:CanBeAttacked(inst)
                   and not (dude.components.health and dude.components.health:IsDead() )
                   and not dude:HasTag("flying")
                   and not dude:HasTag("notraptrigger")
        end)
        
        if target then
            mine:Explode(target)
        end
    end
end

local Mine = Class(function(self, inst)
    self.inst = inst
    
    self.radius = nil
    self.onexplode = nil
    self.onreset = nil
    self.onsetsprung = nil
    self.target = nil
    self.issprung = false

	self.alignment = "player"
    
    self.inst:ListenForEvent("onputininventory", function(inst) self:StopTesting() end)
    self.inst:ListenForEvent("ondropped", function(inst) self:StartTesting() end)
end)

function Mine:SetRadius(radius)
    self.radius = radius
end

function Mine:SetOnExplodeFn(fn)
    self.onexplode = fn
end

function Mine:SetOnSprungFn(fn)
    self.onsetsprung = fn
end

function Mine:SetOnResetFn(fn)
    self.onreset = fn
end

function Mine:SetAlignment(alignment)
	self.alignment = alignment
end

function Mine:SetReusable(reusable)
    self.canreset = reusable
end

function Mine:Reset()
    self:StopTesting()
    self.target = nil
    self.issprung = false
    if self.onreset then
        self.onreset(self.inst)
    end
    self:StartTesting()
end

function Mine:StartTesting()
    self:StopTesting()
    self.testtask = self.inst:DoPeriodicTask(0.4, MineTest, 1)
end

function Mine:StopTesting()
    if self.testtask then
        self.testtask:Cancel()
        self.testtask = nil
    end
end

function Mine:CollectSceneActions(doer, actions, right)
    if right and self.issprung then
        table.insert(actions, ACTIONS.RESETMINE)
    end
end


function Mine:GetTarget()
    return self.target
end

function Mine:Explode(target)
    self:StopTesting()
    self.target = target
    self.issprung = true
    if self.onexplode then
        self.onexplode(self.inst, target)
    end
end

function Mine:OnSave()
    if self.issprung then
        return {sprung = true}
    end
end

function Mine:OnLoad(data)
    if data.sprung then
        self.issprung = true
        self:StopTesting()
        if self.onsetsprung then
            self.onsetsprung(self.inst)
        end
    end
end

function Mine:OnRemoveEntity()
    self:StopTesting()
end


return Mine
