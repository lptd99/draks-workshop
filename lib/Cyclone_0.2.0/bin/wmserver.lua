--wmserver

local wmserver = {}
local wmclient = {}

local windows = {}

local registers = {}
registers.button = {}

local moving = nil
local closing = nil

local mx,my = 0,0
local pmx,pmy = 0,0

local function validateWindow(window)
	if window.surface_boundaries.x < 50 then window:move(50 - window.surface_boundaries.x,0, true) end
	if window.surface_boundaries.y < 50 then window:move(0,50 - window.surface_boundaries.y, true) end
end

function wmserver.triggerEvent(window, event, ...)
	if registers[window] == nil or registers[window][event] == nil then return nil end
	for k,v in pairs(registers[window][event]) do
		v(...)
	end
end

function wmclient.registerWindow(window)
	validateWindow(window)
	windows[window] = 0
end

function wmclient.deleteWindow(window)
	windows[window] = nil
end

function wmclient.changeWindow(oldwindow, newwindow)
	wmserver.triggerEvent(oldwindow, "change", nil)
	windows[oldwindow] = nil
	validateWindow(newwindow)
	windows[newwindow] = 1
end

function wmclient.openWindow(window)
	windows[window] = 1
	wmserver.triggerEvent(window, "open", nil)
end

function wmclient.openName(name)
	for k,v in pairs(windows) do
		if (k.name == name) and (v == 0) then
			wmclient.openWindow(k)
		end
	end
end

function wmclient.minimizeWindow(window)
	windows[window] = 0
	wmserver.triggerEvent(window, "minimize")
end

function wmclient.closeWindow(window)
	windows[window] = 0
	wmserver.triggerEvent(window, "close", nil)
end

function wmclient.registerEvent(window, event, f)
	if registers[window] == nil then registers[window] = {} end
	if registers[window][event] == nil then registers[window][event] = {} end
	table.insert(registers[window][event], f)
end

local function updateControls(window)
	if not window.title_hidden then
		if window.controls_close_boundaries:intersectsPoint(pmx,pmy) then
			if (input.checkMouse("left") == 3) then
				wmclient.closeWindow(window)
			end
			window.controls_close_highlight = 1
		elseif window.controls_minimize_boundaries:intersectsPoint(pmx,pmy) then
			if (input.checkMouse("left") == 3) then
				wmclient.closeWindow(window)
			end
			window.controls_minimize_highlight = 1
		end
	end
end

local function updateButtons(window)
	if window.surface_boundaries:intersectsPoint(mx,my) then
		for _k,_v in pairs(window.body_elements) do
			if tostring(_v) == "Button" and _v.boundaries:intersectsPoint((mx - window.surface_boundaries.x ) * Cyclone.sc - window.panx, (my - window.surface_boundaries.y) * Cyclone.sc - window.pany) then
				_v.highlighted = true
				if input.checkMouse("left") == 3 then
					wmserver.triggerEvent(window, "button", _v.id, _v.name)
				end
			end
		end
	end
end

local function updateMovement()
	if moving == nil then
		if (input.checkMouse("left") == 3) or ((input.checkMouse("middle") == 3) and Cyclone.input.CTRL) then
			for k,v in pairs(windows) do
				if input.checkMouse("middle") == 3 and (not k.lock_pan) then
					if v == 1 and k.surface_boundaries:intersectsPoint(pmx,pmy) then
						moving = k
					end
				else
					if v == 1 and k.title_boundaries:intersectsPoint(pmx,pmy) and not k.title_hidden and (not (k.controls_close_boundaries:intersectsPoint(pmx,pmy) or k.controls_minimize_boundaries:intersectsPoint(pmx,pmy))) then
						moving = k
					end
				end
			end
		elseif ((input.checkMouse("middle") == 3) and not Cyclone.input.CTRL) then
			for k,v in pairs(windows) do
				if (input.checkMouse("middle") == 3) and (v == 1) and k.surface_boundaries:intersectsPoint(pmx,pmy) then
					k:pan(0,0)
				end
			end
		end
	else
		if (input.checkMouse("left") == 0) and (input.checkMouse("middle") == 0) then
			moving = nil
		elseif (input.checkMouse("left") == 2) then
			moving:move(Cyclone.input.dMPOS.x * Cyclone.sc,Cyclone.input.dMPOS.y * Cyclone.sc,true)
		elseif (input.checkMouse("middle") == 2) then
			moving:pan(Cyclone.input.dMPOS.x * Cyclone.sc,Cyclone.input.dMPOS.y * Cyclone.sc,true)
		end
	end
end

function wmserver.update()
	if input.checkKeyboard(Cyclone.options["terminalkey"]) == 3  and (not Cyclone.terminal.custom) then
		if windows[Cyclone.terminal.window] == 0 then
			wmclient.openWindow(Cyclone.terminal.window)
			Cyclone.terminal.activate()
		else
			wmclient.closeWindow(Cyclone.terminal.window)
			Cyclone.terminal.deactivate()
		end
	end

	if Cyclone.launcher then Cyclone.launcher.update(windows) end
	
	pmx, pmy = mx, my
	mx, my = input.getMousePos(true)
	
	for k,v in pairs(windows) do if v == 1 then
		k:update()
		updateControls(k)
		updateButtons(k)
	end end
	updateMovement()
end

wmserver.render = function()
	for k,v in pairs(windows) do if v == 1 then
		k:draw()
	end end
end

export("Cyclone.wmserver", wmserver)
export("Cyclone.wmclient", wmclient)

if not Cyclone.options["no-launcher"] then require("bin/launcher") end