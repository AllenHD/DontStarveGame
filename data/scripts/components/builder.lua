local Builder = Class(function(self, inst)
    self.inst = inst
    self.recipes = {}
    self.recipe_count = 0
    self.current_tech_level = 0
    self.inst:StartUpdatingComponent(self)
    self.current_machine = nil
    self.buffered_builds = {}
    self.bonus_tech_level = 0
    self.custom_tabs = {}
    
end)

function Builder:ActivateCurrentResearchMachine()
	if self.current_machine and self.current_machine.components.researchpointconverter then
		self.current_machine.components.researchpointconverter:Activate()
	end
end

function Builder:AddRecipeTab(tab)
	table.insert(self.custom_tabs, tab)
end

function Builder:OnSave()
	local data =
	{
		buffered_builds = self.buffered_builds
	}
	
	data.recipes = self.recipes
	return data
end

function Builder:OnLoad(data)
    
    
    if data.buffered_builds then
		self.buffered_builds = data.buffered_builds
    end
    
	if data.recipes then
		for k,v in pairs(data.recipes) do
			self:AddRecipe(v)
		end
	end
end


function Builder:IsBuildBuffered(recipe)
	return self.buffered_builds[recipe] == true
end

function Builder:BufferBuild(recipe)
	self:RemoveIngredients(recipe)
	self.buffered_builds[recipe] = true
end

function Builder:OnUpdate( dt )
	self:EvaluateTechLevel()
end


function Builder:GiveAllRecipes()
    if self.freebuildmode then
    	self.freebuildmode = false
    else
    	self.freebuildmode = true
    end
end

function Builder:CanBuildAtPoint(pt, recipe)

	local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt:Get())
    end

	if tile == GROUND.IMPASSABLE then
		return false
	else
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 6) -- or we could include a flag to the search?
		for k, v in pairs(ents) do
			if v ~= self.inst and (not v.components.placer) and not v:HasTag("player") and not v:HasTag("FX") and v.entity:IsVisible() and not (v.components.inventoryitem and v.components.inventoryitem.owner )then
				local min_rad = recipe.min_spacing or 2+1.2
				--local rad = (v.Physics and v.Physics:GetRadius() or 1) + 1.25
				local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
				if dsq <= min_rad*min_rad then
					return false
				end
			end
		end
	end
	
	return true
end

function Builder:EvaluateTechLevel()
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, TUNING.RESEARCH_MACHINE_DIST, {"researchmachine"})
	
	
	local old_level = self.current_tech_level or 0
	
	local old_machine = self.current_machine	
	self.current_machine = nil
	
	local machine_active = false
	for k,v in pairs(ents) do
		
		if v.components.researchpointconverter then
			local distsq = self.inst:GetDistanceSqToInst(v)
			if not machine_active and distsq < TUNING.RESEARCH_MACHINE_DIST*TUNING.RESEARCH_MACHINE_DIST then 
				v.components.researchpointconverter:TurnOn()
				self.current_tech_level = v.components.researchpointconverter.level
				machine_active = true
				self.current_machine = v
			else
				v.components.researchpointconverter:TurnOff()
			end
			
		end
	end
	
	self.current_tech_level = self.current_tech_level + self.bonus_tech_level

	if not machine_active then
		self.current_tech_level = self.bonus_tech_level	
	end
	
	local level_changed = self.current_tech_level ~= old_level
	
	
	
	if old_machine and old_machine.components.researchpointconverter and old_machine.entity:IsValid() and old_machine ~= self.current_machine then
		old_machine.components.researchpointconverter:TurnOff()
	end
	
	if level_changed then
		self.inst:PushEvent("techlevelchange", {level = self.current_tech_level})
	end
end


function Builder:AddRecipe(rec)
	if table.contains(self.recipes, rec) == false then
	    table.insert(self.recipes, rec)
	    self.recipe_count = self.recipe_count + 1
    end
end

function Builder:UnlockRecipe(recname)

	if self.inst.components.sanity then
		self.inst.components.sanity:DoDelta(TUNING.SANITY_MED)
	end
	
	self:AddRecipe(recname)
	self.inst:PushEvent("unlockrecipe", {recipe = recname})
end

function Builder:RemoveIngredients(recname)
    local recipe = GetRecipe(recname)
    if recipe then
        for k, v in pairs(recipe.ingredients) do
            self.inst.components.inventory:ConsumeByName(v.type, v.amount)
        end
    end
end

function Builder:OnSetProfile(profile)
end

function Builder:MakeRecipe(recipe, pt, onsuccess)
    if recipe then
		pt = pt or Point(self.inst.Transform:GetWorldPosition())
		if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
			self.inst.components.locomotor:Stop()
			local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, 1)
			if onsuccess then
				buffaction:AddSuccessAction(onsuccess)
			end
			
			self.inst.components.locomotor:PushAction(buffaction, true)
			
			return true
		end
    end
    return false
end

function Builder:DoBuild(recname, pt)
    local recipe = GetRecipe(recname)
    if recipe and self:IsBuildBuffered(recname) or self:CanBuild(recname) then

		if self.buffered_builds[recname] then
			self.buffered_builds[recname] = nil
        else
			self:RemoveIngredients(recname)
		end
		
        local prod = SpawnPrefab(recipe.product)
        if prod then
            if prod.components.inventoryitem then
                if self.inst.components.inventory then
					 
                    --self.inst.components.inventory:GiveItem(prod)
                    self.inst:PushEvent("builditem", {item=prod, recipe = recipe})
                    ProfileStatsAdd("build_"..prod.prefab)
                    if prod.components.equippable and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
						self.inst.components.inventory:Equip(prod)
                    else
						self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetMouseScreenPos())
                    end
                    
					if self.onBuild then
						self.onBuild(self.inst, prod)
					end
					
					prod:OnBuilt(self.inst)
                    
                    return true
                end
            else

                pt = pt or Point(self.inst.Transform:GetWorldPosition())
				prod.Transform:SetPosition(pt.x,pt.y,pt.z)
                self.inst:PushEvent("buildstructure", {item=prod, recipe = recipe})
                prod:PushEvent("onbuilt")
                ProfileStatsAdd("build_"..prod.prefab)
                
				if self.onBuild then
					self.onBuild(self.inst, prod)
				end
				
				prod:OnBuilt(self.inst)
			                    
                return true
            end

        end
    end
    

end

function Builder:KnowsRecipe(recname)
	return self.freebuildmode or table.contains(self.recipes, recname)
end


function Builder:CanBuild(recname)

	if self.freebuildmode then
		return true
	end

    local recipe = GetRecipe(recname)
    if recipe then
        for ik, iv in pairs(recipe.ingredients) do
            if not self.inst.components.inventory:Has(iv.type, iv.amount) then
                return false
            end
        end
        return true
    end

    return false
end


return Builder
