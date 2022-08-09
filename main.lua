-- Compass Mod for Trailmakers, ticibi 2022
-- name: Compass
-- author: Thomas Bresee
-- description: dynamic compass display in game ui


local debug = false
local globalTime = 0
local compass = "N....................E....................S....................W...................."

function onPlayerJoined(player)
    tm.os.Log(tm.players.GetPlayerName(player.playerId) .. " joined the server")
    initializeUI(player.playerId)
end

function onPlayerLeft(player)
    tm.os.Log(tm.players.GetPlayerName(player.playerId) .. " left the server")
end

function initializeUI(playerId)
    homePage(playerId)
end

tm.players.OnPlayerJoined.add(onPlayerJoined)
tm.players.OnPlayerLeft.add(onPlayerLeft)

function update()
    local playerList = tm.players.CurrentPlayers()
    for _, player in pairs(playerList) do
        updateCompass(player.playerId)
        if debug then 
            globalTime = globalTime + 1
            tm.playerUI.SetUIValue(player.playerId, "globaltime", "time: " .. globalTime/10) 
        end
    end
end

function updateCompass(playerId)
    local transform = tm.players.GetPlayerTransform(playerId)
    local rotation = transform.GetRotation()
    local heading = rotation.y
    local spacer = updateSpacer()
    local rate = 360/#compass 
    local hdgIndex = math.floor(heading / rate)
    local minValue = hdgIndex - 20
    local maxValue = hdgIndex + 22
    local displayText = ""
    if hdgIndex + 20 > #compass then
        local diff = hdgIndex + 20 - (#compass)
        local buffer = string.sub(compass, 1, diff)
        displayText = string.sub(compass, minValue, #compass) .. buffer
    elseif hdgIndex - 20 < 1 then
        local diff = math.abs(hdgIndex - 20)
        local buffer = string.sub(compass, #compass-diff, #compass)
        displayText = buffer .. string.sub(compass, 1, maxValue)
    else
        displayText = string.sub(compass, minValue, maxValue)
    end
    tm.playerUI.SetUIValue(playerId, "heading", math.floor(heading))
    tm.playerUI.SetUIValue(playerId, "compass", displayText)  
end

function updateSpacer()
    local spacer = ""
    if math.floor(heading) > 9 and math.floor(heading) < 100 then
        spacer = "                      "
    elseif math.floor(heading) > 100 then
        spacer = "                     "
    else
        spacer = "                       "
    end
    return spacer
end

function homePage(playerId)
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUILabel(playerId, "heading", "") 
    tm.playerUI.AddUILabel(playerId, "compass", "") 
    if debug then tm.playerUI.AddUILabel(playerId, "globaltime", "") end
end
