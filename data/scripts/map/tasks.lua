------------------------------------------------------------------------------------------
---------             SAMPLE TASKS                   --------------------------------------
------------------------------------------------------------------------------------------
require("map/task")
require("map/lockandkey")
require("map/terrain")

local blockersets = require("map/blockersets")

local sz = 64
local noise_scale = math.random(5)+4
local offx = math.random(100)
local offy = math.random(100)

local SIZE_VARIATION = 3
-- A set of tasks to be performed 
local threeToFive = function () return 3 + math.random(2) end

local everything_sample2 = {
	Task("One of everything", {
		locks=LOCKS.NONE,
		keys_given=KEYS.PICKAXE,
		room_choices_special={
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["SpiderCon"] = 3,
		},
		room_choices={
			["Forest"] = 1, 
		 }, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
}
local everything_sample = {
	Task("One of everything", {
		locks=LOCKS.NONE, 
		keys_given=KEYS.PICKAXE, 
		room_choices_special={
			["Graveyard"] = 1, 
			["BeefalowPlain"] = 1, 		
			["SpiderVillage"] = 1, 
			["PigKingdom"] = 1, 
			["PigVillage"] = 1, 
			["MandrakeHome"] = 1,
			["BeeClearing"] = 1,
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["Rockpile"] = 1,
			["Woodpile"] = 1,
			["Trapfield"] = 1,
			["Minefield"] = 1,
			["SpiderCon"] = 1,
		},
		room_choices={
			["Forest"] = 1, 
			["Rocky"] = 1, 
			["BarePlain"] = 1, 
			["Plain"] = 1, 
			["Marsh"] = 1, 
			["DeepForest"] = 1, 
			["Clearing"] = 1,
			["BurntForest"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
}

local samples = {
	Task("Make a pick", {
		locks=LOCKS.NONE,
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1},
		room_choices_special={
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Resource-rich Tier2", {
		locks=LOCKS.NONE, -- Special story starting node
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1,KEYS.TIER2},
		room_choices_special={
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Resource-Rich", {
		locks=LOCKS.NONE,
		keys_given={KEYS.TIER1}, -- Special story node has only one key
		room_choices_special={
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Wasps and Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		entrance_room=blockersets.all_bees,
		room_choices_special={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
		},
		room_choices={
			["EvilFlowerPatch"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		room_choices_special={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
		},
		room_choices={
			["FlowerPatch"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Hounded Magic meadow", {
		locks={LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOD,KEYS.HOUNDS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_hounds,
		room_choices_special={
			["Pondopolis"] = 2,
		},
		room_choices={
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		}, 
		room_bg=GROUND.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Magic meadow", {
		locks={LOCKS.TIER1},
		keys_given={KEYS.GRASS,KEYS.MEAT,KEYS.TIER1},
		room_choices_special={
			["Pondopolis"] = 2,
		},
		room_choices={
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		}, 
		room_bg=GROUND.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Waspy The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		entrance_room=blockersets.all_bees,
		room_choices_special={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
		},
		room_choices={
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		room_choices_special={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
		},
		room_choices={
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Guarded Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		entrance_room=ArrayUnion(blockersets.rocky_hard, blockersets.all_walls),
		room_choices_special={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
		},
		room_choices={
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		room_choices_special={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
		},
		room_choices={
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Insanity-Blocked Necronomicon", {
		locks={LOCKS.TIER3},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		entrance_room=blockersets.all_walls,
		room_choices_special={
			["Graveyard"] = 3,
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}), 
	Task("Necronomicon", {
		locks={LOCKS.ROCKS,LOCKS.TIER2},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		room_choices_special={
			["Graveyard"] = 3,
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}), 
																  
	Task("Easy Blocked Dig that rock", {
		locks={LOCKS.ROCKS,LOCKS.TIER1},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		entrance_room_chance=0.5,
		entrance_room=blockersets.all_easy,
		room_choices_special={
			["Graveyard"] = 1,
			--["Wormhole"] = 1,
		},
		room_choices={
			["Rocky"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = math.random(SIZE_VARIATION)
		},
		room_bg=GROUND.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	}), 
																  
	Task("Dig that rock", {
		locks={LOCKS.ROCKS},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		room_choices_special={
			["Graveyard"] = 1,
			["Sinkhole"] = 2,
		},
		room_choices={
			["Rocky"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = math.random(SIZE_VARIATION)
		},
		room_bg=GROUND.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	}), 
																  
	Task("Tentacle-Blocked The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER3},
		keys_given={KEYS.TENTACLES,KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER3},
		entrance_room=blockersets.all_tentacles,
		room_choices_special={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
		},
		room_choices={
			["BGForest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	}), 
	Task("The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER2},
		room_choices_special={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	}), 
--------------------------------------------------------------------------------
-- Pigs 
--------------------------------------------------------------------------------
	Task("Trapped Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		entrance_room="Trapfield",
		room_choices_special={
			["PigVillage"] = 1, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}), 
	Task("Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER1},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		room_choices_special={
			["PigVillage"] = 1, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}), 
	Task("Pigs in the city", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices_special={
			["PigCity"] = 1, 
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 1, 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=1,g=0,b=0,a=1}
	}), 
	Task("The Pigs are back in town", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices_special={
			["PigTown"] = 1, 
		},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 1, 
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}), 
 	Task("Guarded King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room="PigGuardpost",
		room_choices_special={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
		},
		room_choices={
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	}), 
 	Task("Guarded Speak to the king", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room=blockersets.all_pigs,
		room_choices_special={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["DeepForest"] = 3 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	}), 
 	Task("King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices_special={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
		},
		room_choices={
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	}), 
 	Task("Speak to the king", {
		locks={LOCKS.PIGKING,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.GOLD,KEYS.TIER3},
		room_choices_special={
			["PigKingdom"] = 1,
			["Sinkhole"] = 1,
			--["Wormhole"] = 1,
		},
		room_choices={
			["DeepForest"] = 3 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	}), 
--------------------------------------------------------------------------------
-- Beefalo 
--------------------------------------------------------------------------------
	Task("Hounded Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.HOUNDS,KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_hounds,
		room_choices_special={
			["BeefalowPlain"] = 3 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}), 
	Task("Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.WALRUS,KEYS.TIER4},
		room_choices_special={
			["BeefalowPlain"] = 3 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}), 
	Task("Sanity-Blocked Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices_special={
			["BeefalowPlain"] = 1 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}), 
	Task("Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		room_choices_special={
			["BeefalowPlain"] = 1 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}), 
--------------------------------------------------------------------------------
-- Hounds 
--------------------------------------------------------------------------------
	Task("Rock-Blocked HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room="DenseRocks",
		room_choices_special={
			["Moundfield"] = 1 + math.random(SIZE_VARIATION), 		
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			}, 
		room_bg=GROUND.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	}), 
	Task("HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		room_choices_special={
			["Moundfield"] = 1 + math.random(SIZE_VARIATION), 		
		}, 
		room_choices={
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			}, 
		room_bg=GROUND.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	}), 
--------------------------------------------------------------------------------
-- Merms 
--------------------------------------------------------------------------------
	Task("Merms ahoy", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.MERMS,KEYS.MEAT,KEYS.SPIDERS,KEYS.SILK,KEYS.TIER4},
		room_choices_special={
			["MermTown"] = 1+math.random(SIZE_VARIATION), 
		},
		room_choices={
			["SpiderMarsh"] = 3+math.random(SIZE_VARIATION), 
			["Marsh"] = 3+math.random(SIZE_VARIATION), 
			["DeepForest"] = 2+math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=1,g=0,b=0,a=1}
	}), 
	Task("Sane-Blocked Swamp", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.TENTACLES,KEYS.WOOD,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices_special={
			--["Wormhole"] = 1,
		},
		room_choices={
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("Guarded Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER2},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_marsh,
		room_choices_special={
			--["Wormhole"] = 1,
		},
		room_choices={
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER2},
		room_choices_special={
			["Sinkhole"] = 1,
		},
		room_choices={
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("Wood in the Wet", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.WOOD,
		room_choices_special={
			["Woodpile"] = 1,
			--["Wormhole_Swamp"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("Swamp start", {
		locks=LOCKS.NONE,
		keys_given={KEYS.MERMS,KEYS.TIER2,KEYS.TIER3},
		room_choices_special={
			["SafeSwamp"] = 2,
			--["Wormhole_Swamp"] = 1,
		},
		room_choices={
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.5,a=1}
	}), 
	Task("Tentacle-Blocked Spider Swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.TENTACLES,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		entrance_room=blockersets.all_tentacles,
		room_choices_special={
			["SpiderVillageSwamp"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.5,g=.05,b=.05,a=1}
	}), 
	Task("Lots-o-Spiders", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.SPIDERS,KEYS.TIER3,KEYS.AXE},
		entrance_room=blockersets.all_spiders,
		room_choices_special={
			["SpiderCity"] = 1,
			["SpiderVillage"] = 2,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["CrappyForest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	}), 
	Task("Lots-o-Tentacles", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TENTACLES,KEYS.TIER3,KEYS.AXE},
		entrance_room="TentaclelandA",
		room_choices_special={
			["MermTown"] = 1,
		},
		room_choices={
			["Marsh"] = 1+math.random(SIZE_VARIATION), 
			["SlightlyMermySwamp"] = 1+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.5,a=1}
	}), 
	Task("Lots-o-Tallbirds", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TALLBIRDS,KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD,KEYS.AXE},
		entrance_room=blockersets.all_tallbirds,
		room_choices_special={
			["WalrusHut_Rocky"] = 1,
			["WalrusHut_Plains"] = 1,
			["BeefalowPlain"] = 1+math.random(SIZE_VARIATION), 
			["TallbirdNests"] = 1+math.random(SIZE_VARIATION), 
		},
		room_choices={
		},
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.5,g=.3,b=.05,a=1}
	}), 
	Task("Lots-o-Chessmonsters", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.CHESSMEN,KEYS.GEARS,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD},
		entrance_room=blockersets.all_chess,
		room_choices_special={
			["ChessForest"] = 1+math.random(SIZE_VARIATION),
			["ChessBarrens"] = 1+math.random(SIZE_VARIATION),
			["ChessMarsh"] = 1+math.random(SIZE_VARIATION),
		},
		room_choices={
		},
		room_bg=GROUND.ROCKY,
		background_room="BGChessRocky",
		colour={r=.8,g=.08,b=.05,a=1}
	}), 
	Task("Spider swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		room_choices_special={
			--["Wormhole_Swamp"] = 1,
			["SpiderVillageSwamp"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.15,g=.05,b=.7,a=1}
	}), 
	--Task("Into the Nothing small", {
		--lock,LOCKS.ROCKS,
		--keys_given=KEYS.MEAT,
		--room_choices_special={
		--},
		--room_choices={
			--["Forest"] = 1, 
			--["Nothing"] = 1+math.random(SIZE_VARIATION)
		--},  
		--room_bg=GROUND.IMPASSABLE,
		--colour={r=.05,g=.05,b=.05,a=1}
	--}),
 	Task("Sanity-Blocked Spider Queendom", {
		locks={LOCKS.PIGKING,LOCKS.SPIDERDENS,LOCKS.ADVANCED_COMBAT,LOCKS.TIER5},
		keys_given={KEYS.SPIDERS,KEYS.HARD_SPIDERS,KEYS.TIER5,KEYS.TRINKETS},
		entrance_room=blockersets.all_walls,
		room_choices_special={
			["SpiderCity"] = 4, 
			["Graveyard"] = 1,
		},
		room_choices={
			["CrappyDeepForest"] = 2,
		}, 
		room_bg=GROUND.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0,a=1}
	}), 
 	Task("Spider Queendom", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices_special={
			["SpiderCity"] = 4, 
			--["Wormhole_Plains"] = 1,
			["Graveyard"] = 1,
		},
		room_choices={
			["CrappyDeepForest"] = 2,
		}, 
		room_bg=GROUND.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0.2,a=1}
	}), 
																  
	Task("Guarded For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		entrance_room_chance=0.3,
		entrance_room=ArrayUnion(blockersets.forest_easy, blockersets.all_grass, blockersets.walls_easy),
		room_choices_special={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = 1 + math.random(SIZE_VARIATION),
			--["Wormhole"] = 1,
		},
		room_choices={
			["DeepForest"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	}), 
	Task("For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		room_choices_special={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = 1 + math.random(SIZE_VARIATION),
			--["Wormhole"] = 1,
		},
		room_choices={
			["DeepForest"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	}), 
	Task("Mine Forest", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.MEAT,
		room_choices_special={
			["Trapfield"] = 4,
		},
		room_choices={
			["Clearing"] = 2
		},  
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=.05,g=.5,b=.05,a=1}
	}), 
	Task("Battlefield", {
		locks={LOCKS.SPIDERDEN,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.SPIDERS,KEYS.PIGS,KEYS.SILK,KEYS.TIER5},
		entrance_room="Trapfield",
		room_choices_special={
			["Trapfield"] = 1,
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
			["PigCamp"] = 2,
		},
		room_choices={
			["BGForest"] = 1,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.05,g=.8,b=.05,a=1}
	}), 
	Task("Guarded Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_forest,
		room_choices_special={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
		},
		room_choices={
			["BGForest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	}), 
	Task("Trapped Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room="Trapfield",
		room_choices_special={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	}), 
	Task("Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		room_choices_special={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.15,g=.5,b=.05,a=1}
	}), 
	Task("Walled Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		entrance_room_chance=0.4,
		entrance_room=blockersets.walls_easy,
		room_choices_special={
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["CrappyForest"] = math.random(SIZE_VARIATION), 
			["CrappyDeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.15,g=.5,b=.15,a=1}
	}), 
	Task("Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		room_choices_special={
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["CrappyForest"] = math.random(SIZE_VARIATION), 
			["CrappyDeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.25,g=.4,b=.06,a=1}
	}), 
	Task("Waspy Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		entrance_room_chance=0.8,
		entrance_room=blockersets.all_bees,
		room_choices_special={
			["BeeClearing"] = 1, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	}), 
	Task("Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		room_choices_special={
			["BeeClearing"] = 1, 
			--["Wormhole"] = 1,
		},
		room_choices={
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	}), 
	Task("Killer Bees!", {
		locks={LOCKS.KILLERBEES,LOCKS.TIER3},
		keys_given={KEYS.HONEY,KEYS.TIER3},
		entrance_room= "Waspnests",
		room_choices_special={
			--["Wormhole"] = 1,
			["Waspnests"] = math.random(SIZE_VARIATION), 
		},
		room_choices={
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=0.1,b=0.1,a=1}
	}), 
	Task("Pretty Rocks Burnt", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.BEEHAT,
		room_choices_special={
			--["Wormhole_Plains"] = 1,
		},
		room_choices={
			["Rocky"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	}),
	Task("Make A Beehat", {
		locks={LOCKS.SPIDERS_DEFEATED,LOCKS.TIER1},
		keys_given={KEYS.BEEHAT,KEYS.GRASS,KEYS.TIER1},
		room_choices_special={
			--["Wormhole_Plains"] = 1,
		},
		room_choices={
			["Rocky"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=1,b=0.5,a=1}
	}),
	Task("The charcoal forest", {
		locks=LOCKS.NONE,
		keys_given=KEYS.NONE,
		room_choices_special={
			--["Wormhole_Burnt"] = 1,
			["BurntForestStart"] = 1,
		},
		room_choices={
			["BurntForest"] = math.random(SIZE_VARIATION), 
			["BurntClearing"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	}),
	Task("Land of Plenty", {
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices_special={
			["PigCamp"] = 2,
			["PigTown"] = 2,
			["PigCity"] = 1,
			["BeeClearing"] = 1,
			["MandrakeHome"] = 2,
			["BeefalowPlain"] = 2,
			["Graveyard"] = 2,
		},
		room_choices={
			["Forest"] = 2,
			["DeepForest"] = 1,
			["BGRocky"] = 1,
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=.05,g=.5,b=.05,a=1}
	}), 
	Task("The other side", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.NONE,
		entrance_room = "SanityWormholeBlocker",
		room_choices_special={
			["Graveyard"] = math.random(2),
			["SpiderCity"] = math.random(SIZE_VARIATION), 
			["Waspnests"] = 1, 
			["WalrusHut_Rocky"] = math.random(1),
			["Pondopolis"] = math.random(2),
			["Tentacleland"] = math.random(SIZE_VARIATION), 		
			["Moundfield"] = math.random(2), 		
			["MermTown"] = 1 + math.random(SIZE_VARIATION), 		
			["Trapfield"] = 1 + math.random(2), 		
			["ChessArea"] = math.random(2),
			["ChessMarsh"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(2), 
		},  
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	}), 
	Task("Chessworld", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER5},
		keys_given={KEYS.CHESSMEN,KEYS.TIER5},
		entrance_room=blockersets.all_chess,
		room_choices_special={
			["ChessArea"] = 2,
			["MarbleForest"] = 1+ math.random(SIZE_VARIATION),
			["ChessBarrens"] = 2,
		},
		room_choices={
		},  
		room_bg=GROUND.MARSH,
		background_room="BGChessRocky",
		colour={r=.05,g=.5,b=.05,a=1},
	}),
	--Task("Into the Nothing", {
		--locks=LOCKS.SPIDERDENS,
		--keys_given=KEYS.MEAT,
		--room_choices_special={
			--["PigCamp"] = 1, 
		--},
		--room_choices={
			--["Forest"] = 1, 
			--["Nothing"] = 1+math.random(SIZE_VARIATION)
		--},  
		--room_bg=GROUND.IMPASSABLE,
		--colour={r=.05,g=.05,b=.05,a=1}
	--}), 
		--{ fn = GeneratePerlinXY, args = { sz=sz, noise_scale=noise_scale, offx=offx, offy=offy }})
	Task("MaxPuzzle1", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices_special={
			["MaxPuzzle1"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("MaxPuzzle2", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices_special={
			["MaxPuzzle2"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	Task("MaxPuzzle3", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices_special={
			["MaxPuzzle3"] = 1,
		},
		room_choices={
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 
	
	Task("MaxHome", {
		lock=LOCKS.NONE,
		key_given=KEYS.NONE,
		room_choices_special={
			["MaxHome"] = 1,
		},
		room_choices={
		},
		room_bg=GROUND.IMPASSABLE,
		background_room="BGImpassable",
		colour={r=.05,g=.05,b=.05,a=1}
	}), 

------------------------------------------------------------
-- Island Hopping
------------------------------------------------------------

	Task("IslandHop_Start", { -- Sweet starting node, horrid other than that (leave the island)
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices={
			["SpiderMarsh"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),

	Task("IslandHop_Hounds", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SpiderForest"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGBadlands",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),

	Task("IslandHop_Forest", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices_special={
			["Waspnests"] = 1+math.random(2), 
		},
		-- room_choices={
		-- 	["DeepForest"] = 1+math.random(2), 
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGDeepForest",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),

	Task("IslandHop_Savanna", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices_special={
			["BeefalowPlain"] = 1+math.random(2), 
		},
		-- room_choices={
		-- 	["BeefalowPlain"] = 1+math.random(2), 
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGSavanna",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),

	Task("IslandHop_Rocky", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["Rocky"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGRocky",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),

	Task("IslandHop_Merm", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SlightlyMermySwamp"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	}),




------------------------------------------------------------
-- Caves Initial Level
------------------------------------------------------------
	Task("CavesStart", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices_special={
			["MistyCavern"] = 2+math.random(2),
			["PitCave"] = 3+math.random(2),
			["RockLobsterPlains"] = 1,
		},
		room_choices={
			["BGCaveRoom"] = 4+math.random(2),
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.7,b=1,a=1},
	}),
	Task("CavesAlternateStart", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices_special={
			["SinkholeRoom"] = 3+math.random(2),
			["MistyCavern"] = 1,
			["RockLobsterPlains"] = 1+math.random(2),
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.5,b=1,a=1},
	}),

	Task("BatCaves", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		entrance_room = "BatCaveRoomAntichamber",
		room_choices_special={
			["CaveRoom"] = 2+math.random(2),
			["BatCaveRoom"] = 4+math.random(2),
		},
		room_bg=GROUND.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.6,b=1,a=1},
	}),
	Task("FungalBatCave", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.FUNGUS,
		room_choices_special={
			["FungusRoom"] = 2+math.random(2),
			["BatCaveRoom"] = 1+math.random(2),
		},
		room_bg=GROUND.FUNGUS,
		background_room="BGFungusRoom",
		colour={r=1,g=0,b=0.5,a=1},
	}),
	Task("TentacledCave", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.NONE,
		room_choices_special={
			["PitRoom"] = 1+math.random(2),
			["TentacleCave"] = 1+math.random(4),
		},
		room_bg=GROUND.MARSH,
		background_room="BGFungusRoom",
		colour={r=0.5,g=0,b=1,a=1},
	}),

	Task("LargeFungalComplex", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices_special={
			["BatCaveRoom"] = 3+math.random(4),
			["PitRoom"] = 10+math.random(7),
		},
		room_bg=GROUND.WALL_ROCKY,
		background_room="BGFungusRoom",
		colour={r=0.6,g=0,b=1,a=1},
	}),
	Task("RabbitsAndFungs", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices_special={
			["RabitFungusRoom"] = 1+math.random(2),
			["Stairs"] = 1,
		},
		room_choices={
			["BGCaveRoom"] = 2+math.random(2),
		},
		room_bg=GROUND.WALL_ROCKY,
		background_room="BGCaveRoom",
		colour={r=0.8,g=0,b=1,a=1},
	}),
	Task("SingleBatCaveTask", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices_special={
			["BatCaveRoom"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=1,b=1,a=1},
	}),

	Task("FungalPlain", {
		locks={LOCKS.CAVE, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices_special={
			["NoisyFungus"] = 3+math.random(2),
			["RabitFungusRoom"] = 1+math.random(2),
			["RockLobsterPlains"] = 1+math.random(2),
		},
		room_bg=GROUND.FUNGUS_NOISE,
		background_room="BGNoisyFungus",
		colour={r=1,g=0,b=0.6,a=1},
	}),
	Task("Cavern", {
		locks={LOCKS.LIGHT, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices_special={
			["NoisyCave"] = 3+math.random(2),
			["RockLobsterPlains"] = 1,
		},
		room_bg=GROUND.CAVE_NOISE,
		background_room="BGNoisyCave",
		colour={r=1,g=0,b=0.7,a=1},
	}),

	Task("FungalRabitCityPlain", {
		locks={LOCKS.CAVE, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices_special={
			["NoisyFungus"] = 3+math.random(2),
			["RabitFungusRoom"] = 1+math.random(2),
			["RockLobsterPlains"] = 1+math.random(2),
			["RabbitCity"] = 4+math.random(2),
		},
		room_bg=GROUND.UNDERROCK,
		background_room="BGNoisyFungus",
		colour={r=1,g=0,b=0.6,a=1},
	}),

------------------------------------------------------------
-- CAVE "BASE" TASKS - TEMP POINTS OF INTEREST
------------------------------------------------------------

	Task("CaveBase",
	{
		locks={LOCKS.CAVE},
		keys_given=KEYS.NONE,
		room_choices_special={
			["CaveBase"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGNoisyCave",
		colour={r=1,g=0,b=0.7,a=1},
	}),

	Task("MushBase",
	{
		locks={LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices_special={
			["MushBase"] = 1,
		},
		room_bg=GROUND.FUNGUS,
		background_room="BGFungusRoom",
		colour={r=1,g=0,b=0.6,a=1},
	}),

	Task("SinkBase",
	{
		locks={LOCKS.LIGHT},
		keys_given=KEYS.NONE,
		room_choices_special={
			["SinkBase"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0,b=0.7,a=1},
	}),

	Task("RabbitTown",
	{
		locks={LOCKS.LIGHT},
		keys_given=KEYS.NONE,
		room_choices_special={
			["RabbitTown"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0,b=0.7,a=1},
	}),

------------------------------------------------------------
-- TEST TASKS
------------------------------------------------------------
	Task("TEST_TASK", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices={
			["BGCaveRoom"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0.7,b=1,a=1},
	}),

	Task("TEST_TASK1", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices_special={
			["CaveRoom"] = 3,
			["BatCaveRoom"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.6,b=1,a=1},
	}),
}

local function GetTaskByName(name, tasks)
	for i,task in ipairs(tasks) do 
		if task.id == name then
			return task
		end
	end

	return nil
end

tasks = {
	sampletasks = samples,
	oneofeverything = everything_sample,
	GetTaskByName = GetTaskByName,
}
