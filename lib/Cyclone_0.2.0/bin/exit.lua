--exit

local exit = {}
exit.name = "exit"
exit.call = function()
	Cyclone.terminal.deactivate()
	Cyclone.wmclient.closeWindow(Cyclone.terminal.window)
end
Cyclone.terminal.add(exit)