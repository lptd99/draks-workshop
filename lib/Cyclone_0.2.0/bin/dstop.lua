--dstop

local dstop = {}
dstop.name = "dstop"

local stopped = false

dstop.call = function()
	stopped = not stopped
end

registercallback("onStep", function()
	if stopped then
		misc.director:set("points",0)
	end
end)

Cyclone.terminal.add(dstop)