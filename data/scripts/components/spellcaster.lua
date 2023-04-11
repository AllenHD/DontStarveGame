local SpellCaster = Class(function(self, inst)
	self.inst = inst
	self.spell = nil
	self.spelltest = nil
	self.onspellcast = nil
	self.inventoryonly = true
end)

function SpellCaster:SetSpellFn(fn)
	self.spell = fn
end

function SpellCaster:SetSpellTestFn(fn)
	self.spelltest = fn
end

function SpellCaster:SetOnSpellCastFn(fn)
	self.onspellcast = fn
end

function SpellCaster:CastSpell(target)
	if self.spell then
		self.spell(self.inst, target)

		if self.onspellcast then
			self.onspellcast(self.inst, target)
		end
	end
end

function SpellCaster:CanCast(doer, target)
	if self.spelltest then
		return self.spelltest(self.inst, doer, target) and self.spell ~= nil
	end

	return self.spell ~= nil

end

function SpellCaster:CollectInventoryActions(doer, actions)
	if self:CanCast(doer) then
		table.insert(actions, ACTIONS.CASTSPELL)
	end
end

function SpellCaster:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanCast(doer, target) and not self.inventoryonly then
		table.insert(actions, ACTIONS.CASTSPELL)
	end
end

return SpellCaster