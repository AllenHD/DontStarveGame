require "class"
require "screens/scripterrorscreen"
require "modutil"
require "prefabs"

MOD_API_VERSION = 2

local function modprint(...)
	--print(unpack(arg))
end

local runmodfn = function(fn,mod,modtype)
	return (function(...)
		if fn then
			local status, r = pcall( fn, unpack(arg) )
			if not status then
				print("error calling "..modtype.." in mod "..mod.modname..": \n"..r)
				ModManager:RemoveBadMod(mod.modname,r)
				ModManager:DisplayBadMods()
			else
				return r
			end
		end
	end)
end

ModWrangler = Class(function(self)
	self.modnames = {}
	self.mods = {}
	self.records = {}
	self.failedmods = {}
	self.oldmods = {}
	self.enabledmods = {}
end)

function ModWrangler:GetModNames()
	return self.modnames
end

function ModWrangler:GetEnabledModNames()
	return self.enabledmods
end

function ModWrangler:GetMod(modname)
	for i,mod in ipairs(self.mods) do
		if mod.modname == modname then
			return mod
		end
	end
end

function ModWrangler:GetModInfo(modname)
	return self:GetMod(modname).modinfo
end

function ModWrangler:SetModRecords(records)
	self.records = records
	for mod,record in pairs(self.records) do
		if table.contains(self.enabledmods, mod) then
			record.active = true
		else
			record.active = false
		end
	end

	for i,mod in ipairs(self.enabledmods) do
		if not self.records[mod] then
			self.records[mod] = {}
			self.records[mod].active = true
		end
	end
end

function ModWrangler:GetModRecords()
	return self.records
end

function CreateEnvironment(modname)

	local modutil = require("modutil")

	local env = 
	{
		TUNING=TUNING,
		CHARACTERLIST = CHARACTERLIST,
		modname = modname,
		prefabpostinits = {},
		componentpostinits = {},
		pairs = pairs,
		ipairs = ipairs,
		print = print,
		math = math,
		table = table,
		type = type,
		string = string,
		tostring = tostring,
		Class = Class,
		GLOBAL = _G,
		MODROOT = "mods/"..modname.."/",
		Prefab = Prefab,
		Asset = Asset,

		-- modutil
		AddModCharacter = modutil.AddModCharacter
	}

	env.env = env

	--install our crazy loader!
	env.modimport = function(modulename)
		print("modimport: "..env.MODROOT..modulename)
        local result = kleiloadlua(env.MODROOT..modulename)
		if type(result) == "string" then
			error("Error in modimport: "..modname.."!\n"..result)
		else
        	setfenv(result, env.env)
            result()
        end
	end

	env.AddPrefabPostInit = function(prefabname, fn)
		--print("adding post init for prefab: "..prefabname)
		env.prefabpostinits[prefabname] = fn
	end

	env.AddComponentPostInit = function(componentname, fn)
		env.componentpostinits[componentname] = fn
	end

	env.AddGamePostInit = function(fn)
		env.gamepostinit = fn
	end

	env.AddSimPostInit = function(fn)
		env.simpostinit = fn
	end

	return env
end

