-- meter.lua
-- Creates a display for combat.lua

local Display, DisplayMT = newtype("Display")
DisplayMT.__index = {}

local enemyObjectGroup = ObjectGroup.find("enemies")
local fonts = {nil, graphics.FONT_SMALL, graphics.FONT_DEFAULT, graphics.FONT_LARGE}

local header_text = "Rainy Stats"
local text_string = 
[[&lt&Armor&!&: %d
&lt&Attack Speed&!&: %.2f
&lt&Attack Damage&!&: %d
&lt&Critical Strike Chance&!&: %d

&lt&Speed&!&: %.2f
&lt&Experience&!&: %s / %s
&lt&Remaining Enemies&!&: %d

&lt&DPS&!&: %s (%d | %d)]]

function DisplayMT:__init(combat)
    self.settings = {
        active = true,
        draggable = true,
        position = {x = 20, y = 100},
        oldPosition = {x = 20, y = 100},
        size = {x = 0, y = 0},
        fontSize = {x = 0, y = 0},
        fontIndex = 3,
        headerHeight = 0,
        backgroundColor = {color = Color.BLACK, alpha = 2 / 10},
        headerColor = {color = Color.fromHex(0x737495), alpha = 10 / 10},
        padding = 2,
        headerFix = 3,
        keybind = "j"
    }

    self.stats = {
        totalAllyDamage = 0,
        totalAllyDPS = 0,
        allyCount = 0,
        secondsInCombat = 0,
        secondsOutOfCombat = 0
    }

    self.mouse = {
        clickedMouse = {x = 0, y = 0},
        position = {x = 0, y = 0},
        dragging = false
    }

    self.combat = combat
    self.settings.headerHeight = graphics.textHeight(header_text, fonts[self.settings.fontIndex])
    self.settings.fontSize.x = graphics.textWidth(text_string, fonts[self.settings.fontIndex])
    self.settings.fontSize.y = graphics.textHeight(text_string, fonts[self.settings.fontIndex])
    self.settings.size.x = self.settings.fontSize.x + 2 * self.settings.padding
    self.settings.size.y = self.settings.headerHeight + self.settings.fontSize.y + 2 * self.settings.padding
end

function DisplayMT.__index:draw(player)
    local playerAccessor = player:getAccessor()
    -- We don't care to draw or evaluate anything if we aren't even active
    if not self.settings.active then return end
    local enemyCount = #enemyObjectGroup:findAll()

    -- Header --
    do
        -- Bar
        setColor(self.settings.headerColor)
        graphics.rectangle(
            self.settings.position.x - 1, self.settings.position.y, 
            self.settings.position.x + self.settings.size.x + 1, 
            self.settings.position.y + self.settings.headerHeight
        )

        -- Top Text
        graphics.color(Color.WHITE)
        graphics.print(header_text,
            self.settings.position.x + self.settings.size.x / 2, 
            self.settings.position.y + self.settings.headerFix,
            fonts[self.settings.fontIndex],
            graphics.ALIGN_MIDDLE, graphics.ALIGN_TOP
        )
    end

    -- Body --
    do
        -- Background
        setColor(self.settings.backgroundColor)
        graphics.rectangle(
            self.settings.position.x, 
            self.settings.position.y + self.settings.headerHeight, 

            self.settings.position.x + self.settings.size.x, 
            self.settings.position.y + self.settings.size.y
        )

        -- Print our stats
        setColor({color = Color.WHITE, alpha = 1})
        graphics.printColor(
            string.format(text_string,
                playerAccessor.armor, -- Armor
                playerAccessor.attack_speed, -- Attack Speed
                playerAccessor.damage, -- Attack Damage
                playerAccessor.critical_chance, -- Critical Strike Chance
                playerAccessor.pHspeed, -- Speed
                formatNumber(playerAccessor.expr), formatNumber(playerAccessor.maxexp), -- Experience
                enemyCount, -- Remaining Enemies
                shortNumber(self.stats.totalAllyDPS), 
                self.stats.secondsInCombat, self.stats.secondsOutOfCombat), 
                -- DPS (In Combat | Out Combat)
            self.settings.position.x + 2 * self.settings.padding, 
            self.settings.position.y + 2 * self.settings.padding + self.settings.headerHeight, 
            fonts[self.settings.fontIndex]
        )
    end
end

