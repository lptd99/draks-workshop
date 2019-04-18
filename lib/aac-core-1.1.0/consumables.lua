-----------
-- Setup --
-----------

-- Tables --

local pcon = {}
local touching = {}

local wPickup = Sound.find("Pickup")
local wError = Sound.find("error")

local con_to_item = {}
local item_to_con = {}
local obj_to_item = {}
local con_callbacks = {}
local con_custom_sounds = {}
local con_special_callbacks = {}
local con_special_callback_exceptions = {}
local con_callback_isvalid = {pickup = true, drop = true, step = true, use = true, check = true}
local con_special_callback_isvalid = {onUse = true, postUse = true}
local con_logs = {}

local con_objects = ObjectGroup("consumables")

-- Sprites --

local consumableslot = Sprite.load("Consumable Slot", "ui/consumableslot.png", 1, 0, 0)

-- Functions --

local function fireSpecialCallback(player, consumable, callback)
	if con_special_callbacks[callback] then
		for _, v in ipairs(con_special_callbacks[callback]) do
            v(consumable, player)
        end
	end
end

local function fireConCallback(player, consumable, callback)
    if con_callbacks[consumable][callback] then
        for _, v in ipairs(con_callbacks[consumable][callback]) do
            v(player)
        end
    end
end

local function check(consumable, player)
	for _, v in ipairs(con_callbacks[consumable].check) do
		if not v(player) then return false end
	end
	return true
end

local function activate(consumable, player, keep)
	if not consumable.dontProcSpecial then fireSpecialCallback(player, consumable, "onUse") end
	if not keep then pcon[player] = nil end
	for _, v in ipairs(con_callbacks[consumable].use) do
		v(player, keep)
	end
	if not consumable.dontProcSpecial then fireSpecialCallback(player, consumable, "postUse") end
end

-- Callbacks --

registercallback("onPlayerInit", function(player)
	pcon[player] = nil
end)

registercallback("onGameEnd", function()
    touching = {}
	pcon = {}
end)

registercallback("onPlayerHUDDraw", function(player, x, y)
	consumableslot:draw(x + 122, y - 2, 1)
	if pcon[player] then pcon[player].sprite:draw(x + 134, y + 9, 2) end
end)

registercallback("onPlayerStep", function(player)
	if pcon[player] then
		fireConCallback(player, pcon[player], "step")
	end
	
	if checkActivateConsumable(player, 3) then -- THIS SHOULD BE A BINDING AT SOME POINT MAYBE
		local con = pcon[player]
		if con then
			if check(con, player) then
				activate(con, player, false)
				if con.customSound then con.customSound:play() else wPickup:play() end
			else
				wError:play()
			end
		end
	end
end)

registercallback("postLoad", function()
	for c, args in pairs(con_logs) do
		con_to_item[c]:setLog(args)
	end
end)

registercallback("onStep", function()
	for _, inst in ipairs(con_objects:findAll()) do
	    -- Disables normal pickups
		inst:setAlarm(0, 10)
		local d = inst:get("aac_consumable_delay")
		if d > 0 then
			d = d - 1
			inst:set("aac_consumable_delay", d)
		end
		
		touching[inst] = nil
		
		if inst:get("used") == 0 then -- Don't allow pickups if already picked up
			for _, player in ipairs(misc.players) do
				if inst:collidesWith(player, inst.x, inst.y) then
					if d <= 0 and (not pcon[player] or checkSwapConsumable(player, 3)) then 
						Consumable.give(player, item_to_con[obj_to_item[inst:getObject()]])
						inst:set("used", 1)
						break
					else
						touching[inst] = true
					end
				end
			end
		end
	end
end)

registercallback("onDraw", function()
	for _, inst in ipairs(con_objects:findAll()) do
		if touching[inst] and inst:get("aac_consumable_delay") <= 0 then
			graphics.color(Color.WHITE)
			graphics.printColor("Press &y&'"..consumable_swap_text.."'&!& to swap.", math.floor(inst.x + 0.5 - 56), math.floor(inst.y + 0.5) + 40)
		end
	end
end)

