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
    self.loadCancelled = false

    self.data = nil

    self:init()

    return self
end

function leaderstats:init()
    for _, value in ipairs(dataTemplate) do
        local dataValueInstance = dataValue.new(value, self.userId)
        self.values[value.valueName] = dataValueInstance

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

    self.data = setmetatable({}, {
        __index = function(_, key)
            local value = self:get(key)

            if typeof(value) == "table" then
                local copy = table.clone(value)

                task.defer(function()
                    local isTableManipulated = false

                    for index, subValue in pairs(value) do
                        if copy[index] ~= subValue then
                            isTableManipulated = true
                            break
                        end
                    end

                    if isTableManipulated then
                        self:set(key, self:get(key))
                    end
                end)
            end

            return value
        end,

        __newindex = function(_, key, value)
            task.spawn(function()
                self:set(key, value)
            end)
        end,

        __call = function(_, key, transformer)
            task.spawn(function()
                self:update(key, transformer)
            end)
        end
    })

    if self.values.__SESSION_LOCKED:get() == true then
        if os.time() - self.values.__LAST_SESSION:get() > settings.sessionTimeout then
            self.values.__SESSION_LOCKED:set(false)
        else
            if self.player then
                self.player:Kick("Session locked because your data is loaded in another server. If you continue seeing this message, please rejoin the game.")
                self.loadCancelled = true
            end
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

function leaderstats:lock()
    self.values.__SESSION_LOCKED:set(true)
end

function leaderstats:unlock()
    self.values.__SESSION_LOCKED:set(false)
end

-- Return the class
return leaderstats
