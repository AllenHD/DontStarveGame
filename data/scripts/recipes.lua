require "recipe"
require "tuning"


--LIGHT
Recipe("campfire", {Ingredient("cutgrass", 3),Ingredient("log", 2)}, RECIPETABS.LIGHT, 0, "campfire_placer")
Recipe("firepit", {Ingredient("log", 2),Ingredient("rocks", 12)}, RECIPETABS.LIGHT, 0, "firepit_placer")
Recipe("torch", {Ingredient("cutgrass", 2),Ingredient("twigs", 2)}, RECIPETABS.LIGHT, 0)

Recipe("minerhat", {Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, 2)
Recipe("pumpkin_lantern", {Ingredient("pumpkin", 1), Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, 2)
Recipe("lantern", {Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)}, RECIPETABS.LIGHT, 2)

--STRUCTURES
Recipe("treasurechest", {Ingredient("boards", 3)}, RECIPETABS.TOWN, 1, "treasurechest_placer",1)
Recipe("homesign", {Ingredient("boards", 1)}, RECIPETABS.TOWN, 1, "homesign_placer")

Recipe("wall_hay_item", {Ingredient("cutgrass", 4), Ingredient("twigs", 2) }, RECIPETABS.TOWN, 1)
Recipe("wall_wood_item", {Ingredient("boards", 2),Ingredient("rope", 1)}, RECIPETABS.TOWN,  1)
Recipe("wall_stone_item", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, 2)

Recipe("pighouse", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.TOWN, 2, "pighouse_placer")
Recipe("rabbithouse", {Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)}, RECIPETABS.TOWN, 2, "rabbithouse_placer")
Recipe("birdcage", {Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)}, RECIPETABS.TOWN, 2, "birdcage_placer")

Recipe("turf_road", {Ingredient("turf_rocky", 1), Ingredient("boards", 1)}, RECIPETABS.TOWN,  2)
Recipe("turf_woodfloor", {Ingredient("boards", 1)}, RECIPETABS.TOWN, 2)
Recipe("turf_checkerfloor", {Ingredient("marble", 1)}, RECIPETABS.TOWN, 3)
Recipe("turf_carpetfloor", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, RECIPETABS.TOWN, 3)

