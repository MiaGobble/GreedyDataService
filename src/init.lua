local greedyDataService = {}

local runService = game:GetService("RunService")

local playerObject = require(script.bin.player)
local leaderstats = require(script.bin.leaderstats)
local settings = require(script.config.settings)
local dataTemplate = require(script.config.dataTemplate)
local dataType = require(script.config.dataTemplate.dataType)

local loadedPlayerObjects = {}

local function init()
    table.insert(dataTemplate, dataType.private(false) "__SESSION_LOCKED")
    table.insert(dataTemplate, dataType.private(0) "__LAST_SESSION")
end

function greedyDataService:loadPlayer(player : Player)
    if loadedPlayerObjects[player] then
        return loadedPlayerObjects[player]
    end

    if not player:IsDescendantOf(game) then
        local waitStart = os.clock()

        repeat
            task.wait()
        until player:IsDescendantOf(game) or os.clock() - waitStart >= settings.loadingTimeout

        if not player:IsDescendantOf(game) then
            player:Kick("Data failed to load, please rejoin")
            warn(("Player %s failed to load data, kicked after %s seconds"):format(player.Name, os.clock() - waitStart))
            return nil
        end
    end

    loadedPlayerObjects[player] = playerObject.new(player)

    if loadedPlayerObjects[player].loadCancelled then
        loadedPlayerObjects[player] = nil
        warn(("Player %s was kicked for an already locked session"):format(player.Name))
        return nil
    else
        local lastUpdate = os.clock()

        local updateConnection = runService.Heartbeat:Connect(function()
            if os.clock() - lastUpdate > 1 then
                lastUpdate = os.clock()
                loadedPlayerObjects[player]:set("__LAST_SESSION", os.time())
            end
        end)

        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(game) then
                loadedPlayerObjects[player]:unlock()
                loadedPlayerObjects[player] = nil
                updateConnection:Disconnect()
            end
        end)
    
        loadedPlayerObjects[player].leaderstats:lock()
    
        return loadedPlayerObjects[player]
    end
end

function greedyDataService:getPlayerSession(player : Player)
    return loadedPlayerObjects[player]
end

function greedyDataService:setValueForPlayer(player : Player, valueName : string, value : any) : boolean
    if loadedPlayerObjects[player] then
        loadedPlayerObjects[player]:set(valueName, value)
        return true
    else
        warn(`Attempted set value for a player that does not exist (nil/{valueName}::{value})`)
        return false
    end
end

function greedyDataService:getValueFromPlayer(player : Player, valueName : string) : any
    if loadedPlayerObjects[player] then
        return loadedPlayerObjects[player]:get(valueName), true
    else
        warn(`Attempted get value from a player that does not exist (nil/{valueName})`)
        return nil, false
    end
end

function greedyDataService:updateValueForPlayer(player : Player, valueName : string, transformer : (any?) -> any?)
    if loadedPlayerObjects[player] then
        loadedPlayerObjects[player]:update(valueName, transformer)
        return true
    else
        warn(`Attempted to transform a value for a player that does not exist (nil/{valueName}::function->transformer)`)
        return false
    end
end

function greedyDataService:getMemoryFromUserId(userId : number)
    return leaderstats.new(userId)
end

return greedyDataService, init()