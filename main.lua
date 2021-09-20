-- Compass
-- by dinoman/ticibi 2021

local debug = false
local globalTime = 0
local compass = "N....................E....................S....................W...................."

function onPlayerJoined(player)
    tm.os.Log(tm.players.GetPlayerName(player.playerId) .. " joined the server")
    initializeUI_AndKeybinds(player.playerId)
end

function onPlayerLeft(player)
    tm.os.Log(tm.players.GetPlayerName(player.playerId) .. " left the server")
end

function initializeUI_AndKeybinds(playerId)
    homePage(playerId)
    --tm.input.RegisterFunctionToKeyDownCallback(playerId, "" ,"")
end

tm.players.OnPlayerJoined.add(onPlayerJoined)
tm.players.OnPlayerLeft.add(onPlayerLeft)

function update()
    local playerList = tm.players.CurrentPlayers()
    for k, player in pairs(playerList) do
        updateCompass(player.playerId)
        if debug then globalTime = globalTime + 1 end
        if debug then tm.playerUI.SetUIValue(player.playerId, "globaltime", "time: " .. globalTime/10) end
    end
end

function updateCompass(playerId)
    local transform = tm.players.GetPlayerTransform(playerId)
    local rotation = transform.GetRotation()
    local heading = rotation.y
    local spacer = ""
    if math.floor(heading) > 9 and math.floor(heading) < 100 then
        spacer = "                      "
    elseif math.floor(heading) > 100 then
        spacer = "                     "
    else
        spacer = "                       "
    end
    local rate = 360/#compass 
    local hdgIndex = math.floor(heading / rate)
    local minValue = hdgIndex - 20
    local maxValue = hdgIndex + 20
    local display = ""
    if hdgIndex + 20 > #compass then
        local diff = hdgIndex + 20 - (#compass)
        local buffer = string.sub(compass, 1, diff)
        display = string.sub(compass, minValue, #compass) .. buffer
    elseif hdgIndex - 20 < 1 then
        local diff = math.abs(hdgIndex - 20)
        local buffer = string.sub(compass, #compass-diff, #compass)
        display = buffer .. string.sub(compass, 1, maxValue+2)
    else
        display = string.sub(compass, minValue, maxValue+2)
    end
    tm.playerUI.SetUIValue(playerId, "heading", math.floor(heading))
    tm.playerUI.SetUIValue(playerId, "compass", display)  
end

function homePage(playerId)
    tm.playerUI.ClearUI(playerId)
    tm.playerUI.AddUILabel(playerId, "heading", "") 
    tm.playerUI.AddUILabel(playerId, "compass", "") 
    if debug then tm.playerUI.AddUILabel(playerId, "globaltime", "") end
end