function ModWrangler:LoadMods(modlist, skipmenuassets)

	skipmenuassets = skipmenuassets or false

	local moddirs = modlist
	if not moddirs then
		moddirs = TheSim:GetModDirectoryNames()
	end

	local modinfoassets = {}

	for i,modname in ipairs(moddirs) do
		modprint("Found mod "..modname)
		table.insert(self.modnames, modname)

		local initenv = {}
		local didInit = self:InitializeModInfo(modname, initenv)
		local env = CreateEnvironment(modname)
		env.modinfo = initenv
		table.insert( self.mods, env )

		if not didInit then
			if initenv.old and KnownModIndex:IsModNewlyOld(modname) then
				modprint("  It's using an old api_version.")
				KnownModIndex:DisableBecauseOld(modname)
			elseif initenv.failed then
				modprint("  But there was an error loading it.")
				KnownModIndex:DisableBecauseBad(modname)
			else
				-- we've already "dealt" with this in the past; if the user
				-- chooses to enable it, then try loading it!
			end
		end

		if env.modinfo.icon and env.modinfo.icon_atlas then
			table.insert(modinfoassets, Asset("ATLAS", "mods/"..env.modname.."/"..env.modinfo.icon_atlas))
			table.insert(modinfoassets, Asset("IMAGE", "mods/"..env.modname.."/"..env.modinfo.icon))
		end

	end

	-- Sort the mods by priority, so that "library" mods can load first
	local function modPrioritySort(a,b)
		local apriority = (a.modinfo and a.modinfo.priority) or 0
		local bpriority = (b.modinfo and b.modinfo.priority) or 0
		return apriority > bpriority
	end
	table.sort(self.mods, modPrioritySort)

	for i,mod in ipairs(self.mods) do
		if KnownModIndex:IsModEnabled(mod.modname) then
			table.insert(self.enabledmods, mod.modname)
			package.path = "mods\\"..mod.modname.."\\scripts\\?.lua;"..package.path
			self:InitializeModMain(mod.modname, mod)
		else
			modprint("  ... and it's disabled.")
		end
	end

	if not skipmenuassets then
		RegisterPrefabs( Prefab("modbaseprefabs/MODSCREEN", nil, modinfoassets, nil) )
		TheSim:LoadPrefabs({"MODSCREEN"})
	end

end

local RunUntrusted = function(fn,env)
	setfenv(fn, env)
	return pcall(fn)
end

function ModWrangler:InitializeModInfo(modname, env)
	local fn = kleiloadlua("mods/"..modname.."/modinfo.lua")
	if type(fn) == "string" then
		print("Error loading mod: "..modname.."!\n"..fn)
		table.insert( self.failedmods, {name=modname,error=fn} )
		env.failed = true
		return false
	elseif not fn then
		print("Warning loading mod: "..modname.."! Could not find modinfo.lua")
		table.insert( self.oldmods, {name=modname,error="Cannot find modinfo.lua for mod "..modname} )
		env.old = true
		return false
	else
		local status, r = RunUntrusted(fn,env)

		if status == false then
			print("Error loading mod: "..modname.."!\n"..r)
			table.insert( self.failedmods, {name=modname,error=r} )
			env.failed = true
			return false
		elseif env.api_version == nil or env.api_version < MOD_API_VERSION then
			local old = "Mod "..modname.." was built for an older version of the game and requires updating. (api_version is version "..tostring(env.api_version)..", game is version "..MOD_API_VERSION..".)"
			print("Warning loading mod: "..modname.."!\n"..old)
			table.insert( self.oldmods, {name=modname,error=old} )
			env.old = true
			return false
		elseif env.api_version > MOD_API_VERSION then
			local old = "api_version for "..modname.." is in the future, please set to the current version. (api_version is version "..env.api_version..", game is version "..MOD_API_VERSION..".)"
			print("Error loading mod: "..modname.."!\n"..old)
			table.insert( self.failedmods, {name=modname,error=old} )
			env.failed = true
			return false
		else
			local checkinfo = { "name", "description", "author", "version", "forumthread", "api_version" }
			local missing = {}
			for i,v in ipairs(checkinfo) do
				if env[v] == nil then
					table.insert(missing, v)
				end
			end
			if #missing > 0 then
				local e = "Error loading modinfo.lua. These fields are required: " .. table.concat(missing, ", ")
				print (e)
				table.insert( self.failedmods, {name=modname,error=e} )
				env.failed = true
				return false
			else
				-- the env is an "out reference" so we're done here.
				return true
			end
		end
	end
end

