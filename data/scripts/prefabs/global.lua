local assets =
{
	Asset("PKGREF", "data/sound/dontstarve.fev"),

    Asset("SOUND", "data/sound/sfx.fsb"),
	Asset("SOUND", "data/sound/music.fsb"),
	
    Asset("ATLAS", "data/images/global.xml"),
    Asset("IMAGE", "data/images/global.tex"),
	
    Asset("ANIM", "data/anim/button.zip"),
    Asset("ANIM", "data/anim/button_small.zip"),
    Asset("ANIM", "data/anim/button_long.zip"),


	Asset("SHADER", "data/shaders/anim_bloom.ksh"),
	Asset("SHADER", "data/shaders/wall_bloom.ksh"),
	Asset("SHADER", "data/shaders/road.ksh"),

	Asset("IMAGE", "data/images/erosion.tex"),
	
	--Asset("IMAGE", "data/images/river_bed.tex"),
	--Asset("IMAGE", "data/images/water_river.tex"),
	Asset("IMAGE", "data/images/pathnoise.tex"),
	Asset("IMAGE", "data/images/roadnoise.tex"),
	Asset("IMAGE", "data/images/roadedge.tex"),
	Asset("IMAGE", "data/images/roadcorner.tex"),
	Asset("IMAGE", "data/images/roadendcap.tex"),

	Asset("IMAGE", "data/images/circle.tex"),
	Asset("IMAGE", "data/images/square.tex"),
	Asset("IMAGE", "data/images/shadow.tex"),
	
	Asset("ATLAS", "data/images/fx.xml"),
	Asset("IMAGE", "data/images/fx.tex"),

	Asset("IMAGE", "data/images/colour_cubes/identity_colourcube.tex"),

	Asset("SHADER", "data/shaders/anim.ksh"),
	Asset("SHADER", "data/shaders/anim_bloom.ksh"),
	Asset("SHADER", "data/shaders/blurh.ksh"),
	Asset("SHADER", "data/shaders/blurv.ksh"),
	Asset("SHADER", "data/shaders/creep.ksh"),
	Asset("SHADER", "data/shaders/debug_line.ksh"),
	Asset("SHADER", "data/shaders/debug_tri.ksh"),
	Asset("SHADER", "data/shaders/render_depth.ksh"),
	Asset("SHADER", "data/shaders/font.ksh"),
	Asset("SHADER", "data/shaders/ground.ksh"),
    Asset("SHADER", "data/shaders/ceiling.ksh"),
    -- Asset("SHADER", "data/shaders/triplanar.ksh"),
    Asset("SHADER", "data/shaders/triplanar_bg.ksh"),
    Asset("SHADER", "data/shaders/triplanar_alpha_wall.ksh"),
    Asset("SHADER", "data/shaders/triplanar_alpha_ceiling.ksh"),
	Asset("SHADER", "data/shaders/lighting.ksh"),
	Asset("SHADER", "data/shaders/minimap.ksh"),
	Asset("SHADER", "data/shaders/minimapfs.ksh"),
	Asset("SHADER", "data/shaders/particle.ksh"),
	Asset("SHADER", "data/shaders/road.ksh"),
	Asset("SHADER", "data/shaders/river.ksh"),
	Asset("SHADER", "data/shaders/splat.ksh"),
	Asset("SHADER", "data/shaders/texture.ksh"),
	Asset("SHADER", "data/shaders/ui.ksh"),
	Asset("SHADER", "data/shaders/ui_anim.ksh"),
	Asset("SHADER", "data/shaders/postprocess.ksh"),
	Asset("SHADER", "data/shaders/postprocessbloom.ksh"),
	Asset("SHADER", "data/shaders/postprocessdistort.ksh"),
	Asset("SHADER", "data/shaders/postprocessbloomdistort.ksh"),


    --common UI elements that we will always need
    Asset("ATLAS", "data/images/ui.xml"),
    Asset("IMAGE", "data/images/ui.tex"),
    
    --oft-used panel bgs
    Asset("ATLAS", "data/images/panel.xml"),
    Asset("IMAGE", "data/images/panel.tex"),
    Asset("ATLAS", "data/images/panel_upsell.xml"),
    Asset("IMAGE", "data/images/panel_upsell.tex"),
    Asset("ATLAS", "data/images/small_dialog.xml"),
    Asset("IMAGE", "data/images/small_dialog.tex"),
    Asset("ATLAS", "data/images/panel_upsell_small.xml"),
    Asset("IMAGE", "data/images/panel_upsell_small.tex"),

	--character portraits
	Asset("ATLAS", "data/images/saveslot_portraits.xml"),
    Asset("IMAGE", "data/images/saveslot_portraits.tex"),
}


require "fonts"
for i, font in ipairs( FONTS ) do
	table.insert( assets, Asset( "FONT", font.filename ) )
end

local function fn(Sim)
    return nil
end

return Prefab( "common/global", fn, assets ) 

