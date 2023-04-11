require("util")
require("screen")
require("button")
require("animbutton")
require("image")
require("uianim")
require("spinner")
require("numericspinner")
require("screens/popupdialog")

local spinner_images = {
  arrow_normal = "data/images/spin_arrow.tex",
  arrow_over = "data/images/spin_arrow_over.tex",
  arrow_disabled = "data/images/spin_arrow_disabled.tex",
  bgtexture = "data/images/spinner.tex"
}
local text_font = DEFAULTFONT

local enableDisableOptions = { { text = "Disabled", data = false }, { text = "Enabled", data = true } }

local entityOptions = {
--  {text = "Test Hound", data = "hound2"},
  {text = "Beefalo", data = "beefalo"},
  {text = "Baby Beefalo ", data = "babybeefalo"},
  {text = "Tallbird", data = "tallbird"},
  {text = "Smallbird", data = "smallbird"},
  {text = "Hound", data = "hound"},
  {text = "Fire Hound", data = "firehound"},
  {text = "Pig Man", data = "pigman"},
  {text = "Pig King", data = "pigking"},
  {text = "Spider ", data = "spider"},
  {text = "Spider Warrior ", data = "spider_warrior"},
  {text = "Spider Queen", data = "spiderqueen"},
  {text = "Tentacle", data = "tentacle"},
  {text = "Krampus", data = "krampus"},
  {text = "Koalefant", data = "koalefant"},
  {text = "Treeguard", data = "leif"},
  {text = "Gobbler", data = "perd"},
  {text = "Rabbit", data = "rabbit"},
  {text = "Butterfly", data = "butterfly"},
  {text = "Bee", data = "bee"},
  {text = "Frog", data = "frog"},
  {text = "Ghost", data = "ghost"},
  {text = "Mandrake", data = "mandrake"},
  {text = "Crow", data = "crow"},
  {text = "Robin", data = "robin"},
  {text = "Chester", data = "chester"},
  {text = "Abigail", data = "abigail"},
  {text = "Crawling Horror", data = "crawlinghorror"},
  {text = "Terrorbeak", data = "terrorbeak"}
}

local uncraftableItemOptions = { 

  {text = "Log", data = "log"},
  {text = "Rocks", data = "rocks"},
  {text = "Twigs", data = "twigs"},
  {text = "Cut Grass", data = "cutgrass"},
  {text = "Pinecone", data = "pinecone"},
  {text = "Flint", data = "flint"},
  {text = "Gold Nugget", data = "goldnugget"},
  {text = "Cut Reeds", data = "cutreeds"},
  {text = "Manure", data = "poop"},
  {text = "Charcoal", data = "charcoal"},
  {text = "Silk ", data = "silk"},
  {text = "Beefalo Wool", data = "beefalowool"},
  {text = "Pig Skin", data = "pigskin"},
  {text = "Stinger", data = "stinger"},
  {text = "Dug Berrybush", data = "dug_berrybush"},
  {text = "Dug Sapling", data = "dug_sapling"},
  {text = "Dug Grass", data = "dug_grass"},
  {text = "Tentacle Spots", data = "tentaclespots"},
  {text = "Crow Feather", data = "feather_crow"},
  {text = "Robin Feather", data = "feather_robin"},
  {text = "Koalefant Trunk", data = "trunk_summer"},
  {text = "Honeycomb", data = "honeycomb"},
  {text = "Bee", data = "bee"},
  {text = "Butterfly", data = "butterfly"},
  {text = "Fireflies", data = "fireflies"},
  {text = "Red Gem", data = "redgem"},
  {text = "Beard Hair", data = "beardhair"},
  {text = "Tentacle Spike", data = "tentaclespike"},
  {text = "Beefalo Horn", data = "horn"},
  {text = "Krampus Sack", data = "krampus_sack"},
  {text = "Spider Eggs", data = "spidereggsack"},
  {text = "Chester Eyebone", data = "chester_eyebone"},
  {text = "Nightmare Fuel", data = "nightmarefuel"},
  {text = "Ash", data = "ash"},
}

