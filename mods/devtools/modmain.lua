--[[
    
***************************************************************
Created by: Jamie Cheng
Date: February 27, 2013
Description: port of the devtools made by clockwork
***************************************************************

]]

local require = GLOBAL.require
require("screens/pausescreen")
require("screens/testscreen")
require("components/testtoolcontroller")

function gamepostinit()
	local PauseScreen = GLOBAL.PauseScreen
	PauseScreen.CreateButtonsPre = PauseScreen.CreateButtons
	PauseScreen.CreateButtons = function(self)
		self:CreateButtonsPre()
		table.insert( PauseScreen.buttons,
			{text = "Test Tools", cb = function() TheFrontEnd:PushScreen(GLOBAL.TestScreen(true)) end } )
	end

	PauseScreen.CreateMenuPre = PauseScreen.CreateMenu
	PauseScreen.CreateMenu = function(self)
		self:CreateMenuPre()
		GLOBAL.AddTestToolController()
	end

end

--add a post init to the sim starting up
AddGamePostInit(gamepostinit)

