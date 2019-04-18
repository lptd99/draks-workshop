----------------------
-- Keybind Settings --
----------------------

--[[	Texts
	Change these to set the text displayed in various text fields in game
	This does not actually change what button is used, just what text is displayed.
]]
-- Displayed text for swapping consumables "Press '<button>' to ..."
consumable_swap_text = "Q"
-- Displayed text for picking up accessories "Press '<button>' to ..."
accessory_pickup_text = "Q"

--[[	Controls
	
	Edit this to change which bound controls are bound to what actions
	The controls are changed via the in-game keybind menu and should work with both controller and keyboard
	To add multiple controls, add multiple "control" strings, separated by commas, like so:
	{"enter", "swap"}
	
	For a list of controls, see this page: https://saturnyoshi.gitlab.io/RoRML-Docs/global/input.html#input-checkcontrol-control-player
]]
-- Controls for activating a consumable, default uses a key and a controller button instead
local consumable_activate_controls = {}
-- Controls for swapping consumables, by default this uses the same button as swapping use items
local consumable_swap_controls = {"swap"}
-- Controls for picking up accessories, by default this uses the same button as swapping use items
local accessory_pickup_controls = {"swap"}


--[[	Keyboard
	
	Edit this to change which keyboard keys are bound to what actions
	To add multiple keys, add multiple "key" strings, separated by commas, like so:
	{"F", "O", "numpad5"}
]]
-- Keys for activating a consumable, default "F"
local consumable_activate_keys = {"F"}
-- Keys for swapping consumables, by default this uses a control instead
local consumable_swap_keys = {}
-- Keys for picking up accessories, by default this uses a control instead
local accessory_pickup_keys = {}


--[[	Controller
	
	Edit this to change which controller buttons are bound to what actions
	To add multiple buttons, add multiple "button" strings, separated by commas, like so:
	{"padu", "stickr"}
	
	For a list of buttons, see this page: https://saturnyoshi.gitlab.io/RoRML-Docs/global/input.html#input-checkgamepad-button-gamepad
]]
-- Buttons for activating a consumable, default clicking the left stick
local consumable_activate_buttons = {"stickl"}
-- Buttons for swapping consumables, by default this uses a control instead
local consumable_swap_buttons = {}
-- Buttons for picking up accessories, by default this uses a control instead
local accessory_pickup_buttons = {}

-----------------------
-- Keybind functions --
-----------------------

local function checkAll(controls, keys, buttons, player, state)
	for _, control in ipairs(controls) do
		if input.checkControl(control, player) == state then return true end
	end
	for _, key in ipairs(keys) do
		if input.checkKeyboard(key) == state then return true end
	end
	local pad = input.getPlayerGamepad(player)
	if pad then
		for _, button in ipairs(buttons) do
			if input.checkGamepad(button, pad) == state then return true end
		end
	end
	return false
end

function checkActivateConsumable(player, state)
	return checkAll(consumable_activate_controls, consumable_activate_keys, consumable_activate_buttons, player, state)
end

function checkSwapConsumable(player, state)
	return checkAll(consumable_swap_controls, consumable_swap_keys, consumable_swap_buttons, player, state)
end

function checkPickupAccessory(player, state)
	return checkAll(accessory_pickup_controls, accessory_pickup_keys, accessory_pickup_buttons, player, state)
end