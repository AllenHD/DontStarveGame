local KnownLocations = Class(function(self, inst)
    self.inst = inst
    self.locations = {}
end)

function KnownLocations:GetDebugString()
    local str = ""
    for k,v in pairs(self.locations) do
        str = str..string.format("%s: %s ", k, tostring(v))
    end
    return str
end

function KnownLocations:RememberLocation(name, pos)
    self.locations[name] = pos
end

function KnownLocations:GetLocation(name)
    return self.locations[name] 
end

function KnownLocations:ForgetLocation(name)
    self.locations[name] = nil
end

return KnownLocations
