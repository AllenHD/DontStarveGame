local assets =
{
	Asset("ANIM", "data/anim/marsh_tile.zip"),
	Asset("ANIM", "data/anim/splash.zip"),
}

local function teleport_target(inst)
	inst.components.container:DestroyContents()
end

local function validteleporttarget(inst)
	return inst.components.container:IsFull()
end

local function getstatus(inst)
	if validteleporttarget(inst) then
		return "VALID"
	else
		return "GEMS"
	end
end

local function ItemTest(inst, item, slot)
	return item.prefab == "purplegem"
end

local function ItemTradeTest(inst, item)
	if item.prefab == "purplegem" then
		return true
	end
	return false
end

local slotpos = {	
	Vector3(0,64+32+8+4,0), 
	Vector3(0,32+4,0),
	Vector3(0,-(32+4),0), 
	Vector3(0,-(64+32+8+4),0)
}

local widgetbuttoninfo = {
	text = "Close",
	position = Vector3(0, -165, 0),
	fn = function(inst, doer) inst.components.container:Close() end,
}

local function commonfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst:AddTag("telebase")

    anim:SetBuild("marsh_tile")
    anim:SetBank("marsh_tile")
    anim:PlayAnimation("idle", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst.onteleto = teleport_target

	inst.canteleto = validteleporttarget

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("container")
    inst.components.container.canbeopened = true
    inst.components.container.itemtestfn = ItemTest
    inst.components.container:SetNumSlots(4)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetpos = Vector3(0,0,0)
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.acceptsstacks = false
	return inst
end

return Prefab( "common/inventory/telebase", commonfn, assets),
	   MakePlacer( "common/telebase_placer", "marsh_tile", "marsh_tile", "idle" ) 