--FARM
Recipe("slow_farmplot", {Ingredient("cutgrass", 8),Ingredient("poop", 4),Ingredient("log", 4)}, RECIPETABS.FARM,  1, "farmplot_placer")
Recipe("fast_farmplot", {Ingredient("cutgrass", 10),Ingredient("poop", 6),Ingredient("rocks", 4)}, RECIPETABS.FARM,  2, "farmplot_placer")
Recipe("beebox", {Ingredient("boards", 2),Ingredient("honeycomb", 1),Ingredient("bee", 4)}, RECIPETABS.FARM, 1, "beebox_placer")
Recipe("meatrack", {Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)}, RECIPETABS.FARM, 1, "meatrack_placer")
Recipe("cookpot", {Ingredient("cutstone", 3),Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM,  1, "cookpot_placer")
Recipe("icebox", {Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("boards", 1)}, RECIPETABS.FARM,  2, "icebox_placer", 1.5)

--SURVIVAL
Recipe("trap", {Ingredient("twigs", 2),Ingredient("cutgrass", 6)}, RECIPETABS.SURVIVAL, 0)
Recipe("birdtrap", {Ingredient("twigs", 3),Ingredient("silk", 4)}, RECIPETABS.SURVIVAL, 1)
Recipe("compass", {Ingredient("goldnugget", 1), Ingredient("papyrus", 1)}, RECIPETABS.SURVIVAL,  1)
Recipe("backpack", {Ingredient("cutgrass", 4), Ingredient("twigs", 4)}, RECIPETABS.SURVIVAL, 1)
Recipe("piggyback", {Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, 2)
Recipe("healingsalve", {Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)}, RECIPETABS.SURVIVAL,  1)
Recipe("bandage", {Ingredient("papyrus", 1), Ingredient("honey", 2)}, RECIPETABS.SURVIVAL,  2)
Recipe("bedroll_straw", {Ingredient("cutgrass", 6), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, 1)
Recipe("bedroll_furry", {Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 2)}, RECIPETABS.SURVIVAL, 2)
Recipe("tent", {Ingredient("silk", 6),Ingredient("twigs", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, 2, "tent_placer")
Recipe("umbrella", {Ingredient("twigs", 6) ,Ingredient("pigskin", 1), Ingredient("silk",2 )}, RECIPETABS.SURVIVAL, 1)
Recipe("bugnet", {Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, 1)
Recipe("fishingrod", {Ingredient("twigs", 2),Ingredient("silk", 2)}, RECIPETABS.SURVIVAL, 1)
Recipe("heatrock", {Ingredient("rocks", 10),Ingredient("pickaxe", 1),Ingredient("flint", 3)}, RECIPETABS.SURVIVAL, 2)


--TOOLS
Recipe("axe", {Ingredient("twigs", 1),Ingredient("flint", 1)}, RECIPETABS.TOOLS, 0)
Recipe("goldenaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  2)
Recipe("pickaxe", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS, 0)
Recipe("goldenpickaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  2)
Recipe("shovel", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  1)
Recipe("goldenshovel", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  2)

Recipe("hammer", {Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("rope", 2)}, RECIPETABS.TOOLS,  1)
Recipe("pitchfork", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  1)
Recipe("razor", {Ingredient("twigs", 2), Ingredient("flint", 2)}, RECIPETABS.TOOLS,  1)



--SCIENCE
Recipe("researchlab", {Ingredient("goldnugget", 1),Ingredient("log", 4),Ingredient("rocks", 4)}, RECIPETABS.SCIENCE, 0, "researchlab_placer")
Recipe("researchlab2", {Ingredient("boards", 4),Ingredient("cutstone", 2), Ingredient("goldnugget", 6)}, RECIPETABS.SCIENCE,  1, "researchlab2_placer")
Recipe("researchlab3", {Ingredient("livinglog", 2), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 10)}, RECIPETABS.SCIENCE, 2, "researchlab3_placer")
Recipe("diviningrod", {Ingredient("twigs", 1), Ingredient("nightmarefuel", 4), Ingredient("gears", 1)}, RECIPETABS.SCIENCE, 2)
Recipe("winterometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2)}, RECIPETABS.SCIENCE,  1, "winterometer_placer")
Recipe("rainometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)}, RECIPETABS.SCIENCE,  1, "rainometer_placer")
Recipe("gunpowder", {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)}, RECIPETABS.SCIENCE,  2)
Recipe("lightning_rod", {Ingredient("goldnugget", 3), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE,  1, "lightning_rod_placer")

--MAGIC
Recipe("resurrectionstatue", {Ingredient("boards", 4),Ingredient("cookedmeat", 4),Ingredient("beardhair", 4)}, RECIPETABS.MAGIC,  1, "resurrectionstatue_placer")
Recipe("panflute", {Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  2)
Recipe("onemanband", {Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 4),Ingredient("pigskin", 2)}, RECIPETABS.MAGIC, 3)
Recipe("nightlight", {Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  3, "nightlight_placer")
Recipe("armor_sanity", {Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)}, RECIPETABS.MAGIC,  3)
Recipe("nightsword", {Ingredient("nightmarefuel", 5),Ingredient("livinglog", 1)}, RECIPETABS.MAGIC,  3)
Recipe("batbat", {Ingredient("batwing", 5), Ingredient("livinglog", 2), Ingredient("purplegem", 1)}, RECIPETABS.MAGIC, 3)


--REFINE
Recipe("rope", {Ingredient("cutgrass", 3)}, RECIPETABS.REFINE,  1)
Recipe("boards", {Ingredient("log", 4)}, RECIPETABS.REFINE,  1)
Recipe("cutstone", {Ingredient("rocks", 3)}, RECIPETABS.REFINE,  1)
Recipe("papyrus", {Ingredient("cutreeds", 4)}, RECIPETABS.REFINE,  1)
Recipe("purplegem", {Ingredient("redgem",1), Ingredient("bluegem", 1)}, RECIPETABS.REFINE, 2)
Recipe("nightmarefuel", {Ingredient("petals_evil", 4)}, RECIPETABS.REFINE, 3)

--WAR
Recipe("spear", {Ingredient("twigs", 2),Ingredient("rope", 1),Ingredient("flint", 1) }, RECIPETABS.WAR,  1)
Recipe("hambat", {Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)}, RECIPETABS.WAR,  2)
Recipe("armorgrass", {Ingredient("cutgrass", 10), Ingredient("twigs", 2)}, RECIPETABS.WAR,  0)
Recipe("armorwood", {Ingredient("log", 8),Ingredient("rope", 2)}, RECIPETABS.WAR,  1)
Recipe("armormarble", {Ingredient("marble", 12),Ingredient("rope", 4)}, RECIPETABS.WAR,  2)
Recipe("footballhat", {Ingredient("pigskin", 1), Ingredient("rope", 1)}, RECIPETABS.WAR,  2)
Recipe("blowdart_sleep", {Ingredient("cutreeds", 2),Ingredient("stinger", 1),Ingredient("feather_crow", 1) }, RECIPETABS.WAR,  1)
Recipe("blowdart_fire", {Ingredient("cutreeds", 2),Ingredient("charcoal", 1),Ingredient("feather_robin", 1) }, RECIPETABS.WAR,  1)
Recipe("blowdart_pipe", {Ingredient("cutreeds", 2),Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1) }, RECIPETABS.WAR,  1)
Recipe("boomerang", {Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)}, RECIPETABS.WAR,  2)
Recipe("beemine", {Ingredient("boards", 1),Ingredient("bee", 4),Ingredient("flint", 1) }, RECIPETABS.WAR,  1)
Recipe("trap_teeth", {Ingredient("log", 1),Ingredient("rope", 1),Ingredient("houndstooth", 1)}, RECIPETABS.WAR,  2)

--DRESSUP

Recipe("sewing_kit", {Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)}, RECIPETABS.DRESS, 2)

Recipe("flowerhat", {Ingredient("petals", 12)}, RECIPETABS.DRESS, 0)
Recipe("earmuffshat", {Ingredient("rabbit", 2), Ingredient("twigs",1)}, RECIPETABS.DRESS, 1)
Recipe("strawhat", {Ingredient("cutgrass", 12)}, RECIPETABS.DRESS,  1)
Recipe("beefalohat", {Ingredient("beefalowool", 8),Ingredient("horn", 1)}, RECIPETABS.DRESS,  1)
Recipe("beehat", {Ingredient("silk", 8), Ingredient("rope", 1)}, RECIPETABS.DRESS,  2)
Recipe("featherhat", {Ingredient("feather_crow", 3),Ingredient("feather_robin", 2), Ingredient("tentaclespots", 2)}, RECIPETABS.DRESS,  2)

Recipe("bushhat", {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)}, RECIPETABS.DRESS,  2)
Recipe("winterhat", {Ingredient("beefalowool", 4),Ingredient("silk", 4)}, RECIPETABS.DRESS,  2)
Recipe("tophat", {Ingredient("silk", 6)}, RECIPETABS.DRESS,  2)
Recipe("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, RECIPETABS.DRESS,  2)
Recipe("sweatervest", {Ingredient("houndstooth", 8),Ingredient("silk", 6)}, RECIPETABS.DRESS,  2)
Recipe("trunkvest_summer", {Ingredient("trunk_summer", 1),Ingredient("silk", 8)}, RECIPETABS.DRESS,  2)
Recipe("trunkvest_winter", {Ingredient("trunk_winter", 1),Ingredient("silk", 8), Ingredient("beefalowool", 2)}, RECIPETABS.DRESS,  2)


----GEMS----
Recipe("blueamulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("bluegem", 1)}, RECIPETABS.GEMOLOGY,  3)
Recipe("amulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.GEMOLOGY,  3)
Recipe("purpleamulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("purplegem", 1)}, RECIPETABS.GEMOLOGY,  3)
Recipe("icestaff", {Ingredient("spear", 1),Ingredient("bluegem", 1)}, RECIPETABS.GEMOLOGY,  2)
Recipe("firestaff", {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)}, RECIPETABS.GEMOLOGY, 3)
Recipe("telestaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)}, RECIPETABS.GEMOLOGY, 3)