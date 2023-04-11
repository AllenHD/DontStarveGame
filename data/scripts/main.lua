--defines
MAIN = 1
ENCODE_SAVES = BRANCH ~= "dev"
CHEATS_ENABLED = BRANCH == "dev"
SOUNDDEBUG_ENABLED = false

debug.setmetatable(nil, {__index = function() return nil end})  -- Makes  foo.bar.blat.um  return nil if table item not present   See Dave F or Brook for details

local servers = 
{
	release = "http://dontstarve-release.appspot.com",
	dev = "http://dontstarve-dev.appspot.com",
	staging = "http://dontstarve-staging.appspot.com",
}
GAME_SERVER = servers[BRANCH]


TheSim:SetReverbPreset("default")

if PLATFORM == "NACL" then
	VisitURL = function(url, notrack)
		if notrack then
			TheSim:SendJSMessage("VisitURLNoTrack:"..url)
		else
			TheSim:SendJSMessage("VisitURL:"..url)
		end
	end
end

if PLATFORM == "WIN32" then
	--this is done strangely, because we statically link to luasocket. We statically link to lusocket because we statically link to lua. We statically link to lua because of NaCl. Boo.
	--anyway, you should be able to use luasocket as you would expect from this point forward (on windows at least).
	dofile("data/scriptlibs/socket.lua")
	dofile("data/scriptlibs/mime.lua")
end

--used for A/B testing and preview features. Gets serialized into and out of save games
GameplayOptions = 
{
}


--install our crazy loader!
local loadfn = function(modulename)
	--print (modulename, package.path)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch(package.path, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        filename = string.gsub(filename, "\\", "/")
        local result = kleiloadlua(filename)
        if result then
            return result
        end
        errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
  return errmsg    
end
table.insert(package.loaders, 1, loadfn)

--patch this function because NACL has no fopen
if TheSim then
    function loadfile(filename)
        filename = string.gsub(filename, ".lua", "")
        filename = string.gsub(filename, "data/scripts/", "")
        return loadfn(filename)
    end
end

if PLATFORM == "NACL" then
    package.loaders[2] = nil
elseif PLATFORM == "WIN32" then
end

require("strict")


require("mainfunctions")


--TheSim:UnloadAllPrefabs()
require("mods")
require("json")
require("vector3")
require("tuning")
require("languages/language")
require("strings")
require("stringutil")
require("constants")
require("class")
require("actions")
require("debugtools")
require("simutil")
require("util")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("entityscript")
require("profiler")
require("recipes")
require("brain")
require("emitters")
require("dumper")
require("input")
require("upsell")
require("stats")
require("frontend")
require("overseer")
require("fileutil")
require("screens/scripterrorscreen")
require("prefablist")

require("widget")
require("image")
require("text")
require("textedit")
require("standardcomponents")
require("cameras\\followcamera")
require("update")
require("fonts")
require("physics")
require("modindex")

print ("running main.lua\n")

VERBOSITY_LEVEL = VERBOSITY.ERROR
if CONFIGURATION ~= "Production" then
	VERBOSITY_LEVEL = VERBOSITY.DEBUG
end

-- uncomment this line to override
VERBOSITY_LEVEL = VERBOSITY.WARNING

math.randomseed(TheSim:GetRealTime())

TheCamera = FollowCamera()

--instantiate the mixer
local Mixer = require("mixer")
TheMixer = Mixer.Mixer()
require("mixes")
TheMixer:PushMix("start")

KnownModIndex:Load(function() end)

---PREFABS AND ENTITY INSTANTIATION
Prefabs = {}

ModManager:LoadMods()

-- Register every standard prefab with the engine
for i,file in ipairs(PREFABFILES) do -- required from prefablist.lua
	LoadPrefabFile("prefabs/"..file)
end

ModManager:RegisterPrefabs()

Ents = {}
AwakeEnts = {}
UpdatingEnts = {}
NewUpdatingEnts = {}
num_updating_ents = 0
NumEnts = 0


--- GLOBAL ENTITY ---
TheGlobalInstance = CreateEntity()
TheGlobalInstance.entity:SetCanSleep( false )
TheGlobalInstance.entity:AddTransform()

TheSim:LoadPrefabs({"global"})

SplatManager = TheGlobalInstance.entity:AddSplatManager()
ShadowManager = TheGlobalInstance.entity:AddShadowManager()
ShadowManager:SetTexture( "data/images/shadow.tex" )
RoadManager = TheGlobalInstance.entity:AddRoadManager()
EnvelopeManager = TheGlobalInstance.entity:AddEnvelopeManager()

PostProcessor = TheGlobalInstance.entity:AddPostProcessor()
local IDENTITY_COLOURCUBE = "data/images/colour_cubes/identity_colourcube.tex"
PostProcessor:SetColourCubeData( 0, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )
PostProcessor:SetColourCubeData( 1, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )

FontManager = TheGlobalInstance.entity:AddFontManager()
MapLayerManager = TheGlobalInstance.entity:AddMapLayerManager()
Roads = nil
TheFrontEnd = nil
LoadFonts()

