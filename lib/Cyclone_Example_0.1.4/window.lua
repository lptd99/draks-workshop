--Cyclone_Example_Window

--Creates a window
local window = Cyclone.Window:new()

--Sets the name of the window
window.name = "Sandbox"

--Setting the icon of the window
window.icon = Sprite.load("cyclonesandbox","sandbox.png", 1,8,8)

--Enemygroups and objects
local enemyGroup = ObjectGroup.find("enemies")
local enemyObjects = {}
local objects_obsolete = true
--Refreshing objects and the window when obsolete
local function refresh()
	enemyObjects = {}
	
	--Indexes the table with the objects (which will be the IDs of the button) with the values of the object names (which will be the button names)
	for k,v in pairs(enemyGroup:toList()) do
		enemyObjects[v] = v:getName()
	end
	
	--Makes the menu from the table
	Cyclone.cr.menuFromTable(enemyObjects,window)
end


--Getting the enemies and making the window menu
registercallback("onGameStart", refresh)

--Marking it out of date if the window is closed. (Not minimized)
Cyclone.wmclient.registerEvent(window,"close",function()
	objects_obsolete = true
end)

--Refreshing if obsolete while starting
Cyclone.wmclient.registerEvent(window,"open",function()
	if objects_obsolete then
		refresh()
		objects_obsolete = false
	end
end)

--Registers to the button events of the window
Cyclone.wmclient.registerEvent(window,"button",function(id,name)
	--Gets the Cyclone cursor position
	local x,y = Cyclone.getPos()
	
	--Creates an intance of the object (ID was set to be the object)
	if not pcall(id.create,id,x,y) then
		Cyclone.terminal.write("Error: Couldn't create the object.")
	end
end)

--Registers the window to the WMServer
Cyclone.wmclient.registerWindow(window)