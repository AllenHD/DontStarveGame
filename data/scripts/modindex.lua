require("mods")


ModIndex = Class(function(self)
	self.savedata =
	{
		known_mods = { },
		known_api_version = 0,
	}
end)
--[[
known_mods = {
	[modname] = {
		enabled = true,
		disabled_bad = true,
		disabled_old = true,
		modinfo = {
			version = "1.2",
			api_version = 2,
			old = true,
			failed = false,
		},
	}
}
--]]

function ModIndex:GetModIndexName()
	local name = "modindex" 
	if BRANCH ~= "release" then
		name = name .. "_"..BRANCH
	end
	return name
end

function ModIndex:Save(callback)
	local newdata = { known_mods = {} }
	newdata.known_api_version = MOD_API_VERSION
	local names = ModManager:GetModNames()
	for i,name in ipairs(names) do
		newdata.known_mods[name] = {}
		if self.savedata.known_mods[name] then
			newdata.known_mods[name].enabled = self.savedata.known_mods[name].enabled
			newdata.known_mods[name].disabled_bad = self.savedata.known_mods[name].disabled_bad
			newdata.known_mods[name].disabled_old = self.savedata.known_mods[name].disabled_old
			newdata.known_mods[name].seen_api_version = MOD_API_VERSION
		end
		newdata.known_mods[name].modinfo = ModManager:GetModInfo(name)
	end

	--print("\n\n---SAVING MOD INDEX---\n\n")
	--dumptable(newdata)
	--print("\n\n---END SAVING MOD INDEX---\n\n")

	local data = DataDumper(newdata, nil, false)
    local insz, outsz = TheSim:SetPersistentString(self:GetModIndexName(), data, ENCODE_SAVES, callback)
end


function ModIndex:Load(callback)

    local filename = self:GetModIndexName()
    TheSim:GetPersistentString(filename,
        function(str) 
			local success, savedata = RunInSandbox(str)
			if success and string.len(str) > 0 then
				self.savedata = savedata
				for k,info in pairs(self.savedata.known_mods) do
					info.was_enabled = info.enabled
				end
				print ("loaded "..filename)
	--print("\n\n---LOADING MOD INDEX---\n\n")
	--dumptable(self.savedata)
	--print("\n\n---END LOADING MOD INDEX---\n\n")
			else
				print ("Could not load "..filename)
			end

			callback()
			--self:VerifyFiles(callback)
        end)    
end

function ModIndex:IsModEnabled(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.enabled
end

-- Note: Installed means enabled + ran in this terminology
function ModIndex:WasModEnabled(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.was_enabled
end

function ModIndex:Disable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:DisableAllMods()
	for i,modname in ipairs(ModManager:GetModNames()) do
		self:Disable(modname)
	end
end

function ModIndex:DisableBecauseBad(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].disabled_bad = true
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:DisableBecauseOld(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].disabled_old = true
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:Enable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].enabled = true
	self.savedata.known_mods[modname].disabled_bad = false
	self.savedata.known_mods[modname].disabled_old = false
end

function ModIndex:IsModNewlyBad(modname)
	local known_mod = self.savedata.known_mods[modname]
	local current_mod_info = ModManager:GetModInfo(modname)
	if known_mod and known_mod.modinfo.failed then
		-- After a mod is disabled it can no longer fail;
		-- in addition, the index is saved when a mod fails.
		-- So we just have to check if the mod failed in the index
		-- and that indicates what happened last time.
		return true
	end
	return false
end

function ModIndex:KnownAPIVersion(modname)
	local known_mod = self.savedata.known_mods[modname]
	if not known_mod or not known_mod.modinfo then
		return -2 -- If we've never seen the mod before, we assume it's REALLY old
	elseif not known_mod.modinfo.api_version then
		return -1 -- If we've seen it but it has no info, it's just "Old"
	else
		return known_mod.modinfo.api_version
	end
end

function ModIndex:CurrentAPIVersion(modname)
	local current_mod_info = ModManager:GetModInfo(modname)
	if not current_mod_info or not current_mod_info.api_version then
		return -1
	else
		return current_mod_info.api_version
	end
end


function ModIndex:IsModNewlyOld(modname)
	if self:CurrentAPIVersion(modname) < MOD_API_VERSION and
			self.savedata.known_mods[modname] and
			self.savedata.known_mods[modname].seen_api_version and
			self.savedata.known_mods[modname].seen_api_version < MOD_API_VERSION then
		return true
	end
	return false
end

function ModIndex:IsModNew(modname)
	return not self.savedata.known_mods[modname] or not self.savedata.known_mods[modname].modinfo
end

function ModIndex:IsModKnownBad(modname)
	return self.savedata.known_mods[modname].disabled_bad
end

function ModIndex:IsModUpdated(modname)
	local known_mod = self.savedata.known_mods[modname]
	local current_mod_info = ModManager:GetModInfo(modname)
	return known_mod and known_mod.modinfo.version ~= current_mod_info.version
end

-- When the user changes settings it messes directly with the index data, so make a backup
function ModIndex:CacheSaveData()
	self.cached_data = deepcopy(self.savedata)
	return self.cached_data
end

-- If the user cancels their mod changes, restore the index to how it was prior the changes.
function ModIndex:RestoreCachedSaveData(ext_data)
	self.savedata = ext_data or self.cached_data
end


KnownModIndex = ModIndex()
