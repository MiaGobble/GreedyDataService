-- Define the class
local dataValue = {}
dataValue.__index = dataValue

local PREFIX = "%d/%s"
local LEADERSTATS_INSTANCE_TYPE_REMAP = {
    string = "StringValue",
    number = "NumberValue",
    boolean = "BoolValue",
    table = "StringValue",
}
local SAVE_INCREMENT = 3

type possibleDataTypes = "string" | "number" | "boolean" | "table"

type dataType = {
    valueName : string,
    defaultValue : string | number | boolean | table,
    dataType : possibleDataTypes,
    scope : "public" | "private",
}

local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")

local heatup = require(script.Parent.Parent.packages.heatup)
local datastore = heatup.new("greedyDataService")

local queuedChanges = {}

local function getEncodedAsValue(value : any) : any
    if typeof(value) ~= "string" then
        return value
    elseif (value:sub(1, 1) == `[` or value:sub(1, 1) == "{") and (value:sub(value:len(), value:len()) == `]` or value:sub(value:len(), value:len()) == "}") then
        return httpService:JSONDecode(value)
    else
        return value
    end
end

local function getValueAsEncoded(value : any) : any
    if typeof(value) == "table" then
		return httpService:JSONEncode(value)
	elseif typeof(value) == "boolean" then
		return if value then 1 else 0
    else
        return value
    end
end

local function queueChange(index : string, value : any)
    queuedChanges[index] = value
end

local function initializeQueue()
    local lastSave = os.clock()

    runService.Heartbeat:Connect(function()
        if os.clock() - lastSave > SAVE_INCREMENT then
            lastSave = os.clock()

            for index, value in pairs(queuedChanges) do
                datastore:Set(index, value)
            end

            queuedChanges = {}
        end
    end)
end

-- Constructor
function dataValue.new(dataType : dataType, userId : number)
    local self = setmetatable({}, dataValue)
   
    self.valueName = dataType.valueName
    self.defaultValue = dataType.defaultValue
    self.dataType = dataType.dataType
    self.scope = dataType.scope
    self.userId = userId

    self.leaderstatsValueInstance = nil
    self.currentValue = nil

    self:init()

    return self
end

function dataValue:init()
    local encodedValue = datastore:Get(PREFIX:format(self.userId, self.valueName), self.defaultValue) or self.defaultValue
    self.currentValue = getEncodedAsValue(encodedValue)

    if self.dataType == "boolean" then
        if self.currentValue == 1 then
            self.currentValue = true
        elseif self.currentValue == 0 then
            self.currentValue = false
        end
    end
end

function dataValue:getLeaderstatsValueInstance() : StringValue | NumberValue | BoolValue
    if self.leaderstatsValueInstance then
        return self.leaderstatsValueInstance
    end

    local valueInstance = Instance.new(LEADERSTATS_INSTANCE_TYPE_REMAP[self.dataType]) :: StringValue | NumberValue | BoolValue
    local value = getValueAsEncoded(self.currentValue)

    valueInstance.Name = self.valueName
    valueInstance.Value = value
    self.leaderstatsValueInstance = valueInstance

    valueInstance:GetPropertyChangedSignal("Value"):Connect(function()
        if valueInstance.Value ~= getValueAsEncoded(self:get()) then
            self:set(valueInstance.Value)
        end
    end)

    return valueInstance
end

function dataValue:get()
    return self.currentValue
end

function dataValue:set(newValue : possibleDataTypes)
    if typeof(newValue) ~= self.dataType then
        error("Invalid type for new value")
    end

    local encodedValue = getValueAsEncoded(newValue)

    self.currentValue = newValue

    if self.leaderstatsValueInstance then
        self.leaderstatsValueInstance.Value = encodedValue
    end

    queueChange(PREFIX:format(self.userId, self.valueName), encodedValue)
end

function dataValue:update(transformer : (any?) -> any?)
    local newValue = transformer(self.currentValue)

    if newValue == nil then
        return
    end

    self:set(newValue)
end

-- Return the class
return dataValue, initializeQueue()

-- initializeQueue should return nil
-- I just put it there to look pretty