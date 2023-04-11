local Health = Class(function(self, inst)
    self.inst = inst
    self.maxhealth = 100
    self.minhealth = 0
    self.currenthealth = self.maxhealth
    self.invincible = false
    
    self.vulnerabletoheatdamage = true
	self.takingfiredamage = false
	self.takingfiredamagetime = 0
	self.fire_damage_scale = 1
	self.nofadeout = false
	self.penalty = 0
    self.absorb = 0
	
end)

function Health:SetInvincible(val)
    self.invincible = val
    self.inst:PushEvent("invincibletoggle", {invincible = val})
end

function Health:OnSave()    
    return 
    {
		health = self.currenthealth,
		penalty = self.penalty > 0 and self.penalty or nil
	}
end


function Health:RecalculatePenalty()
	self.penalty = 0

	for k,v in pairs(Ents) do
		if v.components.resurrector and v.components.resurrector.penalty then
			self.penalty = self.penalty + v.components.resurrector.penalty
		end
	end

	self:DoDelta(0)

end

function Health:OnLoad(data)
    self.penalty = data.penalty or self.penalty
    if data.health then
        self:SetVal(data.health, "loading")
        self:DoDelta(0) --to update hud
	elseif data.percent then
		-- used for setpieces!
		self:SetPercent(data.percent, "loading")
        self:DoDelta(0) --to update hud
    end
end

local FIRE_TIMEOUT = .5
local FIRE_TIMESTART = 1.0

function Health:DoFireDamage(amount, doer)
	if not self.invincible and self.fire_damage_scale > 0 then
		if not self.takingfiredamage then
			self.takingfiredamage = true
			self.takingfiredamagestarttime = GetTime()
			self.inst:StartUpdatingComponent(self)
			self.inst:PushEvent("startfiredamage")
		end
		
		local time = GetTime()
		self.lastfiredamagetime = time
		
		if time - self.takingfiredamagestarttime > FIRE_TIMESTART and amount > 0 then
			self:DoDelta(-amount*self.fire_damage_scale, false, "fire")
            self.inst:PushEvent("firedamage")		
		end
	end
end


function Health:OnUpdate(dt)
	local time = GetTime()
	
	if time - self.lastfiredamagetime > FIRE_TIMEOUT then
		self.takingfiredamage = false
		self.inst:StopUpdatingComponent(self)
		self.inst:PushEvent("stopfiredamage")
	end
end

function Health:DoRegen()
    --print(string.format("Health:DoRegen ^%.2g/%.2fs", self.regen.amount, self.regen.period))
    if not self:IsDead() then
        self:DoDelta(self.regen.amount, true, "regen")
    else
        --print("    can't regen from dead!")
    end
end

function Health:StartRegen(amount, period)
    --print("Health:StopRegen", amount, period)
    if not self.regen then
        self.regen = {}
    end
    self.regen.amount = amount
    self.regen.period = period

    if not self.regen.task then
        --print("   starting task")
        self.regen.task = self.inst:DoPeriodicTask(self.regen.period, function() self:DoRegen() end)
    end
end

function Health:SetAbsorbAmount(amount)
    self.absorb = amount
end

function Health:StopRegen()
    --print("Health:StopRegen")
    if self.regen then
        if self.regen.task then
            --print("   stopping task")
            self.regen.task:Cancel()
        end
        self.regen = nil
    end
end

function Health:GetPenaltyPercent()
	return (self.penalty*TUNING.EFFIGY_HEALTH_PENALTY)/ self.maxhealth
end


function Health:GetPercent()
    return self.currenthealth / self.maxhealth
end

function Health:IsInvincible()
    return self.invincible
end

function Health:GetDebugString()
    local s = string.format("%2.2f / %2.2f", self.currenthealth, self.maxhealth - self.penalty*TUNING.EFFIGY_HEALTH_PENALTY)
    if self.regen then
        s = s .. string.format(", regen %.2f every %.2fs", self.regen.amount, self.regen.period)
    end
    return s
end


function Health:SetMaxHealth(amount)
    self.maxhealth = amount
    self.currenthealth = amount
end

function Health:SetMinHealth(amount)
    self.minhealth = amount
end

function Health:IsHurt()
    return self.currenthealth < (self.maxhealth - self.penalty*TUNING.EFFIGY_HEALTH_PENALTY)
end

function Health:Kill()
    if self.currenthealth > 0 then
        self:DoDelta(-self.currenthealth)
    end
end

function Health:IsDead()
    return self.currenthealth <= 0
end


local function destroy(inst)
	local time_to_erode = 1
	local tick_time = TheSim:GetTickTime()

	if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

	inst:StartThread( function()
		local ticks = 0
		while ticks * tick_time < time_to_erode do
			local erode_amount = ticks * tick_time / time_to_erode
			inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
			ticks = ticks + 1
			Yield()
		end
		inst:Remove()
	end)
end

function Health:SetPercent(percent, cause)
    self:SetVal(self.maxhealth*percent, cause)
    self:DoDelta(0)
end

function Health:OnProgress()
	self.penalty = 0
end

function Health:SetVal(val, cause)

    local old_percent = self:GetPercent()

    self.currenthealth = val
    if self.currenthealth > self.maxhealth - self.penalty*TUNING.EFFIGY_HEALTH_PENALTY then
        self.currenthealth = self.maxhealth - self.penalty*TUNING.EFFIGY_HEALTH_PENALTY
    end

    if self.minhealth and self.currenthealth < self.minhealth then
        self.currenthealth = self.minhealth
        self.inst:PushEvent("minhealth", {cause=cause})
    end
    if self.currenthealth < 0 then
        self.currenthealth = 0
    end

    local new_percent = self:GetPercent()
    
    if old_percent > 0 and new_percent <= 0 then
        self.inst:PushEvent("death", {cause=cause})

        GetWorld():PushEvent("entity_death", {inst = self.inst, cause=cause} )

		if not self.nofadeout then
			self.inst:AddTag("NOCLICK")
			self.inst.persists = false
			self.inst:DoTaskInTime(2, destroy)
		end
    end
end

function Health:DoDelta(amount, overtime, cause, ignore_invincible)

    if self.redirect then
        self.redirect(self.inst, amount, overtime, cause)
        return
    end


    if not ignore_invincible and (self.invincible or self.inst.is_teleporting == true) then
        return
    end
    
    if amount < 0 then
        amount = amount - (amount * self.absorb)
    end

    local old_percent = self:GetPercent()
    self:SetVal(self.currenthealth + amount, cause)
    local new_percent = self:GetPercent()

    self.inst:PushEvent("healthdelta", {oldpercent = old_percent, newpercent = self:GetPercent(), overtime=overtime, cause=cause})
    if self.ondelta then
		self.ondelta(self.inst, old_percent, self:GetPercent())
    end
end

function Health:Respawn(health)
	
	self:DoDelta( health or 10 )
    self.inst:PushEvent( "respawn", {} )
end

function Health:CollectInventoryActions(doer, actions)
    table.insert(actions, ACTIONS.MURDER)
end

return Health
