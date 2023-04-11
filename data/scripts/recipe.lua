require "class"
require "util"

Ingredient = Class(function(self, type, amount)
    self.type = type
    self.amount = amount
   	self.atlas = resolvefilepath("images/inventoryimages.xml")
end)

local num = 0
Recipes = {}

Recipe = Class(function(self, name, ingredients, tab, level, placer, min_spacing)
    self.name = name
    self.placer = placer
    self.descname = STRINGS.NAMES[string.upper(name)]
    self.description = STRINGS.RECIPE_DESC[string.upper(name)]
    self.ingredients = ingredients
    self.product = name
    self.tab = tab

   	self.atlas = resolvefilepath("images/inventoryimages.xml")
   	self.image = name .. ".tex"
	self.sortkey = num
	self.level = level or 0
	self.placer = placer
	self.min_spacing = min_spacing or 3.2

	num = num + 1    
    Recipes[name] = self
end)



function GetAllRecipes()
	return Recipes
end

function GetRecipe(name)
    return Recipes[name]
end
