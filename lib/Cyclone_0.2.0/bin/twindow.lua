--twindow

local twindow = {}
twindow.name = "twindow"
twindow.call = function(args)
	if args[1] == "resize" then
		local _w = tonumber(args[2]) or Cyclone.terminal.window.surface_boundaries.w
		local _h = tonumber(args[3]) or Cyclone.terminal.window.surface_boundaries.h
		Cyclone.terminal.window:resize(_w,_h)
		Cyclone.w("Resized window.")
	elseif args[1] == "move" then
		local _x = tonumber(args[2]) or Cyclone.terminal.window.surface_boundaries.x
		local _y = tonumber(args[3]) or Cyclone.terminal.window.surface_boundaries.y
		Cyclone.terminal.window:move(_x,_y)
		Cyclone.w("Moved window.")
	elseif args[1] == "pan" then
		local _x = tonumber(args[2]) or Cyclone.terminal.window.panx
		local _y = tonumber(args[3]) or Cyclone.terminal.window.pany
		Cyclone.terminal.window:pan(_x,_y,args[4] == "relative")
	else Cyclone.w("Sub-command not found.") end
end
Cyclone.terminal.add(twindow)