local function getcharacterstring(tab, item, modifier)
    if modifier then
		modifier = string.upper(modifier)
	end

    if tab then
        local topic_tab = tab[item]
        if topic_tab then
            if type(topic_tab) == "string" then
		        return topic_tab
            elseif type(topic_tab) == "table" then
                if modifier and topic_tab[modifier] then
                    return topic_tab[modifier]
                end

                if topic_tab['GENERIC'] then
                    return topic_tab['GENERIC']
                end

				if #topic_tab > 0 then
					return topic_tab[math.random(#topic_tab)]
				end
            end
        end
    end
end


function GetSpecialCharacterString(character)
    character = string.lower(character)
    if character == "wilton" then

		local sayings =
		{
			"Ehhhhhhhhhhhhhh.",
			"Eeeeeeeeeeeer.",
			"Rattle.",
			"click click click click",
			"Hissss!",
			"Aaaaaaaaa.",
			"mooooooooooooaaaaan.",
			"...",
		}

		return sayings[math.random(#sayings)]
    elseif character == "wes" then
		return ""
    --else
		--print (character)
    end
end



function GetString(character, stringtype, modifier)
    character = character and string.upper(character)
    stringtype = stringtype and string.upper(stringtype)
    modifier = modifier and string.upper(modifier)
    
    local ret = GetSpecialCharacterString(character) or
			    getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier) or
                getcharacterstring(STRINGS.CHARACTERS["GENERIC"], stringtype, modifier)
    if ret then
        return ret
    end

    return "UNKNOWN STRING: "..( character or "") .." ".. (stringtype or "") .." ".. (modifier or "")

end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

function GetDescription(character, item, modifier)
    character = character and string.upper(character)
    item = item and string.upper(item)
    modifier = modifier and string.upper(modifier)

    local ret = GetSpecialCharacterString(character)

    if not ret and STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, item, modifier)
    end

    if not ret then
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, item, modifier)
    end

    if ret then
       return ret
    end
    return STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
end

function GetActionFailString(character, action, reason)
    local ret = nil

	local ret = GetSpecialCharacterString(character)
	if ret then
		return ret
	end

    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason)
    end

    if not ret then
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
    end

    if ret then
       return ret
    end
    return STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end
