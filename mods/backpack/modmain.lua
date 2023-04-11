
Assets = {
	Asset("IMAGE", "images/equip_slot_back.tex"),
}

GLOBAL.EQUIPSLOTS["BACK"] = "back"


function inventorypostinit(component,inst)
	component.numequipslots = 4
end

function backpackpostinit(inst)
	print("did you run this?")
	inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BACK
end

AddPrefabPostInit("backpack", backpackpostinit)
AddComponentPostInit("inventory", inventorypostinit)
