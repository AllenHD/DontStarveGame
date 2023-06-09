--
-- Revised version by WrathOf using msgctxt field for po/t file
-- msgctxt is set to the "path" in the table structure which is guaranteed unique
-- versus the string values (msgid) which are not.
--
-- Added a file format field to the po file so can support old format po files
-- and new format po files.  The new format ones will contain all entries from
-- the strings table which the old format cannot support.
--

require "class"

Translator = Class(function(self) 
	self.languages = {}
	self.defaultlang = nil

	--self.dbfile = io.open("debuglog.txt", "w")
	self.dbfile = nil

end)

--
-- New version
--
function Translator:LoadPOFile(fname,lang)

if self.dbfile then self.dbfile:write("Translator: Loading PO file: "..fname.."\n") end

	local strings = {}
	local file = io.open(fname)
	if not file then print("Translator:LoadPOFile - Specified language file "..fname.." not found.") return end

	local newformat_flag = false
	local current_id = false
	local current_str = ""
	local msgstr_flag = false

	for line in file:lines() do

		--Skip lines until find an id using new format
		if newformat_flag and not current_id then
			local sidx, eidx, c1, c2 = string.find(line, "msgctxt(%s*)\"(%S*)\"")
			if c2 then
				current_id = c2
if self.dbfile then self.dbfile:write("Found new format id: "..tostring(c2).."\n") end
			end
		--Skip lines until find an id using old format (reference field)
		elseif not newformat_flag and not current_id then
			local sidx, eidx, c1, c2 = string.find(line, "%#%:(%s*)(%S*)")
			if c2 then
				current_id = c2
if self.dbfile then self.dbfile:write("Found old format id: "..tostring(c2).."\n") end
			 end
		--Gather up parts of translated text (since POedit breaks it up into 80 char strings)
		elseif msgstr_flag then
			local sidx, eidx, c1, c2 = string.find(line, "(%s*)\"(.*)\"")
			--Found blank line or next entry (assumes blank line after each entry or at least a #. line)
			if not c2 then
				--Store translated text if provided
				if current_str ~= "" then
					strings[current_id] = self:ConvertEscapeCharactersToRaw(current_str)
if self.dbfile then self.dbfile:write("Found id: "..current_id.."\tFound str: "..current_str.."\n") end
				end
				msgstr_flag = false
				current_str = ""
				current_id = false
			--Combine text with previously gathered text
			else
				current_str = current_str..c2
			end
		--Have id, so look for translated text
		elseif current_id then
			local sidx, eidx, c1, c2 = string.find(line, "msgstr(%s*)\"(.*)\"")
			--Found multi-line entry so flag to gather it up
			if c2 and c2 == "" then
				msgstr_flag = true
			--Found translated text so store it
			elseif c2 then
				strings[current_id] = self:ConvertEscapeCharactersToRaw(c2)
if self.dbfile then self.dbfile:write("Found id: "..current_id.."\t\t\t"..c2.."\n") end
				current_id = false
			end
		else
			--skip line
		end

		--Search for new format field if not already found
		if not newformat_flag then
			if string.find(line, "POT Version: 2.0", 0, 1) then newformat_flag = true end
if self.dbfile then self.dbfile:write("Found new file format\n") end
		end

	end

	file:close()

	self.languages[lang] = strings
	self.defaultlang = lang

if self.dbfile then self.dbfile:write("Done!\n") end

end


--
-- Renamed since more generic now
--
function Translator:ConvertEscapeCharactersToString(str)
	local newstr = string.gsub(str, "\n", "\\n")
	newstr = string.gsub(newstr, "\r", "\\r")
	newstr = string.gsub(newstr, "\"", "\\\"")
	
	return newstr
end

function Translator:ConvertEscapeCharactersToRaw(str)
	local newstr = string.gsub(str, "\\n", "\n")
	newstr = string.gsub(newstr, "\\r", "\r")
	newstr = string.gsub(newstr, "\\\"", "\"")
	
	return newstr
end


--
-- New version
--
function Translator:GetTranslatedString(strid, lang)

	lang = lang or self.defaultlang

	if lang and self.languages[lang] then
if self.dbfile then self.dbfile:write("Reqested id: "..strid.."\t\t\t"..tostring(self.languages[lang][strid]).."\n") end
		if self.languages[lang][strid] then
			return self:ConvertEscapeCharactersToRaw(self.languages[lang][strid])
		else
			return nil
		end
	end

	--No translation available so indicate such to caller
	return nil
end

--Recursive function to process table structure
local function DoTranslateStringTable( base, tbl )
	
	for k,v in pairs(tbl) do
		local path = base.."."..k
		if type(v) == "table" then
			DoTranslateStringTable(path, v)
		else
			local str = LanguageTranslator:GetTranslatedString(path)
			if str and str ~= "" then
				tbl[k] = str
			end
		end
	end
end

--called by strings.lua
function TranslateStringTable( tbl )

if LanguageTranslator.dbfile then LanguageTranslator.dbfile:write("Translator: Translating string table....\n") end

	local root = "STRINGS"
	DoTranslateStringTable( root, tbl )

if LanguageTranslator.dbfile then LanguageTranslator.dbfile:close() end

end


LanguageTranslator = Translator()

