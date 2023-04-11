require "tuning"

local function AddIngredients(ingtable, tags, names, cancook, candry)
	for k,v in pairs(names) do
		ingtable[v] = { tags= {}}

		if cancook then
			ingtable[v.."_cooked"] = {tags={}}
		end

		if candry then
			ingtable[v.."_dried"] = {tags={}}
		end

		for kk,vv in pairs(tags) do
			ingtable[v].tags[kk] = vv
			--print(v,kk,vv,ingtable[v].tags[kk])

			if cancook then
				ingtable[v.."_cooked"].tags.precook = 1
				ingtable[v.."_cooked"].tags[kk] = vv
			end
			if candry then
				ingtable[v.."_dried"].tags.dried = 1
				ingtable[v.."_dried"].tags[kk] = vv
			end
		end
	end
end


local ingredients = {}
local fruits = {"pomegranate", "dragonfruit", "cave_banana"}
AddIngredients(ingredients, {fruit=1}, fruits, true)

AddIngredients(ingredients, {fruit=.5}, {"berries"}, true)
AddIngredients(ingredients, {fruit=1, monster=1}, {"durian"}, true)

AddIngredients(ingredients, {sweetener=1}, {"honey", "honeycomb"}, true)

local veggies = {"carrot", "corn", "pumpkin", "eggplant"}
AddIngredients(ingredients, {veggie=1}, veggies, true)

local mushrooms = {"red_cap", "green_cap", "blue_cap"}
AddIngredients(ingredients, {veggie=.5}, mushrooms, true)

AddIngredients(ingredients, {meat=1}, {"meat"}, true, true)
AddIngredients(ingredients, {meat=1, monster=1}, {"monstermeat"}, true, true)
AddIngredients(ingredients, {meat=.5}, {"froglegs", "drumstick"}, true)
AddIngredients(ingredients, {meat=.5}, {"smallmeat"}, true, true)

AddIngredients(ingredients, {meat=.5,fish=1}, {"fish"}, true)

AddIngredients(ingredients, {veggie=1, magic=1}, {"mandrake"}, true)
AddIngredients(ingredients, {egg=1}, {"egg"}, true)
AddIngredients(ingredients, {egg=4}, {"tallbirdegg"}, true)
AddIngredients(ingredients, {egg=1}, {"bird_egg"}, true)
AddIngredients(ingredients, {decoration=2}, {"butterflywings"})
AddIngredients(ingredients, {fat=1, dairy=1}, {"butter"})
AddIngredients(ingredients, {inedible=1}, {"twigs"})


--our naming conventions aren't completely consistent, sadly
local aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}

local function IsCookingIngredient(prefabname)
	local name = aliases[prefabname] or prefabname
	if ingredients[name] then
		return true
	end

end

local null_ingredient = {tags={}}
local function GetIngredientData(prefabname)
	local name = aliases.prefabname or prefabname

	return ingredients[name] or null_ingredient
end


local foods = require("preparedfoods")
recipes =
{
	cookpot = {}
}
for k,v in pairs (foods) do
	recipes.cookpot[v.name] = v
end

local function GetIngredientValues(prefablist)
	local prefabs = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = aliases[v] or v
		prefabs[name] = prefabs[name] and prefabs[name] + 1 or 1
		local data = GetIngredientData(name)

		if data then

			for kk, vv in pairs(data.tags) do

				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end

	return {tags = tags, names = prefabs}
end



function GetCandidateRecipes(cooker, ingdata)

	local recipes = recipes[cooker] or {}
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		if v.test(cooker, ingdata.names, ingdata.tags) then
			table.insert(candidates, v)
		end
	end

	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then
		--find the set of highest priority recipes
		local top_candidates = {}
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
		return top_candidates
	end

	return candidates
end



local function CalculateRecipe(cooker, names)


	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(cooker, ingdata)

	table.sort( candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )
	local total = 0
	for k,v in pairs(candidates) do
		total = total + (v.weight or 1)
	end

	local val = math.random()*total
	local idx = 1
	while idx <= #candidates do
		val = val - candidates[idx].weight
		if val <= 0 then
			return candidates[idx].name, candidates[idx].cooktime or 1
		end

		idx = idx+1
	end

end



local function TestRecipes(cooker, prefablist)
	local ingdata = GetIngredientValues(prefablist)

	print ("Ingredients:")
	for k,v in pairs(prefablist) do
		if not IsCookingIngredient(v) then
			print ("NOT INGREDIENT:", v)
		end
	end

	for k,v in pairs(ingdata.names) do
		print (v,k)
	end

	print ("\nIngredient tags:")
	for k,v in pairs(ingdata.tags) do
		print (tostring(v), k)
	end

	print ("\nPossible recipes:")
	local candidates = GetCandidateRecipes(cooker, ingdata)
	for k,v in pairs(candidates) do
		print("\t"..v.name, v.weight or 1)
	end

	local recipe = CalculateRecipe(cooker, prefablist)
	print ("Make:", recipe)


	print ("total health:", foods[recipe].health)
	print ("total hunger:", foods[recipe].hunger)

end

--TestRecipes("cookpot", {"tallbirdegg","meat","carrot","meat"})


return { CalculateRecipe = CalculateRecipe, IsCookingIngredient = IsCookingIngredient, recipes = recipes}

