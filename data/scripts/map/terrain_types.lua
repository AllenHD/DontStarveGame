
--TERRAIN_TYPES: 一个表格，包含了游戏中所有地形块的名称和属性信息，每个地形块都是一个表格，其中包含以下信息：
--	name: 地形块的名称。
--	is_ground: 表示地形块是否是地面，如果是则为 true。
--	is_border: 表示地形块是否是地图边界，如果是则为 true。
--	edge_build_allowed: 表示是否允许在地形块的边缘上建造建筑，如果允许则为 true。
--	needs_grass: 表示是否需要在地形块上生长草，如果需要则为 true。
--	noise_texture: 表示地形块的噪声纹理。
--	runsound: 表示脚步声的音效名称。
--	walksound: 表示行走声的音效名称。
--	snow_sound: 表示在该地形块上行走时被雪覆盖时的音效名称。
--	grass_sound: 表示在该地形块上行走时踩到草时的音效名称。
--	metal: 表示该地形块是否是金属地形块，如果是则为 true。
--	minimap_color: 表示该地形块在小地图中的颜色。
--	ground_texture: 表示该地形块在游戏中的贴图。
--	animated: 表示该地形块是否是动画地形块，如果是则为 true。
--	animations: 如果 animated 为 true，则该表格包含了地形块的动画信息，包括动画帧数、循环间隔等。

local TERRAIN = 
	{ 
	-- Lots of Trees, rarely haunted
		["BurntForest"] = {
					colour={r=.090,g=.10,b=.010,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									distributepercent = 0.4,
									distributeprefabs= {
										evergreen = 3 + math.random(4),
									},
									prefabdata={
										evergreen = {burnt=true},
									}
								}
						   },
		["CrappyDeepForest"] = {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .8,
					                distributeprefabs=
					                {
                                        fireflies = 0.1,
					                    evergreen_sparse = 6,
										spiderden = 0.01,
					                    grass = .05,
					                    sapling=.5,
					                    berrybush=.02,
					                    blue_mushroom = 0.02,
					                },
					            }
					
					},
		["DeepForest"] = {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .8,
					                distributeprefabs=
					                {
                                        fireflies = 0.1,
					                    evergreen = 6,
					                    grass = .05,
					                    sapling=.5,
					                    berrybush=.02,
					                    blue_mushroom = 0.02,
					                },
					            }
					
					},
	-- Trees, very few rocks, very few rabbit holes
		["Forest"] = {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
                                        fireflies = 0.2,
					                    evergreen = 6,
					                    rock1 = 0.05,
					                    grass = .05,
					                    sapling=.8,
					                    rabbithole=.05,
					                    berrybush=.03,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                },
					            }
					},
		["CrappyForest"] = {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
                                        fireflies = 0.2,
					                    evergreen_sparse = 6,
					                    rock1 = 0.05,
					                    grass = .05,
					                    sapling=.8,
					                    rabbithole=.05,
					                    berrybush=.03,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                },
					            }
					},
		["SpiderForest"] = {
					colour={r=.80,g=0.34,b=.80,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    evergreen_sparse = 6,
					                    rock1 = 0.05,
					                    sapling = .05,
										spiderden = 1,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=2}}
																else
																	return { growable={stage=1}}
																end
															end,
									},
					            }
					},
		["BurntClearing"] = {
					colour={r=.8,g=0.5,b=.7,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    evergreen = 0.15,
					                    grass = .1,
					                    sapling=.2,
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					},
	-- Trees on the outside, empty in the middle
		["Clearing"] = {
					colour={r=.8,g=0.5,b=.6,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingLarge"]=function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .1,
					                distributeprefabs=
					                {
										pighouse=0.015,
                                        fireflies = 1,
					                    evergreen = 1.5,
					                    grass = .1,
					                    sapling=.8,
					                    berrybush=.1,
					                    beehive=.05,
					                    red_mushroom = .01,
					                    green_mushroom = .02,
					                },
					            }
					},
	-- Trees on the outside, flowers in the middle
		["FlowerPatch"] = {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower=2,
					                    beehive=1,
					                },
					            }
					},
		["EvilFlowerPatch"] = {
					colour={r=.8,g=1,b=.4,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower_evil=2,
					                    wasphive=0.5,
					                },
					            }
					},
	-- Very few Trees, very few rocks, rabbit holes, some beefalow, some grass
		["Plain"] = {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    rock1 = 0.05,
					                    grass = .5,
					                    rabbithole=.25, 
					                    green_mushroom = .005,
					                },
					            }
					},
	-- Rabbit holes, Beefalow hurds if bigger
		["BarePlain"] = {					colour={r=.5,g=.5,b=.45,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    grass = .8,
					                    rabbithole=.4,
--					                    beefalo=0.2
					                },
					            }
					},
	-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
		["Rocky"] = {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.DIRT,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    rock1 = 2,
					                    rock2 = 2,
					                    tallbirdnest=.1,
					                    spiderden=.01,
					                    blue_mushroom = .002,
					                },
					            }
					},
	-- No trees, no rocks, very rare spiderden
		["Marsh"] = {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingMedium"]=function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    evergreen = 1.0,
					                    tentacle = 3,
					                    pond_mos = 1,
					                    reeds =  4,--function () return 3 + math.random(4) end,
					                    mandrake=0.0001,
					                    spiderden=.01,
					                    blue_mushroom = 0.01,
					                    green_mushroom = 2.02,
					                },
					            }
					},
		["SpiderMarsh"] = {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    evergreen = 1.0,
					                    tentacle = 2,
					                    pond_mos = 0.1,
					                    blue_mushroom = 0.1,
					                    reeds =  4,--function () return 3 + math.random(4) end,
					                    mandrake=0.0001,
					                    spiderden=3.15,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=2}}
																else
																	return { growable={stage=1}}
																end
															end,
									},
					            }
					},
		["SlightlyMermySwamp"] = {
					colour={r=0.5,g=.18,b=.35,a=.50},
					value = GROUND.MARSH,
					contents =  {

									distributepercent = .1,
									distributeprefabs= {
					                    --merm = 0.1,
					                    mermhouse = 0.1,
										pighead = 0.01,
					                    tentacle =  1,
					                    marsh_tree =  2,
					                    marsh_bush= 1.5,
									},
					            }
					 },
		["Nothing"] = {
					colour={r=.45,g=.45,b=.35,a=.50},
					value = GROUND.IMPASSABLE,
					contents =  {
					            }
					},
