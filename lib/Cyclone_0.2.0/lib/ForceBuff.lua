--ForceBuff

--	Meta (var[object])

local ForceBuff = {}
local mt = {}
local get = {}
local set = {}
local var = {}
local def = {}
def.__index = def

--Instances
local objects = {}

mt.__index = function(self, key)
	if get[key] ~= nil then return get[key](self) else return var[self][key] end
end

mt.__newindex = function(self, key, value)
	if set[key] ~= nil then set[key](self, value) end
end

mt.__tostring = function() return "ForceBuff" end

--	Def (def.<keyname> = <value>)

def.prefix = "ForceBuff_"
def.suffix_clock = "_clock"
def.name = ""
def.duration = 0
def.callbacks = nil
def.sprite = nil
def.climb = 0

--	Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>)



--	Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>)

set.name = function(self, value) var[self].name = value end
set.duration = function(self, value) var[self].duration = value end
set.sprite = function(self, value) var[self].sprite = value end
set.climb = function(self, value) var[self].climb = value end

--	Constructor

function ForceBuff:new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	table.insert(objects, object)
	return object
end

--	Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>)

function def:addCallback(name, f)
	if not type(f) == "function" then return nil end
	if var[self].callbacks == nil then var[self].callbacks = {} end
	if var[self].callbacks[name] == nil then var[self].callbacks[name] = {} end
	table.insert(var[self].callbacks[name], f)
end

function def:triggerCallback(name, parameter)
	if var[self].callbacks ~= nil and var[self].callbacks[name] ~= nil then
		for k,v in pairs(var[self].callbacks[name]) do
			v(parameter)
		end
	end
end

function def:setTimer(i, t)
	if i:isValid() then
		i:set(def.prefix..var[self].name..def.suffix_clock, t)
	end
end

function def:applyTo(i, duration)
	local _duration = duration or var[self].duration
	if i:isValid() then
		i:set(def.prefix..var[self].name, 1)
		self:setTimer(i, _duration)
		self:triggerCallback("start", i)
	end
end

function def:removeFrom(i)
	if i:isValid() then
		self:setTimer(i, nil)
		i:set(def.prefix..var[self].name, nil)
	end
end

function def:has(i)
	return (i:isValid()) and (i:get(var[self].prefix..var[self].name) == 1)
end

function def:getTimer(i)
	if i:isValid() and self:has(i) then
		return i:get(var[self].prefix..var[self].name..var[self].suffix_clock)
	end
end

--	Modloader

local range = ObjectGroup.find("actors")

registercallback("onStep", function()
	for _,buff in pairs(objects) do
		for k,v in pairs(range:findAll()) do
			if (v:isValid()) and (buff:has(v)) then
				buff:setTimer(v, buff:getTimer(v) - 1)
				if buff:getTimer(v) <= 0 then
					buff:removeFrom(v)
					buff:triggerCallback("end", v)
				else
					buff:triggerCallback("step", v)
				end
			end
		end
	end
end)

registercallback("onDraw", function()
	for k,v in pairs(range:findAll()) do
		if v:isValid() then
			local _buffcount = 0
			for _,buff in pairs(objects) do if buff:has(v) then
				buff:triggerCallback("draw", v)
				if buff.sprite ~= nil then
					graphics.drawImage{
						image = buff.sprite,
						subimage = 1,
						x = v.x,
						y = v.y - (v.mask.height or v.sprite.height)/2 - 10 - buff.climb - 16 * _buffcount,
					}
				end
				_buffcount = _buffcount + 1
			end end
		end
	end
end)

if modloader.getActiveNamespace() == "Cyclone" then export("Cyclone.ForceBuff",ForceBuff) end
return ForceBuff