function DisplayMT.__index:update()
    -- Dragable window boundries
    local boundries = {
        start = {
            x = self.settings.position.x,
            y = self.settings.position.y
        },
        ending = {
            x = self.settings.position.x + self.settings.size.x,
            y = self.settings.position.y + self.settings.size.y
        }
    }

    -- Check toggle of display size
    if input.checkKeyboard(self.settings.keybind) == input.PRESSED then
        self.settings.fontIndex = (self.settings.fontIndex % #fonts) + 1

        if self.settings.fontIndex == 1 then
            self.settings.active = false
        else
            self:updateSize(text_string)
            self.settings.active = true
        end
    end

    -- Set some stats to be updated
    self.mouse.position.x, self.mouse.position.y = input.getMousePos(true)
    self.stats.totalAllyDamage = 0
    self.stats.totalAllyDPS = 0
    self.stats.allyCount = 0
    self.stats.secondsInCombat = 0
    self.stats.secondsOutOfCombat = 0

    -- Count the number of ally players and update dps, time in combat, etc.
    for i, player in ipairs(self.combat.teams.allies) do
        self.stats.allyCount = self.stats.allyCount + 1
        self.stats.totalAllyDamage = self.stats.totalAllyDamage + player.combat.damage
        self.stats.totalAllyDPS = self.stats.totalAllyDPS + player.combat.DPS

        if player.combat.secondsInCombat > self.stats.secondsInCombat then
            self.stats.secondsInCombat = player.combat.secondsInCombat
        end

        if player.combat.secondsOutOfCombat > self.stats.secondsOutOfCombat then
            self.stats.secondsOutOfCombat = player.combat.secondsOutOfCombat
        end
    end

    -- Check to see if the window is being dragged
    if self.settings.active then
        self:drag(boundries)
    end
end

function DisplayMT.__index:drag(boundries)
    -- If draggable, mouse pressed, and bounded
    if isDragging(self, boundries) then
        -- Toggle dragging and set old mouse and window position for calculation
        self.mouse.dragging = true
        self.mouse.clickedMouse.x = self.mouse.position.x
        self.mouse.clickedMouse.y = self.mouse.position.y
        self.settings.oldPosition.x = self.settings.position.x
        self.settings.oldPosition.y = self.settings.position.y
    -- If dragging and mouse held down
    elseif self.mouse.dragging and input.checkMouse("left") == input.HELD then
        -- Update window position
        self.settings.position.x = (
            self.mouse.position.x - (self.mouse.clickedMouse.x - self.settings.oldPosition.x)
        ) 
        self.settings.position.y = (
            self.mouse.position.y - (self.mouse.clickedMouse.y - self.settings.oldPosition.y)
        )
    -- Mostly if the mouse isn't pressed or held, toggle dragging
    else
        self.mouse.dragging = false
    end
end

function DisplayMT.__index:updateSize()
    -- If visible
    if self.settings.fontIndex ~= 1 then
        -- There is a slight offset between font_small and font_medium which
        -- is different between medium and large. It's weird idek..
        self.settings.headerFix = 3
        if self.settings.fontIndex == 2 then
            -- The smaller font should go up a little more
            self.settings.headerFix = 1
        end
        -- Set header height, get font size, adjust size of window.
        self.settings.headerHeight = graphics.textHeight(header_text, fonts[self.settings.fontIndex])
        self.settings.fontSize.x = graphics.textWidth(text_string, fonts[self.settings.fontIndex])
        self.settings.fontSize.y = graphics.textHeight(text_string, fonts[self.settings.fontIndex])
        self.settings.size.x = self.settings.fontSize.x + 2 * self.settings.padding
        self.settings.size.y = self.settings.headerHeight + self.settings.fontSize.y + 2 * self.settings.padding
    end
end

function isDragging(self, boundries)
    return (
        self.settings.draggable 
        and input.checkMouse("left") == input.PRESSED 
        and isBounded(self.mouse.position, boundries)
    )
end

function isBounded(coordinates, boundries)
    if coordinates.x >= boundries.start.x and coordinates.x <= boundries.ending.x then
        if coordinates.y >= boundries.start.y and coordinates.y <= boundries.ending.y then
            return true
        end
    end

    return false
end

-- Just so I don't have to type out alpha and color :p
function setColor(colorThing)
    graphics.alpha(colorThing.alpha)
    graphics.color(colorThing.color)
end

-- Format time as seconds into minutes and seconds
function secondsToClock(s)
    local minutes = math.floor(s / 60)
    local seconds = s % 60

    return string.format("%dm %ds", minutes, seconds)
end

-- Format numbers for display

-- 0.0k / 0.0m
function shortNumber(n)
    if n >= 10^6 then
        return string.format("%.1fm", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.1fk", n / 10^3)
    else
        return string.format("%.1f", n)
    end
end

-- 000,000,000,000,000,000,000,000,000
function formatNumber(amount)
    local formatted = math.floor(amount)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end

return Display