function ModWrangler:InitializeModMain(modname, env)
	print("Loading modmain for "..modname)

	local fn = kleiloadlua("mods/"..modname.."/modmain.lua")
	if type(fn) == "string" then
		print("Error loading mod: "..modname.."!\n"..fn)
		table.insert( self.failedmods, {name=modname,error=fn} )
		return false
	elseif not fn then
		print("Mod "..modname.." had no modmain.lua. Skipping.")
		return true
	else
		local status, r = RunUntrusted(fn,env)

		if status == false then
			print("Error loading mod: "..modname.."!\n"..r)
			table.insert( self.failedmods, {name=modname,error=r} )
			return false
		else
			-- the env is an "out reference" so we're done here.
			return true
		end
	end
end

function ModWrangler:RemoveBadMod(badmodname,error)
	KnownModIndex:DisableBecauseBad(badmodname)

	table.insert( self.failedmods, {name=badmodname,error=error} )
end

function ModWrangler:DisplayBadMods()
	-- If the frontend isn't ready yet, just hold onto this until we can display it.

	if #self.failedmods > 0 then
		for i,failedmod in ipairs(self.failedmods) do
			KnownModIndex:DisableBecauseBad(failedmod.name)
			self:GetMod(failedmod.name).modinfo.failed = true
			print("Disabling",failedmod.name, "because it had an error.")
		end
		KnownModIndex:Save()
	end

	if TheFrontEnd then
		for k,badmod in ipairs(self.failedmods) do
			TheFrontEnd:PushScreen(
				ScriptErrorScreen(
					STRINGS.UI.MAINSCREEN.MODFAILTITLE, 
					STRINGS.UI.MAINSCREEN.MODFAILDETAIL.." "..badmod.name.."\n"..badmod.error.."\n",
					{
						{text=STRINGS.UI.MAINSCREEN.SCRIPTERRORQUIT, cb = function() TheSim:ForceAbort() end},
						{text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/forumdisplay.php?63-Don-t-Starve-Mods-and-tools") end }
					},
					ANCHOR_LEFT,
					STRINGS.UI.MAINSCREEN.MODFAILDETAIL2,
					20
					))
		end
		self.failedmods = {}
	end
end

function ModWrangler:RegisterPrefabs()
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)

		mod.LoadPrefabFile = LoadPrefabFile
		mod.RegisterPrefabs = RegisterPrefabs
		mod.Prefabs = {}



		print("Registering prefabs for "..mod.modname)

		-- We initialize the prefabs in the sandbox and collect all the created prefabs back
		-- into the main world.
		if mod.PrefabFiles then
			for i,prefab_path in ipairs(mod.PrefabFiles) do
				print("  Registering "..mod.modname.." prefab: "..prefab_path)
				local ret = runmodfn( mod.LoadPrefabFile, mod, "LoadPrefabFile" )("prefabs/"..prefab_path)
				if ret then
					for i,prefab in ipairs(ret) do
						mod.Prefabs[prefab.name] = prefab
					end
				end
			end
		end

		local prefabnames = {}
		for name, prefab in pairs(mod.Prefabs) do
			table.insert(prefabnames, name)
			Prefabs[name] = prefab -- copy the prefabs back into the main environment
		end

		print("  Registering default mod prefab for "..mod.modname)

		RegisterPrefabs( Prefab("modbaseprefabs/MOD_"..mod.modname, nil, mod.Assets, prefabnames) )

		TheSim:LoadPrefabs({"MOD_"..mod.modname})
	end
end