--[[ This is the "Default" background terrain, which was previously
     encoded in forest_map.lua for each ground type. 
	 --]]
		["BGBadlands"] = {
					colour={r=.76,g=.66,b=.1,a=.50},
					value = GROUND.DIRT,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										rock1=1,
										rock2=1,
										rocks=0.1,
										marsh_bush=1,
										marsh_tree=0.3,
										houndbone=0.5,
										houndmound=0.08,
					                },
					            }
					},
		["BGRocky"] = {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										tallbirdnest=0.008,
					                },
					            }
					},
		["BGNoise"] = {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.GROUND_NOISE,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .15,
									-- A bit of everything, and let terrain filters handle the rest.
					                distributeprefabs=
					                {
										flint=0.4,
										rocks=0.4,
										rock1=0.1,
										rock2=0.1,
										grass=0.09,
										rabbithole=0.025,
										flower=0.003,
										spiderden=0.001,
										beehive=0.003,
										berrybush=0.05,
										sapling=0.2,
										pond=.001,
					                    blue_mushroom = .001,
					                    green_mushroom = .001,
					                    red_mushroom = .001,
										evergreen=1.5,
					                },
					            }
					},
		["BGChessRocky"] = {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts = {
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										tallbirdnest=0.008,
					                },
					            }
					},
		["BGDirt"] = {
					colour={r=1.0,g=.8,b=.66,a=.50},
					value = GROUND.DIRT,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										rock1=1,
										rock2=1,
					                },
					            }
					},
		["BGSavanna"] = {
					colour={r=.8,g=.8,b=.2,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										spiderden=0.001,
										grass=0.09,
										rabbithole=0.025,
										flower=0.003,
					                },
					            }
					},
		["BGGrassBurnt"] = {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										rock1=0.01,
										rock2=0.01,
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										rabbithole=0.02,
										flint=0.05,
										sapling=0.2,
										evergreen=0.3,
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					},
		["BGGrass"] = {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										rabbithole=0.02,
										carrot_planted=0.05,
										flint=0.05,
										berrybush=0.05,
										sapling=0.2,
										evergreen=0.3,
										pond=.001,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                },
					            }
					},
		["BGCrappyForest"] = {
					colour={r=.1,g=.8,b=.1,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .6,
					                distributeprefabs=
					                {
										gravestone=0.01,
										pighouse=0.015,
										spiderden=0.04,
										grass=0.0025,
										sapling=0.15,
										rock1=0.008,
										rock2=0.008,
										evergreen_sparse=1.5,
										flower=0.05,
										pond=.001,
					                    green_mushroom = .025,
					                    red_mushroom = .025,
					                },
					            }
					},
		["BGForest"] = {
					colour={r=.1,g=.8,b=.1,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .6,
					                distributeprefabs=
					                {
										gravestone=0.01,
										pighouse=0.015,
										spiderden=0.02,
										grass=0.0025,
										sapling=0.15,
										berrybush=0.005,
										rock1=0.004,
										rock2=0.004,
										evergreen=1.5,
										flower=0.05,
										pond=.001,
					                    green_mushroom = .025,
					                    red_mushroom = .025,
					                },
					            }
					},
		["BGDeepForest"] = {
					colour={r=.1,g=.8,b=.1,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingSmall"]=function() 
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .8,
					                distributeprefabs=
					                {
										spiderden=0.05,
										rock1=0.004,
										rock2=0.004,
										evergreen=4.5,
										fireflies=0.1,
					                    blue_mushroom = .025,
					                    green_mushroom = .005,
					                    red_mushroom = .005,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.1 then
																	return { growable={stage=2}}
																else
																	return { growable={stage=1}}
																end
															end,
									},
					            }
					},
		["BGMarsh"] = {
					colour={r=.6,g=.2,b=.8,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingMedium"] = function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .25,
					                distributeprefabs=
					                {
										spiderden=0.003,
										sapling=0.0001,
										pond_mos=0.005,
										reeds=0.005,
										tentacle=0.095,
										marsh_bush=0.05,
										marsh_tree=0.1,
					                    blue_mushroom = .01,
					                    mermhouse=0.004,
					                },
					            }
					},
		["BGFungusRoom"] = {
					colour={r=.36,g=.32,b=.38,a=.50},
					value = GROUND.FUNGUS,
					--tags = {"ForceConnected"},
					contents =  {
									countstaticlayouts={["MushroomRingMedium"] = function()  
																				if math.random(0,200) > 185 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .15,
					                distributeprefabs=
					                {
										spiderhole=0.001,
										fireflies=0.01,
										flower_cave=0.01,
										tentacle=0.001,
					                    blue_mushroom = .01,
					                    slurtlehole = 0.003,
					                    mushtree_tall =0.02,	
					                },
					            }
					},
		["BGCaveRoom"] = {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.CAVE,
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
										spiderhole=0.001,
										flint=0.05,
										fireflies=0.001,
										stalagmite=0.03,
										stalagmite_tall=0.03,
										--stalagmite_gold=0.02,
					                    blue_mushroom = .005,
					                    slurtlehole = 0.001,
					                },
					            }
					},
		["BGSinkholeRoom"] = {
					colour={r=.15,g=.18,b=.15,a=.50},
					value = GROUND.SINKHOLE,
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
										grass=0.0025,
										sapling=0.15,
										evergreen=0.0025,
										berrybush=0.005,
										spiderden=0.01,
										fireflies=0.01,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                    mandrake=0.001,
					                    slurtlehole = 0.001,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.1 then
																	return { growable={stage=3}}
																else
																	return { growable={stage=2}}
																end
															end,
									},
					            }
					},
		["BGNoisyFungus"] =    {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS_NOISE, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    spiderhole= 0.1,
					                    mushtree_tall = 1.5,
										--mushroomtree_normal = 0.5,
										--mushroomtree_short = 0.5,
					                    slurtlehole = 0.001,
					                }
					            }
					},
		["BGNoisyCave"] =    {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE_NOISE, 
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                	stalagmite = 0.5,
										stalagmite_tall=0.5,
					                	--stalagmite_gold = 0.05,
					                    spiderhole= 0.1,
					                    slurtlehole = 0.01,
					                }
					            }
					},
		["BGImpassable"] = {
					colour={r=.6,g=.35,b=.8,a=.50},
					value = GROUND.IMPASSABLE,
					contents =  { }
					},
		["BGImpassableRock"] = {
					colour={r=.8,g=.8,b=.8,a=.90},
					value = GROUND.ABYSS_NOISE,
					contents =  { }
					},
	}

return {TERRAIN=TERRAIN}
