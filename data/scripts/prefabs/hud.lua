local assets =
{
	 --In-game only
    Asset("ATLAS", "data/images/hud.xml"),
    Asset("IMAGE", "data/images/hud.tex"),
    
    Asset("ATLAS", "data/images/fx.xml"),
    Asset("IMAGE", "data/images/fx.tex"),

    Asset("ANIM", "data/anim/clock_transitions.zip"),
    Asset("ANIM", "data/anim/moon_phases_clock.zip"),
    Asset("ANIM", "data/anim/moon_phases.zip"),

    Asset("ANIM", "data/anim/ui_chest_3x3.zip"),
    Asset("ANIM", "data/anim/ui_backpack_2x4.zip"),
    Asset("ANIM", "data/anim/ui_piggyback_2x6.zip"),
    Asset("ANIM", "data/anim/ui_krampusbag_2x8.zip"),
    Asset("ANIM", "data/anim/ui_cookpot_1x4.zip"), 
    Asset("ANIM", "data/anim/ui_krampusbag_2x5.zip"),

    Asset("ANIM", "data/anim/health.zip"),
    Asset("ANIM", "data/anim/sanity.zip"),
    Asset("ANIM", "data/anim/sanity_arrow.zip"),
    Asset("ANIM", "data/anim/effigy_topper.zip"),
    Asset("ANIM", "data/anim/hunger.zip"),
    Asset("ANIM", "data/anim/beaver_meter.zip"),
    Asset("ANIM", "data/anim/hunger_health_pulse.zip"),
    Asset("ANIM", "data/anim/spoiled_meter.zip"),
    
    Asset("ANIM", "data/anim/saving.zip"),
    Asset("ANIM", "data/anim/vig.zip"),
    Asset("ANIM", "data/anim/fire_over.zip"),
    Asset("ANIM", "data/anim/clouds_ol.zip"),   
    Asset("ANIM", "data/anim/progressbar.zip"),   
    
    Asset("ATLAS", "data/images/fx.xml"),
    Asset("IMAGE", "data/images/fx.tex"),
    
    Asset("ATLAS", "data/images/hud.xml"),
    Asset("IMAGE", "data/images/hud.tex"),
    
    Asset("ATLAS", "data/images/inventoryimages.xml"),
    Asset("IMAGE", "data/images/inventoryimages.tex"),    

    Asset("ANIM", "data/anim/crafting_submenu.zip"), 
}


local prefabs = {
	"minimap",
}

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn(Sim)
    return CreateEntity()
end

return Prefab( "UI/interface/hud", fn, assets, prefabs) 
