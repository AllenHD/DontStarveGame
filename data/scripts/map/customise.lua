local freqency_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
}

local speed_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local day_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "onlyday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "onlydusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "onlynight" },
	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "longday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "longdusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "longnight" },
}

local season_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "onlysummer" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "onlywinter" },
	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "longsummer" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "longwinter" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.BOTH, data = "longboth" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHORT.." "..STRINGS.UI.SANDBOXMENU.BOTH, data = "shortboth" },
}

local season_start_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SUMMER, data = "summer"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER, data = "winter"},-- 	image = "season_start_winter.tex" },
}

local size_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
}

local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
}

local loop_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.LOOPNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPRANDOM, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPALWAYS, data = "always" },
}

local complexity_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSIMPLE, data = "verysimple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESIMPLE, data = "simple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDECOMPLEX, data = "complex" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYCOMPLEX, data = "verycomplex" },	
}

-- Read this from the levels.lua
local preset_descriptions = {
}

-- TODO: Read this from the tasks.lua
local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.YES, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.NO, data = "never" },
}

local GROUP = {
	["monsters"] = 	{	-- These guys come after you	
						text = STRINGS.UI.SANDBOXMENU.CHOICEMONSTERS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["spiders"] = {value = "default", enable = false, spinner = nil, image = "spiders.tex"}, 
							["tentacles"] = {value = "default", enable = false, spinner = nil, image = "tentacles.tex"}, 
							["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex"}, 
							["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex"}, 
							["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex"}, 
							--["mactusk"] = {value = "default", enable = false, spinner = nil, image = "mactusk.tex"}, 
							--["merm"] = {value = "default", enable = false, spinner = nil, image = "merm.tex"}, 
						}
					},
	["animals"] =  	{	-- These guys live and let live
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["pigs"] = {value = "default", enable = false, spinner = nil, image = "pigs.tex"}, 
							["tallbirds"] = {value = "default", enable = false, spinner = nil, image = "tallbirds.tex"}, 
							["rabbits"] = {value = "default", enable = false, spinner = nil, image = "rabbits.tex"}, 
							["beefalo"] = {value = "default", enable = false, spinner = nil, image = "beefalo.tex"}, 
							["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex"}, 
							["frogs"] = {value = "default", enable = false, spinner = nil, image = "frogs.tex"}, 
							["bees"] = {value = "default", enable = false, spinner = nil, image = "bees.tex"}, 
							["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex"}, 
						}
					},
	["resources"] = {
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["grass"] = {value = "default", enable = false, spinner = nil, image = "grass.tex"}, 
							["rock"] = {value = "default", enable = false, spinner = nil, image = "rock.tex"}, 
							["sapling"] = {value = "default", enable = false, spinner = nil, image = "sapling.tex"}, 
							["reeds"] = {value = "default", enable = false, spinner = nil, image = "reeds.tex"}, 
							["trees"] = {value = "default", enable = false, spinner = nil, image = "trees.tex"}, 
						}
					},
	["unprepared"] ={
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = freqency_descriptions,
						enable = true,
						items={
							["carrot"] = {value = "default", enable = true, spinner = nil, image = "carrot.tex",
--											images ={
--												"carrot_never.tex",
--												"carrot_rare.tex",
--												"carrot_default.tex",
--												"carrot_often.tex",
--												"carrot_always.tex",
--											}
										}, 
							["berrybush"] = {value = "default", enable = true, spinner = nil, image = "berrybush.tex"}, 
							--["flowers"] = {value = "default", enable = true, spinner = nil, image = "flowers.tex"}, 
						}
					},
	["misc"] =		{
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
							["day"] = {value = "default", enable = false, spinner = nil, image = "day.tex", desc = day_descriptions}, 
							["season"] = {value = "default", enable = true, spinner = nil, image = "season.tex", desc = season_descriptions}, 
							["season_start"] = {value = "summer", enable = false, spinner = nil, image = "season_start.tex", desc = season_start_descriptions}, 
							["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions}, 
							["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions}, 
							["world_size"] = {value = "default", enable = false, spinner = nil, image = "world_size.tex", desc = size_descriptions}, 
							["branching"] = {value = "default", enable = false, spinner = nil, image = "world_branching.tex", desc = branching_descriptions}, 
							["loop"] = {value = "default", enable = false, spinner = nil, image = "world_loop.tex", desc = loop_descriptions}, 
--							["world_complexity"] = {value = "default", enable = false, spinner = nil, image = "world_complexity.tex", desc = complexity_descriptions}, 
							["boons"] = {value = "default", enable = false, spinner = nil, image = "skeletons.tex", desc = freqency_descriptions}, 
							["touchstone"] = {value = "default", enable = false, spinner = nil, image = "resurrection.tex", desc = freqency_descriptions}, 
							["cave_entrance"] = {value = "default", enable = false, spinner = nil, image = "caves.tex", desc = yesno_descriptions},
						}
					},
}

local function GetGroupForItem(target)
	for area,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == target then
				return area
			end
		end
	end
	return "misc"
end

return {GetGroupForItem=GetGroupForItem, GROUP=GROUP, preset_descriptions=preset_descriptions}