-----------------------------
-- Item instance callbacks --
-----------------------------

local create = function(self)
    touching[self] = nil
	self:set("aac_consumable_delay", 40)
end

local destroy = function(self)
    touching[self] = nil
end

---------------------
-- Consumable Class --
---------------------

local con_mt = {}

Consumable.new, con_mt = newtype("Consumable")

local con_lookup = {
	getObject = function(c)
		return con_to_item[c]:getObject()
	end,
	getName = function(c)
		return con_to_item[c]:getName()
	end,
	getOrigin = function(c)
		return con_to_item[c]:getOrigin()
	end,
	getItem = function(c)
		return con_to_item[c]
	end,
	setLog = function(c, args)
		con_logs[c] = args
	end,
	sprite = {
		get = function(c)
			return con_to_item[c].sprite
		end,
		set = function(c, v)
			con_to_item[c].sprite = v
		end
	},
	dontProcSpecial = {
		get = function(c)
			return not not con_special_callback_exceptions[c]
		end,
		set = function(c, v)
			con_special_callback_exceptions[c] = v
		end
	},
	customSound = {
		get = function(c)
			return con_custom_sounds[c]
		end,
		set = function(c, v)
			con_custom_sounds[c] = v
		end
	},
	pickupText = {
		get = function(c)
			return con_to_item[c].pickupText
		end,
		set = function(c, v)
			con_to_item[c].pickupText = v
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
	addCallback = function(c, name, func)
		if not con_callback_isvalid[name] then
			error("that's not a known callback", 3)
		else
			table.insert(con_callbacks[c][name], func)
		end
    end
}

con_mt.__index = function(t, k)
	local f = con_lookup[k]
	if f then
		if type(f) == "table" then
			return f.get(t)
		else
			return f
		end
	else
		error(string.format("consumable does not contain a field '%s'", tostring(k)), 2)
	end
end
	
con_mt.__newindex = function(t, k, v)
	local f = con_lookup[k]
	if type(f) == "table" then
		f.set(t, v)
	else
		error(string.format("consumable does not contain a field '%s'", tostring(k)), 2)
	end
end
	
con_mt.__init = function(t, name)
    local i = Item("consumable_"..name)
	con_callbacks[t] = {}
	for call, _ in pairs(con_callback_isvalid) do
		con_callbacks[t][call] = {}
	end
	con_to_item[t] = i
	item_to_con[i] = t
	i.isUseItem = true
	i.displayName = name
	
	iobj = i:getObject()
	obj_to_item[iobj] = i
	
	con_objects:add(iobj)
	
    iobj:addCallback("create", create)
    iobj:addCallback("destroy", destroy)
	
    return t
end

----------------------
-- Global functions --
----------------------

Consumable.find = function(name, space)
	return item_to_con[Item.find("consumable_"..name, space)]
end

Consumable.give = function(player, consumable, nodrop)
	if pcon[player] and not nodrop then 
		pcon[player]:getObject():create(player.x, player.y - 16)
		fireConCallback(player, pcon[player], "drop")
	end
	pcon[player] = consumable
	fireConCallback(player, consumable, "pickup")
end

Consumable.get = function(player)
	return pcon[player]
end

-- removes the current consumable the player is holding, or the one in slot 'slot'
Consumable.remove = function(player)
	local ret = pcon[player]
	pcon[player] = nil
	return ret
end

-- activates a consumable for a player, if keep is specified it will not use up the player consumable and if consumable is specified it will activate that one instead of the usual one
Consumable.activate = function(player, keep, consumable)
	activate(player, consumable or pcon[player], keep)
end

-- adds callbacks to onUse and postUse
Consumable.addCallback = function(name, func)
	if not con_special_callback_isvalid[name] then
		error("'"..name.."' is not a valid callback", 3)
	else
		if not con_special_callbacks[name] then
			con_special_callbacks[name] = {}
		end
		table.insert(con_special_callbacks[name], func)
	end
end