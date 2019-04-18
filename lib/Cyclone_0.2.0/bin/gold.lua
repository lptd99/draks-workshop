--gold

local gold = {}
gold.name = "gold"
gold.call = function(args)
	if args[1] == "get" then
		Cyclone.terminal.write(misc.getGold())
	elseif args[1] == "set" then
		misc.setGold(tonumber(args[2]) or misc.getGold())
	elseif args[1] == "give" or args[1] == "add" then
		misc.setGold(misc.getGold() + (tonumber(args[2]) or 0))
	elseif args[1] == "take" or args[1] == "remove" then
		misc.setGold(misc.getGold() - (tonumber(args[2]) or 0))
	else Cyclone.terminal.write("No such command") end
end
Cyclone.terminal.add(gold)