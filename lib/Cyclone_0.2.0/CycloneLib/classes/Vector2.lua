--CycloneLib-Vector2

--Dependencies :
--  CycloneLib-Util


--####################--
-- Meta (var[object]) --
--####################--

local _type = type
local type = function(arg)
	if _type(arg) == "table" and tostring(arg) == "Vector2" then return "Vector2"
	else return _type(arg) end
end

local Vector2 = {}
local mt = {}
local get = {}
local set = {}
local var = {}
local def = {}
def.__index = def

mt.__index = function(self, key)
	if get[key] ~= nil then return get[key](self) else return var[self][key] end
end

mt.__newindex = function(self, key, value)
	if set[key] ~= nil then set[key](self, value) end
end

mt.__tostring = function() return "Vector2" end


--###############################--
-- Def (def.<keyname> = <value>) --
--###############################--

def.i = 0
def.j = 0


--##############################################################################--
-- Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>) --
--##############################################################################--

get.x = function(self) return var[self].i end
get.y = function(self) return var[self].j end
get.angle = function(self) return self:getAngle() end
get.length = function(self) return self:getLength() end


--#######################################################################--
-- Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>) --
--#######################################################################--

set.x = function(self, value) var[self].i = value end
set.y = function(self, value) var[self].j = value end
set.i = function(self, value) var[self].i = value end
set.j = function(self, value) var[self].j = value end


--#############--
-- Constructor --
--#############--

function Vector2.new(i,j)
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	
	if i then object.i = i end
	if j then object.j = j end
	
	return object
end


--#############--
-- MetaMethods --
--#############--

mt.__unm = function(self)
	local _vector2 = Vector2.new()
	_vector2.i = -var[self].i ; _vector2.j = -var[self].j
	return _vector2
end

mt.__add = function(left, right)
	local _vector2 = Vector2.new()
	if (type(left) == "Vector2") and (type(right) == "Vector2") then
		_vector2.i = var[left].i + var[right].i
		_vector2.j = var[left].j + var[right].j
	end
	return _vector2
end

mt.__sub = function(left, right)
	local _vector2 = Vector2.new()
	if (type(left) == "Vector2") and (type(right) == "Vector2") then
		_vector2.i = var[left].i - var[right].i
		_vector2.j = var[left].j - var[right].j
	end
	return _vector2
end

mt.__mul = function(left, right)
	if (type(left) == "Vector2") then
		if type(right) == "Vector2" then
			return (var[left].i * var[right].i + var[left].j * var[right].j)
		elseif type(right) == "number" then
			local _vector2 = Vector2.new()
			_vector2.i = var[left].i * right
			_vector2.j = var[left].j * right
			return _vector2
		end
	elseif (type(left) == "number") then
		local _vector2 = Vector2.new()
		_vector2.i = var[right].i * left
		_vector2.j = var[right].j * left
		return _vector2
	end
end

mt.__div = function(left, right)
	if (type(left) == "Vector2") then
		if type(right) == "Vector2" then
			return nil
		elseif type(right) == "number" then
			local _vector2 = Vector2.new()
			_vector2.i = var[left].i / right
			_vector2.j = var[left].j / right
			return _vector2
		end
	elseif (type(left) == "number") then
		local _vector2 = Vector2.new()
		_vector2.i = var[right].i / left
		_vector2.j = var[right].j / left
		return _vector2
	end
end

mt.__pow = function(left, right)
	if type(left) == "Vector2" then
		if type(right) == "number" then
			local _vector2 = Vector2.new()
			_vector2.i = var[left].i ^ right
			_vector2.j = var[left].j ^ right
			return _vector2
		elseif type(right) == "Vector2" then
			local _vector2 = Vector2.new()
			_vector2.i = var[left].i ^ var[right].i
			_vector2.j = var[left].j ^ var[right].j
			return _vector2
		end
	else return left end
end


--##########################################################################--
-- Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>) --
--##########################################################################--

--Returns the angle of the vector in degrees counterclockwise.
function def:getAngle()
	return CycloneLib.util.vectorToAngle(var[self].i,var[self].j)
end

--Returns the length of the vecor.
function def:getLength()
	return math.sqrt(var[self].i^2 + var[self].j^2)
end

--Takes the dot product with the given vector.
function def:dot(vector2)
	return self * vector2
end


--###########--
-- Modloader --
--###########--

export("CycloneLib.Vector2",Vector2)
return Vector2