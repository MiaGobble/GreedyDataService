-- Define the class
local player = {}
player.__index = player

local leaderstats = require(script.Parent.leaderstats)

-- Constructor
function player.new(playerInstance : Player)
    local self = setmetatable({}, player)
    
    self.player = playerInstance
    self.leaderstats = leaderstats.new(playerInstance.UserId)
    self.data = nil

    self:init()

    return self
end

function player:init()
    self.data = self.leaderstats.data
end

function player:get(valueName : string)
    return self.leaderstats:get(valueName)
end

function player:set(valueName : string, value : any)
    self.leaderstats:set(valueName, value)
end

function player:update(valueName : string, transformer : (any) -> any)
    self.leaderstats:update(valueName, transformer)
end

-- Return the class
return player