function ModWrangler:SetPostEnv()

	local moddetail = ""

	--print("\n\n---MOD INFO SCREEN---\n\n")

	local modnames = ""
	local newmodnames = ""
	local oldmodnames = ""
	local failedmodnames = ""

	if #self.mods > 0 then
		for i,mod in ipairs(self.mods) do
			modprint("###"..mod.modname)
			--dumptable(mod.modinfo)
			if KnownModIndex:IsModNewlyBad(mod.modname) then
				modprint("@NEWLYBAD")
				failedmodnames = failedmodnames.."\""..mod.modname.."\" "
			elseif KnownModIndex:IsModNewlyOld(mod.modname) and KnownModIndex:WasModEnabled(mod.modname) then
					modprint("@NEWLYOLD")
					oldmodnames = oldmodnames.."\""..mod.modname.."\" "
				--elseif KnownModIndex:IsModNew(mod.modname) then
					--print("@NEW")
					--newmodnames = newmodnames.."\""..mod.modname.."\" "
				--end
			elseif KnownModIndex:IsModEnabled(mod.modname) then
				modprint("@ENABLED")
				mod.TheFrontEnd = TheFrontEnd
				mod.Text = Text
				mod.TheSim = TheSim
				mod.Point = Point
				mod.TheGlobalInstance = TheGlobalInstance

				runmodfn( mod.gamepostinit, mod, "gamepostinit" )()
	
				modnames = modnames.."\""..mod.modname.."\" "
			else
				modprint("@DISABLED")
			end
		end
	end

	--print("\n\n---END MOD INFO SCREEN---\n\n")

	if oldmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.OLDMODS.." "..oldmodnames.."\n"
	end
	if failedmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.FAILEDMODS.." "..failedmodnames.."\n"
	end

	if oldmodnames ~= "" or failedmodnames ~= "" then
		moddetail = moddetail..STRINGS.UI.MAINSCREEN.OLDORFAILEDMODS.."\n\n"
	end

	if newmodnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.NEWMODDETAIL.." "..newmodnames.."\n"..STRINGS.UI.MAINSCREEN.NEWMODDETAIL2.."\n\n"
	end
	if modnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL.." "..modnames.."\n\n"
	end
	if newmodnames ~= "" or modnames ~= "" then
		moddetail = moddetail.. STRINGS.UI.MAINSCREEN.MODDETAIL2.."\n\n"
	end

	if (modnames ~= "" or newmodnames ~= "" or oldmodnames ~= "" or failedmodnames ~= "")  and TheSim:ShouldWarnModsLoaded() then
	--if (#self.enabledmods > 0)  and TheSim:ShouldWarnModsLoaded() then
		TheFrontEnd:PushScreen(
			ScriptErrorScreen(
				STRINGS.UI.MAINSCREEN.MODTITLE, 
				moddetail,
				{
					{text=STRINGS.UI.MAINSCREEN.TESTINGYES, cb = function() end},
					{text=STRINGS.UI.MAINSCREEN.MODQUIT, cb = function()
																	KnownModIndex:DisableAllMods()
																	KnownModIndex:Save(function()
																		TheSim:Reset()
																	end)
																end},
					{text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/forumdisplay.php?54-Don-t-Starve-Beta-Mods-amp-Tools") end }
				}))
	end

	self:DisplayBadMods()

end

function ModWrangler:SimPostInit(wilson)
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		runmodfn( mod.simpostinit, mod, "simpostinit" )(wilson)
	end

	self:DisplayBadMods()
end

function ModWrangler:GetPrefabPostInitFns(prefabname) 
	local modfns = {}
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		local modfn = mod.prefabpostinits[prefabname]
		if modfn ~= nil then
			--print("added mod init for "..prefabname)
			table.insert(modfns, runmodfn(modfn, mod, prefabname.." post init"))
		end
	end
	return modfns
end

function ModWrangler:GetComponentPostInitFns(componentname) 

	local modfns = {}
	for i,modname in ipairs(self.enabledmods) do
		local mod = self:GetMod(modname)
		local modfn = mod.componentpostinits[componentname]
		if modfn ~= nil then
			table.insert(modfns, runmodfn(modfn, mod, componentname.." post init"))
		end
	end
	return modfns
end

ModManager = ModWrangler()

---------------------------------------------

--local filename = "mods/modsettings.lua"
--local fn = kleiloadlua( filename )
--assert(fn, "could not load modsettings: "..filename)
--fn()
