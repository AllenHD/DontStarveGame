
GROUND_NAMES=
{
	    [GROUND.IMPASSABLE] = "Impassible",
		[GROUND.ROAD] = "Road",
	    [GROUND.ROCKY] = "Rocky",
	    [GROUND.DIRT] = "Dirt",
	    [GROUND.SAVANNA] = "Savanna",
		[GROUND.GRASS] = "Grass",
		[GROUND.FOREST] = "Forest",
	    [GROUND.MARSH] = "Marsh",
		[GROUND.WOODFLOOR] = "Wood",
		[GROUND.CHECKER] = "Checkers",
	    [GROUND.CARPET] = "Carpet",

		[GROUND.CAVE] = "CAVE",
		[GROUND.FUNGUS] = "FUNGUS",
	    [GROUND.SINKHOLE] = "SINKHOLE",
	    [GROUND.UNDERROCK] = "UNDERROCK",
	    [GROUND.MUD] = "MUD",

		[GROUND.WALL_MARSH] = "WALL_MARSH",
		[GROUND.WALL_FUNGUS] = "WALL_FUNGUS",
	    [GROUND.WALL_ROCKY] = "WALL_ROCKY",
		[GROUND.WALL_DIRT] = "WALL_DIRT",
		[GROUND.WALL_CAVE] = "WALL_CAVE",
	    [GROUND.WALL_SINKHOLE] = "WALL_SINKHOLE",
	    [GROUND.WALL_MUD] = "WALL_MUD",

		[GROUND.GROUND_NOISE] = "GROUND_NOISE",
	    [GROUND.CAVE_NOISE] = "CAVE_NOISE",
	    [GROUND.FUNGUS_NOISE] = "FUNGUS_NOISE",
}


-- These items will not spawn on a terrain tile of the types in the list provided
local TERRAIN_FILTER=
	{
		berrybush=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		berrybush2=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		beefalo=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		beehive=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		wasphive=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		beemine = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		carrot_planted = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH },
		evergreen		= 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT },
		evergreen_normal = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT },
		evergreen_short = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT },
		evergreen_tall = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_sparse = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_sparse_normal = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_sparse_short = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_sparse_tall = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_burnt = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		evergreen_stump = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.DIRT, GROUND.MARSH},
		flower = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		red_mushroom = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		green_mushroom = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		blue_mushroom = 	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		flint = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		fireflies = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		grass = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		depleted_grass =	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		gravestone = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		log = 				{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		mandrake = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		marsh_bush = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		marsh_tree = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		pighouse =			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		pigman =			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		mermhouse =			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		pond = 				{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		pond_mos = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		reeds = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY },
		rock1 = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		rock2 = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		rock_flintless =	{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		basalt = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		basalt_pillar =		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		rocks = 			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		rabbithole=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		sapling=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.MARSH},
		spiderden = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		spiderden_2 = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		spiderden_3 = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		tallbirdnest = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		tentacle=			{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER, GROUND.ROCKY, GROUND.GRASS, GROUND.FOREST, GROUND.SAVANNA},
		trap_teeth = 		{GROUND.ROAD, GROUND.WOODFLOOR, GROUND.CARPET, GROUND.CHECKER },
		marbletree =		{GROUND.ROAD},
		marblestatue =		{GROUND.ROAD},
	}

TERRAIN_FILTER.Print = function (filter)
	local val = ""
	for i,v in ipairs(filter) do
		val = val .." ".. GROUND_NAMES[v]
	end
	return val
end

local TERRAIN_TYPES = require "map/terrain_types"
local special_rooms = require "map/special_rooms"


terrain={base=TERRAIN_TYPES.TERRAIN, special=special_rooms.SpecialRooms, filter=TERRAIN_FILTER}
