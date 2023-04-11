local Placer = Class(function(self, inst)
    self.inst = inst
	self.can_build = false
	self.radius = 1
	self.inst:AddTag("NOCLICK")
end)

function Placer:SetBuilder(builder, recipe)
	self.builder = builder
	self.recipe = recipe
	self.inst:StartUpdatingComponent(self)
end


function Placer:OnUpdate(dt)
	local pt = Input:GetMouseWorldPos()
	
	if self.snap_to_tile and GetWorld().Map then
		local pt2 = Vector3(GetWorld().Map:GetTileCenterPoint(pt:Get()))
		pt = pt2
	elseif self.snap_to_meters then
		pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
	end
	
	self.inst.Transform:SetPosition(pt:Get())	
	
	self.can_build = true
	if self.testfn then
		self.can_build = self.testfn(Vector3(self.inst.Transform:GetWorldPosition()))
	end
	
	self.inst.AnimState:SetMultColour(0,0,0,.5)
	
	local color = self.can_build and Vector3(.1,.5,.1) or Vector3(.5,.1,.1)
	self.inst.AnimState:SetAddColour(color.x, color.y, color.z ,0)
	
end

return Placer
