--item

local item = {}
item.name = "item"

local items = {}
local function refreshItems()
	items = {}
	for k,v in pairs(Cyclone.util.getNamespaces()) do for _k,_v in pairs(Item.findAll(v)) do
		items[_v:getName()] = _v
		items[_v:getName():gsub("%s",'')] = _v
	end end
end
registercallback("onGameStart",refreshItems)

local function listItems()
	for k,v in pairs(items) do Cyclone.terminal.write(k) end
end

local function findItemNames(name)
	if name then
		local _items = {}
		for k,v in pairs(items) do
			if string.find(string.lower(k),string.lower(name)) ~= nil then table.insert(_items,k) end
		end
		return _items
	end
end

local function findItem(name)
	for k,v in pairs(items) do
		if string.find(string.lower(k),string.lower(name)) then return v end
	end
end

item.call = function(args)
	if not args[1] then Cyclone.terminal.write("Commands: list, find, give, remove, fremove.") ; return nil end
	local _count = tonumber(args[3]) or 1
	local _player = misc.players[tonumber(args[4])] or misc.players[1]
	if args[1] == "list" then listItems()
	elseif args[1] == "find" then
		if args[2] then
			for k,v in pairs(findItemNames(args[2])) do
				Cyclone.terminal.write(v)
			end
		end
	elseif args[1] == "give" then
		if args[2] then
			local _item = findItem(args[2])
			if not _item then Cyclone.terminal.write("Item not found.") ; return nil end
			if not _item.isUseItem then _player:giveItem(_item,_count) else _player.useItem = _item end
		else Cyclone.terminal.write("No item specified") end
	elseif (args[1] == "remove") or (args[1] == "fremove") then
		if modloader.checkMod("item-removal-lib") then
			if args[2] then
				local _item = findItem(args[2])
				if (not _item) or (not itemremover.getRemoval(_item)) then Cyclone.terminal.write("Item not found or is missing a removal function.") ; return nil end
				for i=1,_count do
					if itemremover.getRemoval(_item) ~= nil then itemremover.removeItem(_player,_item,(args[1] == "fremove")) end
				end
			else Cyclone.terminal.write("No item specified") end
		else Cyclone.terminal.write("Item remover library not found") end
	elseif args[1] == "rawremove" then
		if args[2] then
			local _item = findItem(args[2])
			if (not _item) then Cyclone.terminal.write("Item not found.") ; return nil end
			_player:removeItem(_item,_count)
		else Cyclone.terminal.write("No item specified") end
	elseif args[1] == "spawn" then
		if args[2] then
			local _pos = Cyclone.pos
			local _item = findItem(args[2])
			if (not _item) then Cyclone.terminal.write("Item not found.") ; return nil end
			local _object = _item:getObject()
			for i=1,_count do _object:create(_pos.x,_pos.y) end
		else Cyclone.terminal.write("No item specified") end
	elseif args[1] == "qspawn" then
		if args[2] then
			local _pos = Cyclone.pos
			local _item = findItem(args[2])
			if (not _item) then Cyclone.terminal.write("Item not found.") ; return nil end
			local _object = _item:getObject()
			for i=1,_count do
				local _instance = _object:create(_pos.x,_pos.y)
				_instance:setAlarm(0, -1)
			end
		else Cyclone.terminal.write("No item specified") end
	else Cyclone.terminal.write("Commands: list, find, give, remove, fremove.") end
end

Cyclone.terminal.add(item)