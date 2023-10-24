-- Define the class
local leaderstats = {}
leaderstats.__index = leaderstats

local playersService = game:GetService("Players")

local dataValue = require(script.Parent.dataValue)
local dataTemplate = require(script.Parent.Parent.config.dataTemplate)
local settings = require(script.Parent.Parent.config.settings)

-- Constructor
function leaderstats.new(userId : number)
    local self = setmetatable({}, leaderstats)

    self.userId = userId
    self.player = playersService:GetPlayerByUserId(userId)
    self.values = {}
    self.leaderstatValueInstances = {}
    self.leaderstatsFolder = nil

    self:init()

    return self
end

function leaderstats:init()
    for _, value in ipairs(dataTemplate) do
        local dataValueInstance = dataValue.new(value, self.userId)
        self.values[value.valueName] = dataValueInstance
        print(dataValueInstance)

        if settings.addLeaderstatsFolder == true and self.player and value.scope == "public" then
            self.leaderstatValueInstances[value.valueName] = dataValueInstance:getLeaderstatsValueInstance()
        end
    end

    if settings.addLeaderstatsFolder and self.player then
        self.leaderstatsFolder = Instance.new("Folder")
        self.leaderstatsFolder.Name = "leaderstats"
        self.leaderstatsFolder.Parent = self.player

        for _, object in self.leaderstatValueInstances do
            object.Parent = self.leaderstatsFolder
        end
    end
end

function leaderstats:get(valueName : string)
    return self.values[valueName]:get()
end

function leaderstats:set(valueName : string, value : any)
    self.values[valueName]:set(value)
end

function leaderstats:update(valueName : string, transformer : (any) -> any)
    self.values[valueName]:update(transformer)
end

-- Return the class
return leaderstats