local foodItemOptions =
{
  {text = "Berries", data = "berries"},
  {text = "Seeds", data = "seeds"},
  {text = "Honey", data = "honey"},
  {text = "Pomegranate", data = "pomegranate"},
  {text = "Dragonfruit", data = "dragonfruit"},
  {text = "Carrot", data = "carrot"},
  {text = "Corn", data = "corn"},
  {text = "Pumpkin", data = "pumpkin"},
  {text = "Eggplant", data = "eggplant"},
  {text = "Durian", data = "durian"},
  {text = "Fish", data = "fish"},
  {text = "Frog Legs", data = "froglegs"},
  {text = "Mandrake", data = "mandrake"},
  {text = "Butter", data = "butter"},
  {text = "Drumstick", data = "drumstick"},
  {text = "Meat", data = "meat"},
  {text = "Monster Meat", data = "monstermeat"},
  {text = "Morsel", data = "smallmeat"},
  {text = "Tallbird Egg", data = "tallbirdegg"},
  {text = "Taffy", data = "taffy"},
  {text = "Pumpkin Cookie", data = "pumpkincookie"}
}

local objectOptions =
{
  {text = "Rabbit Hole", data = "rabbithole"},
  {text = "Tallbird Nest", data = "tallbirdnest"},
  {text = "Sapling", data = "sapling"},
  {text = "Grass", data = "grass"},
  {text = "Reeds", data = "reeds"},
  {text = "Mound", data = "mound"},
  {text = "Flower", data = "flower"},
  {text = "Marsh Bush", data = "marsh_bush"},
  {text = "Tall Evergreen", data = "evergreen_tall"},
  {text = "Normal Evergreen", data = "evergreen_normal"},
  {text = "Short Evergreen", data = "evergreen_short"},
  {text = "Boulder 1", data = "rock1"},
  {text = "Boulder 2", data = "rock2"},  
  {text = "Gravestone", data = "gravestone"},
  {text = "Bonfire", data = "bonfire"},
  {text = "Beehive", data = "beehive"},
  {text = "Spiderden", data = "spiderden"},
  {text = "Pond", data = "pond"},
  {text = "Marsh Tree", data = "marsh_tree"}, 
  {text = "Fireflies", data = "fireflies"},  
  {text = "Teleport Base", data = "teleportato_base"},
  {text = "Teleport Ring", data = "teleportato_ring"},
  {text = "Teleport Box", data = "teleportato_box"},
  {text = "Teleport Crank", data = "teleportato_crank"},
  {text = "Teleport Potato", data = "teleportato_potato"},
}

local spinnerFont = {font = text_font, size = 30}
local spinnerHeight = 64

local function RetrieveIndices()

	assert(io.input("test_indices"))
	local values = {}
	
	for line in io.lines() do
		table.insert(values, line)
	end
	
	io.input():close()
	
	return values
end

TestScreen = Class(Screen, function(self, in_game)
  Screen._ctor(self, "TestScreen")
  self.in_game = in_game
  TheFrontEnd:DoFadeIn(2)
  local graphicsOptions = TheFrontEnd:GetGraphicsOptions()
  self.options = {
	entityPrefab = nil,
	itemPrefab = nil,
	foodPrefab = nil,
	objectPrefab = nil,
  }

  local indexTable = {}
  if pcall(RetrieveIndices) then
	indexTable = RetrieveIndices()
  end
  
  self.entityIndex = indexTable[1] or 1
  self.itemIndex = indexTable[2] or 1
  self.foodIndex = indexTable[3] or 1
  self.speedIndex = indexTable[4] or 1
  self.objectIndex = indexTable[5] or 1

  self.working = deepcopy(self.options)
  self:DoInit()
  self:InitializeSpinners()
end)
function TestScreen:OnKeyUp(key)
  if key == KEY_ENTER then
    self:Accept()
  elseif key == KEY_ESCAPE then
    self:Close()
  end
end
function TestScreen:Accept()
  self:Save(function()
    self:Close()
  end)
end
function TestScreen:Save(cb)
  self.options = deepcopy(self.working)
  Profile:Save(function()
    if cb then
      cb()
    end
  end)
end
function TestScreen:RevertChanges()
  self:Restore()
end
function TestScreen:Restore()
  self.working = deepcopy(self.options)
  self:Apply()
  self:ApplyAndConfirm(true)
  self:InitializeSpinners()
end

function TestScreen:Apply(force)

