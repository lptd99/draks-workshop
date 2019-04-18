--Better-Crates

--Globals
BetterCrates = {
	["common"] =  {
		["crate"] = ItemPool.find("common"):getCrate(),
		["selected"] = 0,
	},
	["uncommon"] =  {
		["crate"] = ItemPool.find("uncommon"):getCrate(),
		["selected"] = 0,
	},
	["rare"] =  {
		["crate"] = ItemPool.find("rare"):getCrate(),
		["selected"] = 0,
	},
	["use"] =  {
		["crate"] = ItemPool.find("use"):getCrate(),
		["selected"] = 0,
	},
}
--Currently active crate name from above list.
local active_crate = nil

--Gives other mods time to modify the BetterCrates global table.
registercallback("onLoad",function()
	for key, data in pairs(BetterCrates) do
		--When a new crate drops set its selection to the stored selection.
		data.crate:addCallback("create",function(instance)
			if instance:isValid() then
				instance:set("selection",data.selected)
			end
		end)
		data.crate:addCallback("destroy",function(instance)
			--A crate is "destroyed" when an item is selected.
			--instance:isValid() is false in here so we have to be extra careful.
			--Reset open crate.
			active_crate = nil
			--Update the last selected value.
			local selected = instance:get("selection")
			data.selected = selected
			--Need to update all crates currently on the field.
			for _, crate in ipairs(data.crate:findAll()) do
				if crate:isValid() then
					crate:set("selection", selected)
				end
			end
		end)
	end
end)

--Looks at all the active crates every step (couldnt find a better callback)
--Also by doing this on the postStep we can close any crate before the draw being called.
registercallback("postStep",function()
	for key, data in pairs(BetterCrates) do
		--Dont need to look at crates that are ok to be open
		if active_crate ~= key then
			for _, thing in ipairs(data.crate:findAll()) do
				--Only need to look at crates that are currently open.
				if thing:isValid() and thing:get("active") == 1 then
					--If there is no other open, or the other open crate is the same type.
					if active_crate == nil or active_crate == key then
						--Become the open crate
						active_crate = key
					else
						--Reset the active and the alpha.
						--This hides the interface through fade_alpha.
						--Stops selection by setting active to 0.
						thing:set("active", 0)
						thing:set("fade_alpha", 0)
						--The player is still rooted by the currently active crate.
						--Any player state is still up to the still active crates to reset.
					end
				end
			end
		end
	end
end)