-- Globals
Accessory = {}
Consumable = {}

-- Keybinds
require "keybinds"

-- Item Pools

Accessory.pool = ItemPool("Accessories")
Consumable.pool = ItemPool("Consumables")

local accboxsprite = Sprite.load("Accessory Command Box", "ui/accessorycommandbox.png", 1, 12, 16)
local conboxsprite = Sprite.load("Consumable Command Box", "ui/consumablecommandbox.png", 1, 12, 16)

Accessory.pool:getCrate().sprite = accboxsprite
Consumable.pool:getCrate().sprite = conboxsprite

-- APIS

require "accessories"
require "consumables"

export("Accessory")
export("Consumable")