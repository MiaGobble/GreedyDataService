-- Define the class
local player = {}
player.__index = player

local leaderstats = require(script.Parent.leaderstats)

-- Constructor
function player.new(playerInstance : Player)
    local self = setmetatable({}, player)
    
    self.player = playerInstance
    self.leaderstats = leaderstats.new(playerInstance.UserId)

    return self
end

function player:init()
    if self.leaderstats.leaderstatsFolder then
        self.leaderstats.leaderstatsFolder.Parent = self.player
    end
end

function player:get(valueName : string)
    return self.leaderstats[valueName]:get()
end

function player:set(valueName : string, value : any)
    self.leaderstats[valueName]:set(value)
end

function player:update(valueName : string, transformer : (any) -> any)
    self.leaderstats[valueName]:update(transformer)
end

-- Return the class
return player
