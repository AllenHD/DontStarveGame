require "class"

Vector3 = Class(function(self, x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end)

Point = Vector3

function Vector3:__add( rhs )
    return Vector3( self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
end

function Vector3:__sub( rhs )
    return Vector3( self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
end

function Vector3:__mul( rhs )
    return Vector3( self.x * rhs, self.y * rhs, self.z * rhs)
end

function Vector3:__div( rhs )
    return Vector3( self.x / rhs, self.y / rhs, self.z / rhs)
end

function Vector3:Dot( rhs )
    return self.x * rhs.x + self.y * rhs.y + self.z * rhs.z
end

function Vector3:Cross( rhs )
    return Vector3( self.y * rhs.z - self.z * rhs.y,
                    self.z * rhs.x - self.x * rhs.z,
                    self.x * rhs.y - self.y * rhs.x)
end

function Vector3:__tostring()
    return string.format("(%2.2f, %2.2f, %2.2f)", self.x, self.y, self.z) 
end

function Vector3:__eq( rhs )
    return self.x == rhs.x and self.y == rhs.y and self.z == rhs.z
end

function Vector3:LengthSq()
    return self.x*self.x + self.y*self.y + self.z*self.z
end

function Vector3:Length()
    return math.sqrt(self:LengthSq())
end

function Vector3:GetNormalized()
    return self / self:Length()
end

function Vector3:Get()
    return self.x, self.y, self.z
end