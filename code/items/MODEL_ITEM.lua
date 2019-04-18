-- MODEL ITEM

-- Please use underscore_notation when naming anything with more than two words.

-- Creating new item
local model_item = Item("[MODEL ITEM]")
-- Setting its pickup text in-game
model_item.pickupText = "[PICKUP TEXT]"
-- Setting its sprite: ([TEXT], [NUMBER], [NUMBER], [NUMBER])
model_item.sprite = Sprite.load("sprites/items/[file_name].png", separate_sprite_in_this_many_pieces, piece_x_center, piece_y_center)
-- Setting its Tier (Vanilla tiers are: "common", "uncommon", "rare", "use")
model_item:setTier("[TIER]")
-- Setting its description in the Item Log
model_item:setLog{
	-- Tier
	group = "[TIER]",
	-- Description on what it does (preferably more precise than the pickupText, i.e.: including percentages and stack values).
	description = "[DETAILED DESCRIPTION]",
	-- Little background story of the item.
	story = "[BACKGROUND STORY]",
	-- Destination to which the item was sent (since the ship you came from had delivery packages in it).
	destination = "[ITEM DESTINATION (WHERE IT WAS SENT TO)]"
	-- The date the item was sent.
	date = "[YEAR/MONTH/DAY]"
}

-- Create support variables here
-- Preferably, created a variable for anything and everything that could be changed in development.
-- Remember that your work is almost sure to be used as a base for another one.
-- Keep it clean, clear, organised and, more important, properly commented

local variable_1_name
local variable_2_name
local variable_3_name

-- Create support functions here

local function myFunc(number)
	print("The number is: " .. tostring(number))
end

-- Create support callbacks here
-- WARNING:
--   Callbacks exist forever (even across runs) no matter when they are defined. If you think you need to define a callback after load, then you’re probably doing something wrong. 

-- Create a callback
local customCallback = createcallback("exampleCustomCallback")

-- Add a function to it
local function myFunc(number)
    print("The number is: " .. tostring(number))
end
registercallback("exampleCustomCallback", myFunc)

-- Call it
customCallback(math.random(100))

-- Call callbacks here.
-- You'll use callbacks to fit your logic into the game logic.
-- i.e.: If you want something to happen upon entering each stage - including the first one -, you'll want to use registercallback

																										-- to be continued...