end

function TestScreen:Close()

  local file = assert(io.open("test_indices", "w"))
  file:write(self.entitySpinner:GetSelectedIndex(), "\n")
  file:write(self.itemSpinner:GetSelectedIndex(), "\n")
  file:write(self.foodSpinner:GetSelectedIndex(), "\n")
  file:write(self.speedSpinner:GetSelectedIndex(), "\n")
  file:write(self.objectSpinner:GetSelectedIndex(), "\n")
  file:close()
  
  TheFrontEnd:DoFadeIn(2)
  TheFrontEnd:PopScreen()
end
local MakeMenu = function(offset, menuitems)
  local menu = Widget("OptionsMenu")
  local pos = Vector3(0, 0, 0)
  for k, v in ipairs(menuitems) do
    local button = menu:AddChild(AnimButton("button"))
    button:SetPosition(pos)
    button:SetText(v.text)
    button.text:SetColour(0, 0, 0, 1)
    button:SetOnClick(v.cb)
    button:SetFont(BUTTONFONT)
    button:SetTextSize(40)
    pos = pos + offset
  end
  return menu
end
function TestScreen:AddSpinners(data, user_offset, bg_size)
  local master_group = self:AddChild(Widget("SpinnerGroup"))
  master_group:SetVAnchor(ANCHOR_TOP)
  local offset = {
    0,
    0,
    0
  }
  if user_offset then
    offset[1] = offset[1] + user_offset[1]
    offset[2] = offset[2] + user_offset[2]
    offset[3] = offset[3] + user_offset[3]
  end
  master_group:SetPosition(offset[1] + 360, offset[2] + -230, offset[2] + 0)
  local label_width = 200
  for idx, entry in ipairs(data) do
    local text = entry[1]
    local spinner = entry[2]
    local group = master_group:AddChild(Widget("SpinnerGroup"))
    group:SetPosition(0, (idx - 1) * -75 + 25, 0)
    local label = group:AddChild(Text(DEFAULTFONT, 30, text))
    label:SetPosition(0.5 * label_width, 0, 0)
    label:SetRegionSize(label_width, 50)
    label:SetHAlign(ANCHOR_RIGHT)
    group:AddChild(spinner)
    spinner:SetPosition(label_width + 32, 0, 0)
  end
  return master_group
