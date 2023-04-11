
local function AddModCharacter(name)
	table.insert(MODCHARACTERLIST, name)
end

return {
			AddModCharacter = AddModCharacter,
		}
