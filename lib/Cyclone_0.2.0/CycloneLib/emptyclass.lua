--CycloneLib-é

--Dependencies :
--  


--####################--
-- Meta (var[object]) --
--####################--

local _type = type
local type = function(arg)
	if _type(arg) == "table" and tostring(arg) == "é" then return "é"
	else return _type(arg) end
end

local é = {}
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

mt.__tostring = function() return "é" end


--###############################--
-- Def (def.<keyname> = <value>) --
--###############################--



--##############################################################################--
-- Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>) --
--##############################################################################--



--#######################################################################--
-- Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>) --
--#######################################################################--



--#############--
-- Constructor --
--#############--

function é.new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	return object
end


--#############--
-- MetaMethods --
--#############--



--##########################################################################--
-- Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>) --
--##########################################################################--



--###########--
-- Modloader --
--###########--

export("CycloneLib.é",é)
return é