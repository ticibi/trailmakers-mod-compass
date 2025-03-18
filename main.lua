-- Compass Mod for Trailmakers
-- Name: Compass
-- Author: ticibi
-- Version: 2.0 (2025 Update)
-- Description: Dynamic compass display in game UI

local Compass = {
    DEBUG = false,
    globalTime = 0,
    COMPASS_PATTERN = "N....................E....................S....................W....................",
    UI_IDS = {
        HEADING = "heading",
        COMPASS = "compass",
        GLOBAL_TIME = "globaltime"
    }
}

-- Player Event Handlers
local function onPlayerJoined(player)
    local playerName = tm.players.GetPlayerName(player.playerId)
    tm.os.Log(playerName .. " joined the server")
    Compass:initializeUI(player.playerId)
end

local function onPlayerLeft(player)
    local playerName = tm.players.GetPlayerName(player.playerId)
    tm.os.Log(playerName .. " left the server")
end

-- Compass Class Methods
function Compass:initializeUI(playerId)
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUILabel(playerId, self.UI_IDS.HEADING, "")
    tm.playerUI.AddUILabel(playerId, self.UI_IDS.COMPASS, "")
    if self.DEBUG then
        tm.playerUI.AddUILabel(playerId, self.UI_IDS.GLOBAL_TIME, "")
    end
end

function Compass:getSpacer(heading)
    local headingInt = math.floor(heading)
    if headingInt >= 100 then
        return "                     "  -- 21 spaces
    elseif headingInt >= 10 then
        return "                      " -- 22 spaces
    end
    return "                       "     -- 23 spaces
end

function Compass:updateCompass(playerId)
    local transform = tm.players.GetPlayerTransform(playerId)
    local rotation = transform.GetRotation()
    local heading = rotation.y
    local rate = 360 / #self.COMPASS_PATTERN
    local hdgIndex = math.floor(heading / rate)
    
    -- Calculate display window
    local minValue = math.max(1, hdgIndex - 20)
    local maxValue = math.min(#self.COMPASS_PATTERN, hdgIndex + 22)
    local displayText = ""
    
    -- Handle compass wrapping
    if hdgIndex + 20 > #self.COMPASS_PATTERN then
        local overflow = hdgIndex + 20 - #self.COMPASS_PATTERN
        displayText = string.sub(self.COMPASS_PATTERN, minValue, #self.COMPASS_PATTERN) ..
                     string.sub(self.COMPASS_PATTERN, 1, overflow)
    elseif hdgIndex - 20 < 1 then
        local underflow = math.abs(hdgIndex - 20)
        displayText = string.sub(self.COMPASS_PATTERN, #self.COMPASS_PATTERN - underflow, #self.COMPASS_PATTERN) ..
                     string.sub(self.COMPASS_PATTERN, 1, maxValue)
    else
        displayText = string.sub(self.COMPASS_PATTERN, minValue, maxValue)
    end
    
    -- Update UI
    tm.playerUI.SetUIValue(playerId, self.UI_IDS.HEADING, math.floor(heading))
    tm.playerUI.SetUIValue(playerId, self.UI_IDS.COMPASS, displayText)
end

function Compass:update()
    local playerList = tm.players.CurrentPlayers()
    for _, player in pairs(playerList) do
        self:updateCompass(player.playerId)
        
        if self.DEBUG then
            self.globalTime = self.globalTime + 1
            tm.playerUI.SetUIValue(
                player.playerId,
                self.UI_IDS.GLOBAL_TIME,
                string.format("time: %.1f", self.globalTime / 10)
            )
        end
    end
end

-- Event Registration
tm.players.OnPlayerJoined.add(onPlayerJoined)
tm.players.OnPlayerLeft.add(onPlayerLeft)

-- Main Update Loop
function update()
    Compass:update()
end
