local assets=
{
	Asset("ANIM", "data/anim/backpack.zip"),
	Asset("ANIM", "data/anim/swap_krampus_sack.zip"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "swap_krampus_sack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_krampus_sack", "swap_body")
    owner.components.inventory.overflow = inst
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.components.inventory.overflow = nil
    inst.components.container:Close(owner)
end



local slotpos = {}

for y = 0, 6 do
	table.insert(slotpos, Vector3(-162, -y*75 + 240 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 240 ,0))
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("krampus_sack.png")

    inst.AnimState:SetBank("backpack1")
    inst.AnimState:SetBuild("swap_krampus_sack")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/krampuspack"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_krampusbag_2x8"
    inst.components.container.widgetanimbuild = "ui_krampusbag_2x8"
    --inst.components.container.widgetpos = Vector3(645,-85,0)
    inst.components.container.widgetpos = Vector3(-5,-75,0)
	inst.components.container.side_widget = true    
    
    return inst
end

return Prefab( "common/inventory/krampus_sack", fn, assets) 
