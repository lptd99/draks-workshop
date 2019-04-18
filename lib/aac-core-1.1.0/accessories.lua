-----------
-- Setup --
-----------

-- Tables --

local pacc = {}
local touching = {}

local acc_to_item = {}
local item_to_acc = {}
local obj_to_item = {}
local acc_callbacks = {}
local acc_callback_isvalid = {pickup = true, drop = true, step = true}
local acc_logs = {}

local acc_objects = ObjectGroup("accessories")

-- Sprites --

local accessoryslot = Sprite.load("Accessory Slot", "ui/accessoryslot.png", 1, 0, 0)

-- Functions --

local function fireAccCallback(player, accessory, callback)
    if acc_callbacks[accessory][callback] then
        for _, v in ipairs(acc_callbacks[accessory][callback]) do
            v(player)
        end
    end
end

-- Callbacks --

registercallback("onPlayerInit", function(player)
	pacc[player] = nil
end)

registercallback("onGameEnd", function(player)
    touching = {}
	pacc = {}
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
	accessoryslot:draw(x - 66, y - 8, 1)
	if pacc[player] then pacc[player].sprite:draw(x - 52, y + 6, 1) end
end)

registercallback("onPlayerStep", function(player)
	if pacc[player] then
		fireAccCallback(player, pacc[player], "step")
	end
end)

registercallback("postLoad", function()
	for a, args in pairs(acc_logs) do
		acc_to_item[a]:setLog(args)
	end
end)

registercallback("onStep", function()
	for _, inst in ipairs(acc_objects:findAll()) do
		-- Disables normal pickups
		inst:setAlarm(0, 10)
		
		touching[inst] = nil
		
		if inst:get("used") == 0 then -- Don't allow pickups if already picked up
			for _, player in ipairs(misc.players) do
				if not pacc[player] and inst:collidesWith(player, inst.x, inst.y) then
					if checkPickupAccessory(player, 1) then
						Accessory.give(player, item_to_acc[obj_to_item[inst:getObject()]])
						inst:set("used", 1)
						break
					else
						-- This makes sure the correct button for pickup is displayed in the pickup text
						touching[inst] = player
					end
				end
			end
		end
	end
end)

registercallback("onDraw", function()
	for _, inst in ipairs(acc_objects:findAll()) do
		if touching[inst] then
			graphics.color(Color.WHITE)
			graphics.printColor("Press &y&'"..accessory_pickup_text.."'&!& to pick up.", math.floor(inst.x + 0.5 - 56), math.floor(inst.y + 0.5) + 40)
		end
	end
end)

-----------------------------
-- Item instance callbacks --
-----------------------------

local create = function(self)
    touching[self] = nil
end

local destroy = function(self)
    touching[self] = nil
end

---------------------
-- Accessory Class --
---------------------

local acc_mt = {}

Accessory.new, acc_mt = newtype("Accessory")

local acc_lookup = {
	getObject = function(a)
		return acc_to_item[a]:getObject()
	end,
	getName = function(c)
		return con_to_item[c]:getName()
	end,
	getOrigin = function(c)
		return con_to_item[c]:getOrigin()
	end,
	getItem = function(a)
		return acc_to_item[a]
	end,
	setLog = function(a, args)
		acc_logs[a] = args
	end,
	sprite = {
		get = function(a)
			return acc_to_item[a].sprite
		end,
		set = function(a, v)
			acc_to_item[a].sprite = v
		end
	},
	pickupText = {
		get = function(a)
			return acc_to_item[a].pickupText
		end,
		set = function(a, v)
			acc_to_item[a].pickupText = v
		end
	},
	displayName = {
		get = function(c)
			return con_to_item[c].displayName
		end,
		set = function(c, v)
			con_to_item[c].displayName = v
		end
	},
	addCallback = function(a, name, func)
		if not acc_callback_isvalid[name] then
			error("that's not a known callback", 3)
		else
			table.insert(acc_callbacks[a][name], func)
		end
    end
}

acc_mt.__index = function(t, k)
	local f = acc_lookup[k]
	if f then
		if type(f) == "table" then
			return f.get(t)
		else
			return f
		end
	else
		error(string.format("accessory does not contain a field '%s'", tostring(k)), 2)
	end
end

acc_mt.__newindex = function(t, k, v)
	local f = acc_lookup[k]
	if type(f) == "table" then
		f.set(t, v)
	else
		error(string.format("accessory does not contain a field '%s'", tostring(k)), 2)
	end
end

acc_mt.__init = function(t, name)
	local i = Item("accessory_"..name)
	acc_callbacks[t] = {}
	for call, _ in pairs(acc_callback_isvalid) do
		acc_callbacks[t][call] = {}
	end
	acc_to_item[t] = i
	item_to_acc[i] = t
	i.displayName = name
	
	iobj = i:getObject()
	obj_to_item[iobj] = i
	
	acc_objects:add(iobj)
	
	iobj:addCallback("create", create)
	iobj:addCallback("destroy", destroy)
	
	return t
end

----------------------
-- Global functions --
----------------------

Accessory.find = function(name)
	return item_to_acc[Item.find("accessory_"..name)]
end

-- Gives the player a new accessory. Replace can be specified to make the old accessory not drop.
Accessory.give = function(player, accessory, nodrop)
	if pacc[player] and nodrop then 
		pacc[player]:getObject():create(player.x, player.y - 16)
		fireAccCallback(player, pacc[player], "drop")
	end
	pacc[player] = accessory
	fireAccCallback(player, accessory, "pickup")
end

-- Gets the accessory at slot
Accessory.get = function(player)
	return pacc[player]
end

-- removes an accessory from the player
Accessory.remove = function(player)
	local ret = pacc[player]
	pacc[player] = nil
	return ret
end