end
function TestScreen:DoInit()
  self.bg = self:AddChild(Image("data/images/bg_main.tex"))
  self.bg:SetVRegPoint(ANCHOR_BOTTOM)
  self.bg:SetHRegPoint(ANCHOR_LEFT)
  local menu_items = {
    {
      text = "Close",
      cb = function()
        self:Accept()
      end
    }
  }
  if self.menu then
    self.menu:Kill()
  end
  local menu_spacing = 60
  local bottom_offset = 70
  local this = self
  
  self.entitySpinner = Spinner(entityOptions, 180, spinnerHeight, spinnerFont, spinner_images)
	  function self.entitySpinner:OnChanged(data)
			this.working.entityPrefab = data
			this:UpdateSelectedEntity()
	  end
  
  self.itemSpinner = Spinner(uncraftableItemOptions, 180, spinnerHeight, spinnerFont, spinner_images)
	  function self.itemSpinner:OnChanged(data)
			this.working.itemPrefab = data
			this:UpdateSelectedItem()
	  end
  
  self.foodSpinner = Spinner(foodItemOptions, 180, spinnerHeight, spinnerFont, spinner_images)
		function self.foodSpinner:OnChanged(data)
			this.working.foodPrefab = data
			this:UpdateSelectedFood()
		end
		
  self.objectSpinner = Spinner(objectOptions, 180, spinnerHeight, spinnerFont, spinner_images)
		function self.objectSpinner:OnChanged(data)
			this.working.objectPrefab = data
			this:UpdateSelectedObject()
		end
	
  self.speedSpinner = NumericSpinner( 2, 10, 50, spinnerHeight, spinnerFont, spinner_images )
  self.speedSpinner.OnChanged =
		function( self, data )
			this:UpdateSpeedMultiplier()
		end 
		
  self.godmodeSpinner = Spinner(enableDisableOptions, 100, spinnerHeight, spinnerFont, spinner_images)
		function self.godmodeSpinner:OnChanged(data)
			--this.working.foodPrefab = data
			this:UpdateGodMode()
		end
	
  local spawning_spinners = {}
  local option_spinners = {}
  local toggle_spinners = {}
  
  local spawn_pos, option_pos, toggle_pos, bg_pos, bg_size

	table.insert(spawning_spinners, { "Entity:", self.entitySpinner })
	table.insert(spawning_spinners, { "Item:", self.itemSpinner })
	table.insert(spawning_spinners, { "Food:", self.foodSpinner })
	table.insert(spawning_spinners, { "Object:", self.objectSpinner })
	
	table.insert(toggle_spinners, { "God Mode:", self.godmodeSpinner })
	
	table.insert(option_spinners, { "Speed Multiplier:", self.speedSpinner })

	spawn_pos = {
	  -225,
	  0,
	  0
	}
	option_pos = {
	  300, -- horizontal; decreasing = left
	  -75, -- vert; increasing = up, dec = down
	  0
	}
	toggle_pos = {
	  225,
	  0,
	  0
	}
	bg_pos = {
	  640,
	  360,
	  0
	}
	bg_size = {1000, 700}

  local bg = self:AddChild(Image("data/images/panel.tex"))
  bg:SetPosition(bg_pos[1], bg_pos[2], bg_pos[3])
  bg:SetSize(bg_size[1], bg_size[2])

  local spawn_group = self:AddSpinners(spawning_spinners, spawn_pos)
  local option_group = self:AddSpinners(option_spinners, option_pos)
  local toggle_group = self:AddSpinners(toggle_spinners, toggle_pos)

  self.soundmenu = self:AddChild(MakeMenu(Vector3(0, -menu_spacing, 0), menu_items))
  self.soundmenu:SetHAnchor(ANCHOR_MIDDLE)
  self.soundmenu:SetPosition(400, bottom_offset + menu_spacing * (#menu_items - 1), 0)

end

local EnabledOptionsIndex = function(enabled)
  if enabled then
    return 2
  else
    return 1
  end
end

local function GodModeIndex()
	local player = TheSim:FindFirstEntityWithTag("player")
	
	if player.components.health:IsInvincible() then
		return 2
	else
		return 1
	end
end

function TestScreen:UpdateSelectedEntity()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.entitySpinner:GetSelected().data then
		player.components.testtoolcontroller.entityPrefab = self.entitySpinner:GetSelectedData()
	end
end

function TestScreen:UpdateSelectedItem()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.itemSpinner:GetSelected().data then
		player.components.testtoolcontroller.itemPrefab = self.itemSpinner:GetSelectedData()
	end
end

function TestScreen:UpdateSelectedFood()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.foodSpinner:GetSelected().data then
		player.components.testtoolcontroller.foodPrefab = self.foodSpinner:GetSelectedData()
	end
end

function TestScreen:UpdateSelectedObject()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.objectSpinner:GetSelected().data then
		player.components.testtoolcontroller.objectPrefab = self.objectSpinner:GetSelectedData()
	end
end

function TestScreen:UpdateSpeedMultiplier()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.speedSpinner:GetSelected() then
		player.components.testtoolcontroller.speed_multiplier = self.speedSpinner:GetSelectedData()
	end
end

function TestScreen:UpdateGodMode()
	local player = TheSim:FindFirstEntityWithTag("player")
	if self.godmodeSpinner:GetSelected() then
		local value = self.godmodeSpinner:GetSelectedData()
		player.components.health:SetInvincible(value)
	end
end

function TestScreen:InitializeSpinners()
  self.entitySpinner:SetSelectedIndex(self.entityIndex)
  self:UpdateSelectedEntity()

  self.itemSpinner:SetSelectedIndex(self.itemIndex)
  self:UpdateSelectedItem()

  self.foodSpinner:SetSelectedIndex(self.foodIndex)
  self:UpdateSelectedFood()
  
  self.objectSpinner:SetSelectedIndex(self.objectIndex)
  self:UpdateSelectedObject()
  
  self.speedSpinner:SetSelectedIndex(self.speedIndex)
  self:UpdateSpeedMultiplier()
  
  self.godmodeSpinner:SetSelectedIndex(GodModeIndex())
  self:UpdateGodMode()
end
