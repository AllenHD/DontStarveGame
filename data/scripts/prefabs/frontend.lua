local assets =
{
  --FE

    Asset("ANIM", "data/anim/credits.zip"),

    Asset("ATLAS", "data/bigportraits/locked.xml"),
    Asset("IMAGE", "data/bigportraits/locked.tex"),

    Asset("ATLAS", "data/images/biobox.xml"),
    Asset("IMAGE", "data/images/biobox.tex"),

    Asset("ATLAS", "data/images/panel_shield.xml"),
    Asset("IMAGE", "data/images/panel_shield.tex"),

    Asset("ATLAS", "data/images/presetbox.xml"),
    Asset("IMAGE", "data/images/presetbox.tex"),
    
    Asset("ATLAS", "data/images/panel.xml"),
    Asset("IMAGE", "data/images/panel.tex"),
    Asset("ATLAS", "data/images/panel_customization.xml"),
    Asset("IMAGE", "data/images/panel_customization.tex"),
    Asset("ATLAS", "data/images/panel_saveslots.xml"),
    Asset("IMAGE", "data/images/panel_saveslots.tex"),

    Asset("ATLAS", "data/images/panel_mod1.xml"),
    Asset("IMAGE", "data/images/panel_mod1.tex"),
    Asset("ATLAS", "data/images/panel_mod2.xml"),
    Asset("IMAGE", "data/images/panel_mod2.tex"),
    
    Asset("ATLAS", "data/images/ui.xml"),
    Asset("IMAGE", "data/images/ui.tex"),
    
    Asset("ATLAS", "data/images/ui.xml"),
    Asset("IMAGE", "data/images/ui.tex"),
    
    Asset("IMAGE", "data/images/customisation.tex" ),
    Asset("ATLAS", "data/images/customisation.xml" ),
    
	Asset("ATLAS", "data/images/selectscreen_portraits.xml"),
	Asset("IMAGE", "data/images/selectscreen_portraits.tex"),
	
    Asset("ANIM", "data/anim/portrait_frame.zip"),
    Asset("ANIM", "data/anim/scroll_arrow.zip"),

    Asset("ANIM", "data/anim/generating_world.zip"),
    Asset("ANIM", "data/anim/generating_cave.zip"),
    Asset("ANIM", "data/anim/creepy_hands.zip"),

    Asset("ANIM", "data/anim/build_status.zip"),
    Asset("ANIM", "data/anim/savetile.zip"),
}

-- Add all the characters by name
for i,char in ipairs(CHARACTERLIST) do
	table.insert(assets, Asset("ATLAS", "data/bigportraits/"..char..".xml"))
	table.insert(assets, Asset("IMAGE", "data/bigportraits/"..char..".tex"))
	--table.insert(assets, Asset("IMAGE", "data/images/selectscreen_portraits/"..char..".tex"))
	--table.insert(assets, Asset("IMAGE", "data/images/selectscreen_portraits/"..char.."_silho.tex"))
end



--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn(Sim)
    return CreateEntity()
end

return Prefab( "UI/interface/frontend", fn, assets) 
